import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSeatDto } from './dto/create-seat.dto';

@Injectable()
export class SeatsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, floor?: string, status?: string) {
    return this.prisma.seat.findMany({
      where: {
        ...(branchId && { branchId }),
        ...(floor && { floor }),
        ...(status && { status: status as any }),
      },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { member: { select: { id: true, name: true, memberCode: true } }, plan: { select: { name: true } } },
          take: 1,
        }
      },
      orderBy: [{ floor: 'asc' }, { seatNumber: 'asc' }]
    });
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
