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
        ...(status && { status: status as any }),
        lockerNumber: { in: validLockerNumbers },
      },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { member: { select: { id: true, name: true, memberCode: true } }, plan: { select: { name: true } } },
          take: 1,
        }
      },
      orderBy: { lockerNumber: 'asc' }
    });

    return lockers.slice(0, 9);
  }

  async findOne(id: string) {
    const locker = await this.prisma.locker.findUnique({
      where: { id },
      include: {
        subscriptions: { where: { status: 'ACTIVE' }, include: { member: true, plan: true }, take: 1 }
      }
    });
    if (!locker) throw new NotFoundException('Locker not found');
    return locker;
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
    const sub = await this.prisma.subscription.findUniqueOrThrow({ where: { id: subscriptionId } });
    await this.prisma.locker.update({ where: { id }, data: { status: 'OCCUPIED' } });
    await this.prisma.subscription.update({ where: { id: subscriptionId }, data: { assignedLockerId: id } });
    return this.prisma.lockerAssignment.create({ data: { lockerId: id, subscriptionId } });
  }

  async release(id: string) {
    await this.prisma.locker.update({ where: { id }, data: { status: 'AVAILABLE' } });
    const activeAssignment = await this.prisma.lockerAssignment.findFirst({ where: { lockerId: id, releasedAt: null } });
    if (activeAssignment) {
      await this.prisma.lockerAssignment.update({ where: { id: activeAssignment.id }, data: { releasedAt: new Date() } });
    }
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
