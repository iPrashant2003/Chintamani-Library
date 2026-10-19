import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSeatDto } from './dto/create-seat.dto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class SeatsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, floor?: string, status?: string) {
    let resolvedBranchId = branchId;
    let branchInfo: any = null;
    if (branchId) {
      branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        resolvedBranchId = branchInfo.id;
      }
    }

    const rawSeats = await this.prisma.seat.findMany({
      where: {
        ...(resolvedBranchId && { branchId: resolvedBranchId }),
        ...(floor && { floor }),
      },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { member: { select: { id: true, name: true, memberCode: true, isActive: true } }, plan: { select: { name: true } } },
          orderBy: { endDate: 'desc' },
          take: 1,
        }
      },
    });

    // ── Enforce Single Hall seat numbering for Chintamani branches ──
    let seats = rawSeats;
    if (branchInfo) {
      const isMhd = branchInfo.isMehdawal;
      const prefix = isMhd ? 'M' : 'K';
      const maxSeat = isMhd ? 65 : 72;
      const validPattern = new RegExp(`^${prefix}(\\d{2})$`);
      seats = rawSeats.filter(s => {
        const m = s.seatNumber.match(validPattern);
        if (!m) return false;
        const num = parseInt(m[1], 10);
        return num >= 1 && num <= maxSeat;
      });
    }

    // Natural sort: K01, K02, ..., K10, K11, ... K72
    seats.sort((a, b) => {
      const numA = parseInt(a.seatNumber.replace(/[^0-9]/g, ''), 10) || 0;
      const numB = parseInt(b.seatNumber.replace(/[^0-9]/g, ''), 10) || 0;
      return numA - numB;
    });

    const now = new Date();
    // Authoritative status calculation and auto-reconciliation
    const reconciledSeats = await Promise.all(seats.map(async (seat) => {
      const activeSub = seat.subscriptions[0];
      const isValid = !!(activeSub && activeSub.member?.isActive && new Date(activeSub.endDate) >= now);
      const authoritativeStatus = isValid
        ? 'OCCUPIED'
        : (seat.status === 'BLOCKED' ? 'BLOCKED' : (seat.status === 'MAINTENANCE' ? 'MAINTENANCE' : 'AVAILABLE'));

      // Reconcile database state if out of sync
      if (seat.status === 'OCCUPIED' && !isValid) {
        try {
          await this.prisma.$transaction([
            this.prisma.seat.update({
              where: { id: seat.id },
              data: { status: 'AVAILABLE' },
            }),
            this.prisma.seatAssignment.updateMany({
              where: { seatId: seat.id, releasedAt: null },
              data: { releasedAt: now },
            }),
            ...(activeSub ? [
              this.prisma.subscription.update({
                where: { id: activeSub.id },
                data: { assignedSeatId: null },
              }),
            ] : []),
          ]);
        } catch (_) {}
      }

      return {
        ...seat,
        status: authoritativeStatus,
        currentMemberName: isValid ? activeSub?.member?.name : null,
      };
    }));

    if (status && status !== 'ALL') {
      return reconciledSeats.filter(s => s.status === status);
    }

    return reconciledSeats;
  }

  async findOne(id: string) {
    const seat = await this.prisma.seat.findUnique({
      where: { id },
      include: {
        subscriptions: { where: { status: 'ACTIVE' }, include: { member: true, plan: true }, take: 1 }
      }
    });
    if (!seat) throw new NotFoundException('Seat not found');
    return seat;
  }

  async create(dto: CreateSeatDto) { 
    const branch = await this.prisma.branch.findUniqueOrThrow({ where: { id: dto.branchId } });
    return this.prisma.seat.create({
      data: {
        ...dto,
        tenantId: branch.tenantId,
      },
    }); 
  }

  async updateStatus(id: string, status: string) { 
    return this.prisma.seat.update({ where: { id }, data: { status: status as any } }); 
  }

  async assign(id: string, subscriptionId: string) {
    const sub = await this.prisma.subscription.findUniqueOrThrow({ where: { id: subscriptionId } });
    await this.prisma.seat.update({ where: { id }, data: { status: 'OCCUPIED' } });
    await this.prisma.subscription.update({ where: { id: subscriptionId }, data: { assignedSeatId: id } });
    return this.prisma.seatAssignment.create({ data: { seatId: id, subscriptionId } });
  }

  async release(id: string) {
    await this.prisma.seat.update({ where: { id }, data: { status: 'AVAILABLE' } });
    const activeAssignment = await this.prisma.seatAssignment.findFirst({ where: { seatId: id, releasedAt: null } });
    if (activeAssignment) {
      await this.prisma.seatAssignment.update({ where: { id: activeAssignment.id }, data: { releasedAt: new Date() } });
    }
    return { message: 'Seat released successfully' };
  }

  async deallocate(id: string, adminUser?: any, reason?: string) {
    const seat = await this.prisma.seat.findUnique({
      where: { id },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { member: true },
        },
      },
    });
    if (!seat) throw new NotFoundException('Seat not found');
    if (seat.status === 'AVAILABLE') {
      return { success: true, message: `Seat ${seat.seatNumber} is already available` };
    }

    await this.prisma.$transaction(async (tx) => {
      // Release the seat
      await tx.seat.update({ where: { id }, data: { status: 'AVAILABLE' } });

      // Mark any open assignment as released
      const activeAssignment = await tx.seatAssignment.findFirst({ where: { seatId: id, releasedAt: null } });
      if (activeAssignment) {
        await tx.seatAssignment.update({ where: { id: activeAssignment.id }, data: { releasedAt: new Date() } });
      }

      // Unlink the seat from any active subscriptions
      for (const sub of seat.subscriptions) {
        await tx.subscription.update({ where: { id: sub.id }, data: { assignedSeatId: null } });
      }

      // Audit log
      try {
        await tx.auditLog.create({
          data: {
            tenantId: seat.tenantId,
            userId: adminUser?.id || null,
            branchId: seat.branchId,
            action: 'DEALLOCATE_SEAT',
            entity: 'Seat',
            entityId: seat.id,
            metadata: JSON.stringify({
              seatNumber: seat.seatNumber,
              reason: reason || 'Manual admin deallocation',
              admin: adminUser?.name || 'Admin',
              membersAffected: seat.subscriptions.map((s) => ({ id: s.memberId, name: s.member?.name })),
            }),
          },
        });
      } catch (_) {}
    });

    return { success: true, message: `Seat ${seat.seatNumber} has been deallocated and is now available` };
  }

  async getHistory(id: string) {
    return this.prisma.seatAssignment.findMany({ 
      where: { seatId: id }, 
      include: { subscription: { include: { member: true, plan: true } } }, 
      orderBy: { assignedAt: 'desc' } 
    });
  }

  // ── SEAT MANAGEMENT EXTENSIONS ────────────────────────────────────────────

  async getSummary(branchId?: string) {
    const where: any = {};
    if (branchId) where.branchId = branchId;

    const [total, available, reserved, occupied, blocked] = await Promise.all([
      this.prisma.seat.count({ where }),
      this.prisma.seat.count({ where: { ...where, status: 'AVAILABLE' } }),
      this.prisma.seat.count({ where: { ...where, status: 'RESERVED' } }),
      this.prisma.seat.count({ where: { ...where, status: 'OCCUPIED' } }),
      this.prisma.seat.count({ where: { ...where, status: 'BLOCKED' } }),
    ]);

    return { total, available, reserved, occupied, blocked };
  }

  async block(id: string, notes?: string, adminUser?: any) {
    const seat = await this.prisma.seat.findUnique({ where: { id } });
    if (!seat) throw new NotFoundException('Seat not found');

    const updated = await this.prisma.seat.update({
      where: { id },
      data: { status: 'BLOCKED', notes: notes || seat.notes },
    });

    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: seat.tenantId,
          userId: adminUser?.id || null,
          branchId: seat.branchId,
          action: 'BLOCK_SEAT',
          entity: 'Seat',
          entityId: seat.id,
          metadata: JSON.stringify({ seatNumber: seat.seatNumber, notes, admin: adminUser?.name || 'Admin' }),
        },
      });
    } catch (_) {}

    return { success: true, message: `Seat ${seat.seatNumber} has been blocked`, seat: updated };
  }

  async unblock(id: string, adminUser?: any) {
    const seat = await this.prisma.seat.findUnique({ where: { id } });
    if (!seat) throw new NotFoundException('Seat not found');

    const updated = await this.prisma.seat.update({
      where: { id },
      data: { status: 'AVAILABLE' },
    });

    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: seat.tenantId,
          userId: adminUser?.id || null,
          branchId: seat.branchId,
          action: 'UNBLOCK_SEAT',
          entity: 'Seat',
          entityId: seat.id,
          metadata: JSON.stringify({ seatNumber: seat.seatNumber, admin: adminUser?.name || 'Admin' }),
        },
      });
    } catch (_) {}

    return { success: true, message: `Seat ${seat.seatNumber} is now available`, seat: updated };
  }

  async reassign(seatId: string, newSeatId: string, adminUser?: any) {
    // 1. Find old seat and its active subscription
    const oldSeat = await this.prisma.seat.findUnique({
      where: { id: seatId },
      include: {
        subscriptions: { where: { status: 'ACTIVE' }, include: { member: true, plan: true } },
      },
    });

    if (!oldSeat) throw new NotFoundException('Current seat not found');
    const activeSub = oldSeat.subscriptions[0];
    if (!activeSub) {
      throw new NotFoundException('No active membership found on the current seat');
    }

    // 2. Validate new seat exists and is AVAILABLE
    const newSeat = await this.prisma.seat.findUnique({ where: { id: newSeatId } });
    if (!newSeat) throw new NotFoundException('Target seat not found');
    if (newSeat.status !== 'AVAILABLE') {
      throw new NotFoundException(
        `Target seat ${newSeat.seatNumber} is currently ${newSeat.status}. Only AVAILABLE seats can be allocated.`
      );
    }

    // 3. Release old seat
    await this.prisma.seat.update({
      where: { id: seatId },
      data: { status: 'AVAILABLE' },
    });
    const oldAssignment = await this.prisma.seatAssignment.findFirst({
      where: { seatId, subscriptionId: activeSub.id, releasedAt: null },
    });
    if (oldAssignment) {
      await this.prisma.seatAssignment.update({
        where: { id: oldAssignment.id },
        data: { releasedAt: new Date() },
      });
    }

    // 4. Assign new seat
    await this.prisma.seat.update({
      where: { id: newSeatId },
      data: { status: 'OCCUPIED' },
    });
    await this.prisma.subscription.update({
      where: { id: activeSub.id },
      data: { assignedSeatId: newSeatId },
    });
    await this.prisma.seatAssignment.create({
      data: { seatId: newSeatId, subscriptionId: activeSub.id },
    });

    // 5. Audit Log
    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: oldSeat.tenantId,
          userId: adminUser?.id || null,
          branchId: oldSeat.branchId,
          action: 'REASSIGN_SEAT',
          entity: 'Seat',
          entityId: newSeatId,
          metadata: JSON.stringify({
            memberId: activeSub.memberId,
            memberName: activeSub.member.name,
            fromSeat: oldSeat.seatNumber,
            toSeat: newSeat.seatNumber,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Member ${activeSub.member.name} successfully moved from Seat ${oldSeat.seatNumber} to Seat ${newSeat.seatNumber}`,
      fromSeat: oldSeat.seatNumber,
      toSeat: newSeat.seatNumber,
    };
  }

  async update(id: string, data: { seatNumber?: string; floor?: string; notes?: string }) {
    const seat = await this.prisma.seat.findUnique({ where: { id } });
    if (!seat) throw new NotFoundException('Seat not found');

    return this.prisma.seat.update({
      where: { id },
      data: {
        ...(data.seatNumber && { seatNumber: data.seatNumber }),
        ...(data.floor && { floor: data.floor }),
        ...(data.notes !== undefined && { notes: data.notes }),
      },
    });
  }

  async remove(id: string) {
    const seat = await this.prisma.seat.findUnique({
      where: { id },
      include: { subscriptions: { where: { status: 'ACTIVE' } } },
    });
    if (!seat) throw new NotFoundException('Seat not found');
    if (seat.subscriptions.length > 0 || seat.status === 'OCCUPIED' || seat.status === 'RESERVED') {
      throw new NotFoundException(`Cannot delete Seat ${seat.seatNumber} while it is ${seat.status}`);
    }

    await this.prisma.seat.delete({ where: { id } });
    return { success: true, message: `Seat ${seat.seatNumber} deleted successfully` };
  }
}
