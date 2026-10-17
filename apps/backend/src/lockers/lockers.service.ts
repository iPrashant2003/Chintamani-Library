import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateLockerDto } from './dto/create-locker.dto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class LockersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, status?: string) {
    let resolvedBranchId = branchId;
    let branchInfo: any = null;
    if (branchId) {
      branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        resolvedBranchId = branchInfo.id;
      }
    }

    // Official library policy: exactly 9 lockers per branch (L01–L09)
    const validLockerNumbers = [
      'L01', 'L02', 'L03', 'L04', 'L05', 'L06', 'L07', 'L08', 'L09',
      'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7', 'L8', 'L9',
    ];

    // Clean up any excess lockers (> 9) from the database
    if (resolvedBranchId) {
      try {
        await this.prisma.locker.deleteMany({
          where: {
            branchId: resolvedBranchId,
            lockerNumber: { notIn: validLockerNumbers },
            subscriptions: { none: {} },
          },
        });
      } catch (_) {}
    }

    const lockers = await this.prisma.locker.findMany({
      where: {
        ...(resolvedBranchId && { branchId: resolvedBranchId }),
        lockerNumber: { in: validLockerNumbers },
      },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { member: { select: { id: true, name: true, memberCode: true } }, plan: { select: { name: true } } },
          take: 1,
        },
        assignments: {
          where: { releasedAt: null },
          include: { subscription: { include: { member: { select: { id: true, name: true, memberCode: true } } } } },
          take: 1,
        }
      },
      orderBy: { lockerNumber: 'asc' }
    });

    // Authoritative status calculation: A locker is OCCUPIED only if an active subscription or unreleased assignment exists
    const reconciledLockers = await Promise.all(lockers.map(async (locker) => {
      const activeSub = locker.subscriptions[0] || locker.assignments[0]?.subscription;
      const hasActiveAssignment = !!activeSub;
      const authoritativeStatus = hasActiveAssignment
        ? 'OCCUPIED'
        : (locker.status === 'MAINTENANCE' ? 'MAINTENANCE' : 'AVAILABLE');

      // Reconcile database state if out of sync
      if (locker.status !== authoritativeStatus && locker.status !== 'MAINTENANCE') {
        try {
          await this.prisma.locker.update({
            where: { id: locker.id },
            data: { status: authoritativeStatus as any },
          });
        } catch (_) {}
      }

      return {
        ...locker,
        status: authoritativeStatus,
        currentMemberName: activeSub?.member?.name || null,
        currentMemberId: activeSub?.member?.id || null,
      };
    }));

    const filtered = status && status !== 'ALL'
      ? reconciledLockers.filter((l) => l.status === status)
      : reconciledLockers;

    return filtered.slice(0, 9);
  }

  async findOne(id: string) {
    const locker = await this.prisma.locker.findUnique({
      where: { id },
      include: {
        subscriptions: { where: { status: 'ACTIVE' }, include: { member: true, plan: true }, take: 1 },
        assignments: { where: { releasedAt: null }, include: { subscription: { include: { member: true } } }, take: 1 }
      }
    });
    if (!locker) throw new NotFoundException('Locker not found');

    const activeSub = locker.subscriptions[0] || locker.assignments[0]?.subscription;
    const hasActiveAssignment = !!activeSub;
    const authoritativeStatus = hasActiveAssignment
      ? 'OCCUPIED'
      : (locker.status === 'MAINTENANCE' ? 'MAINTENANCE' : 'AVAILABLE');

    if (locker.status !== authoritativeStatus && locker.status !== 'MAINTENANCE') {
      try {
        await this.prisma.locker.update({
          where: { id: locker.id },
          data: { status: authoritativeStatus as any },
        });
      } catch (_) {}
    }

    return {
      ...locker,
      status: authoritativeStatus,
      currentMemberName: activeSub?.member?.name || null,
      currentMemberId: activeSub?.member?.id || null,
    };
  }

  async create(dto: CreateLockerDto) { 
    const branch = await this.prisma.branch.findUniqueOrThrow({ where: { id: dto.branchId } });
    return this.prisma.locker.create({
      data: {
        ...dto,
        tenantId: branch.tenantId,
      },
    }); 
  }

  async updateStatus(id: string, status: string) { 
    return this.prisma.locker.update({ where: { id }, data: { status: status as any } }); 
  }

  async assign(id: string, subscriptionId: string) {
    const sub = await this.prisma.subscription.findUniqueOrThrow({
      where: { id: subscriptionId },
      include: { member: true }
    });
    const locker = await this.prisma.locker.findUniqueOrThrow({ where: { id } });

    // Validate branch match
    if (sub.member.branchId && locker.branchId && sub.member.branchId !== locker.branchId) {
      throw new Error('Locker and Member belong to different branches');
    }

    await this.prisma.$transaction([
      this.prisma.locker.update({ where: { id }, data: { status: 'OCCUPIED' } }),
      this.prisma.subscription.update({ where: { id: subscriptionId }, data: { assignedLockerId: id } }),
      this.prisma.lockerAssignment.create({ data: { lockerId: id, subscriptionId } }),
    ]);

    return { message: 'Locker assigned successfully', lockerId: id, memberName: sub.member.name };
  }

  async release(id: string) {
    await this.prisma.$transaction(async (tx) => {
      await tx.locker.update({ where: { id }, data: { status: 'AVAILABLE' } });
      await tx.subscription.updateMany({ where: { assignedLockerId: id }, data: { assignedLockerId: null } });
      await tx.lockerAssignment.updateMany({
        where: { lockerId: id, releasedAt: null },
        data: { releasedAt: new Date() },
      });
    });
    return { message: 'Locker released successfully' };
  }

  async getHistory(id: string) {
    return this.prisma.lockerAssignment.findMany({ 
      where: { lockerId: id }, 
      include: { subscription: { include: { member: true, plan: true } } }, 
      orderBy: { assignedAt: 'desc' } 
    });
  }
}
