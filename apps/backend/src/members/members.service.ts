import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { QueryMembersDto } from './dto/query-members.dto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class MembersService {
  constructor(private readonly prisma: PrismaService) {}

  private generateMemberCode(prefix = 'LIB'): string {
    return `${prefix}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
  }

  private parseSafeDob(dobStr?: string): Date | null {
    if (!dobStr) return null;
    try {
      const clean = dobStr.split('T')[0].trim();
      const parts = clean.split('-').map(Number);
      if (parts.length === 3 && !isNaN(parts[0]) && !isNaN(parts[1]) && !isNaN(parts[2])) {
        const year = parts[0];
        const month = parts[1] - 1;
        const day = parts[2];
        const parsed = new Date(year, month, day, 12, 0, 0);
        if (parsed > new Date()) return null;
        return parsed;
      }
      const d = new Date(dobStr);
      return isNaN(d.getTime()) || d > new Date() ? null : d;
    } catch (_) {
      return null;
    }
  }

  async create(user: any, createMemberDto: CreateMemberDto) {
    let tenantId = user?.tenantId;
    let tenantCode = 'LIB';
    let resolvedBranchId = createMemberDto.branchId;

    if (createMemberDto.branchId) {
      const branchInfo = await resolveBranchInfo(this.prisma, createMemberDto.branchId, tenantId);
      if (branchInfo) {
        resolvedBranchId = branchInfo.id;
        const branch = await this.prisma.branch.findUnique({
          where: { id: branchInfo.id },
          include: { tenant: true },
        });
        if (branch) {
          tenantId = branch.tenantId;
          tenantCode = branch.tenant?.code || 'LIB';
        }
      }
    }

    if (!tenantId) {
      throw new NotFoundException('Branch or tenant not found');
    }

    const memberCode = this.generateMemberCode(tenantCode);
    const academicData = {
      fatherName: createMemberDto.fatherName,
      gender: createMemberDto.gender,
      emergencyContact: createMemberDto.emergencyContact,
      aadhaar: createMemberDto.aadhaar,
      institute: createMemberDto.institute,
      course: createMemberDto.course,
      batch: createMemberDto.batch,
      photoUrl: createMemberDto.photoUrl,
      notes: createMemberDto.notes,
    };

    return this.prisma.member.create({
      data: {
        tenantId,
        memberCode,
        name: createMemberDto.name,
        phone: createMemberDto.phone,
        email: createMemberDto.email,
        dob: this.parseSafeDob(createMemberDto.dob),
        address: createMemberDto.address,
        photoUrl: createMemberDto.photoUrl || null,
        aadhaarNumber: createMemberDto.aadhaar?.replace(/\s/g, '') || null,
        aadhaarFrontUrl: (createMemberDto as any).aadhaarFrontUrl || null,
        aadhaarBackUrl: (createMemberDto as any).aadhaarBackUrl || null,
        otherDocUrls: (createMemberDto as any).otherDocUrls || null,
        academicInfo: JSON.stringify(academicData),
        branchId: resolvedBranchId,
        isActive: true,
      },
    });
  }

  async findAll(user: any, query: QueryMembersDto) {
    const { branchId, status, search, page = 1, limit = 10 } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 10;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {
      isArchived: false,
      NOT: [
        {
          isActive: false,
          subscriptions: { none: {} },
        },
      ],
    };
    if (user?.tenantId) where.tenantId = user.tenantId;
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId, user?.tenantId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
    }

    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const endOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
    const day3End = new Date(endOfToday.getTime() + 3 * 86400000);
    const day5End = new Date(endOfToday.getTime() + 5 * 86400000);
    const day7End = new Date(endOfToday.getTime() + 7 * 86400000);
    const day15End = new Date(endOfToday.getTime() + 15 * 86400000);

    if (status === 'active') {
      where.isActive = true;
      where.subscriptions = {
        some: {
          status: 'ACTIVE',
          endDate: { gte: startOfToday },
        },
      };
    } else if (status === 'expired' || status === 'inactive') {
      where.OR = [
        { isActive: false },
        {
          subscriptions: {
            none: {
              status: 'ACTIVE',
              endDate: { gte: startOfToday },
            },
          },
        },
      ];
    } else if (status === 'expiring1_3') {
      where.isActive = true;
      where.subscriptions = {
        some: {
          status: 'ACTIVE',
          endDate: { gt: endOfToday, lte: day3End },
        },
      };
    } else if (status === 'expiring3_5' || status === 'expiring4_7') {
      where.isActive = true;
      where.subscriptions = {
        some: {
          status: 'ACTIVE',
          endDate: { gt: day3End, lte: day5End },
        },
      };
    } else if (status === 'expiring8_15') {
      where.isActive = true;
      where.subscriptions = {
        some: {
          status: 'ACTIVE',
          endDate: { gt: day7End, lte: day15End },
        },
      };
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { memberCode: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [members, total] = await Promise.all([
      this.prisma.member.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          subscriptions: {
            include: { plan: true, seat: true, locker: true },
            orderBy: { endDate: 'desc' },
            take: 3,
          },
          registration: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.member.count({ where }),
    ]);

    return { data: members, total, page: pageNum, limit: limitNum };
  }

  async getStats(user: any, branchId?: string) {
    const where: any = { isArchived: false };
    if (user?.tenantId) where.tenantId = user.tenantId;
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId, user?.tenantId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
    }

    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const endOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
    const day3End = new Date(endOfToday.getTime() + 3 * 86400000);
    const day5End = new Date(endOfToday.getTime() + 5 * 86400000);
    const day7End = new Date(endOfToday.getTime() + 7 * 86400000);
    const day15End = new Date(endOfToday.getTime() + 15 * 86400000);

    const [total, active, expired, exp1_3, exp3_5, exp8_15] = await Promise.all([
      this.prisma.member.count({ where }),
      this.prisma.member.count({
        where: {
          ...where,
          isActive: true,
          subscriptions: {
            some: {
              status: 'ACTIVE',
              endDate: { gte: startOfToday },
            },
          },
        },
      }),
      this.prisma.member.count({
        where: {
          ...where,
          OR: [
            { isActive: false },
            {
              subscriptions: {
                none: {
                  status: 'ACTIVE',
                  endDate: { gte: startOfToday },
                },
              },
            },
          ],
        },
      }),
      this.prisma.member.count({
        where: {
          ...where,
          isActive: true,
          subscriptions: {
            some: {
              status: 'ACTIVE',
              endDate: { gt: endOfToday, lte: day3End },
            },
          },
        },
      }),
      this.prisma.member.count({
        where: {
          ...where,
          isActive: true,
          subscriptions: {
            some: {
              status: 'ACTIVE',
              endDate: { gt: day3End, lte: day5End },
            },
          },
        },
      }),
      this.prisma.member.count({
        where: {
          ...where,
          isActive: true,
          subscriptions: {
            some: {
              status: 'ACTIVE',
              endDate: { gt: day7End, lte: day15End },
            },
          },
        },
      }),
    ]);

    return {
      all: total,
      active,
      expired,
      expiring1_3: exp1_3,
      expiring3_5: exp3_5,
      expiring4_7: exp3_5,
      expiring8_15: exp8_15,
    };
  }

  async getMemberProfile(user: any, id: string) {
    const where: any = { id };
    if (user?.tenantId) where.tenantId = user.tenantId;

    const member = await this.prisma.member.findFirst({
      where,
      include: {
        subscriptions: {
          include: { plan: true, seat: true, locker: true },
          orderBy: { createdAt: 'desc' },
        },
        attendances: {
          orderBy: { checkIn: 'desc' },
          take: 30,
        },
        payments: {
          orderBy: { createdAt: 'desc' },
        },
        registration: true,
      },
    });
    if (!member) throw new NotFoundException('Member not found');
    return member;
  }

  async update(id: string, updateMemberDto: UpdateMemberDto) {
    const dataToUpdate: any = {};
    if (updateMemberDto.name) dataToUpdate.name = updateMemberDto.name;
    if (updateMemberDto.phone) dataToUpdate.phone = updateMemberDto.phone;
    if (updateMemberDto.email) dataToUpdate.email = updateMemberDto.email;
    if (updateMemberDto.dob) dataToUpdate.dob = this.parseSafeDob(updateMemberDto.dob);
    if (updateMemberDto.address) dataToUpdate.address = updateMemberDto.address;
    if ((updateMemberDto as any).photoUrl !== undefined) dataToUpdate.photoUrl = (updateMemberDto as any).photoUrl;
    if ((updateMemberDto as any).aadhaar !== undefined) dataToUpdate.aadhaarNumber = (updateMemberDto as any).aadhaar;
    if ((updateMemberDto as any).aadhaarNumber !== undefined) dataToUpdate.aadhaarNumber = (updateMemberDto as any).aadhaarNumber;
    if ((updateMemberDto as any).aadhaarFrontUrl !== undefined) dataToUpdate.aadhaarFrontUrl = (updateMemberDto as any).aadhaarFrontUrl;
    if ((updateMemberDto as any).aadhaarBackUrl !== undefined) dataToUpdate.aadhaarBackUrl = (updateMemberDto as any).aadhaarBackUrl;
    if ((updateMemberDto as any).otherDocUrls !== undefined) dataToUpdate.otherDocUrls = (updateMemberDto as any).otherDocUrls;

    return this.prisma.member.update({
      where: { id },
      data: dataToUpdate,
    });
  }

  async findArchived(user: any, query: QueryMembersDto) {
    const { branchId, search, page = 1, limit = 10 } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 10;
    const skip = (pageNum - 1) * limitNum;

    const where: any = { isArchived: true };
    if (user?.tenantId) where.tenantId = user.tenantId;
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId, user?.tenantId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { memberCode: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [members, total] = await Promise.all([
      this.prisma.member.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          subscriptions: {
            include: { plan: true, seat: true, locker: true },
            orderBy: { endDate: 'desc' },
            take: 3,
          },
          registration: true,
        },
        orderBy: { archivedAt: 'desc' },
      }),
      this.prisma.member.count({ where }),
    ]);

    return { data: members, total, page: pageNum, limit: limitNum };
  }

  async archiveMember(id: string, user?: any) {
    const member = await this.prisma.member.findUnique({
      where: { id },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { seat: true, locker: true },
        },
      },
    });

    if (!member) throw new NotFoundException('Member not found');
    if (member.isArchived) {
      throw new BadRequestException(`Member ${member.name} is already archived.`);
    }

    const now = new Date();
    const adminName = user?.name || 'Admin';

    await this.prisma.$transaction(async (tx) => {
      // 1. Release assigned seats atomically
      for (const sub of member.subscriptions) {
        if (sub.assignedSeatId) {
          await tx.seat.update({
            where: { id: sub.assignedSeatId },
            data: { status: 'AVAILABLE' },
          });
          await tx.seatAssignment.updateMany({
            where: { seatId: sub.assignedSeatId, subscriptionId: sub.id, releasedAt: null },
            data: { releasedAt: now },
          });
          await tx.subscription.update({
            where: { id: sub.id },
            data: { assignedSeatId: null },
          });
        }

        // 2. Release assigned lockers atomically
        if (sub.assignedLockerId) {
          await tx.locker.update({
            where: { id: sub.assignedLockerId },
            data: { status: 'AVAILABLE' },
          });
          await tx.lockerAssignment.updateMany({
            where: { lockerId: sub.assignedLockerId, subscriptionId: sub.id, releasedAt: null },
            data: { releasedAt: now },
          });
          await tx.subscription.update({
            where: { id: sub.id },
            data: { assignedLockerId: null },
          });
        }
      }

      // 3. Update member record to archived
      await tx.member.update({
        where: { id },
        data: {
          isArchived: true,
          archivedAt: now,
          archivedBy: adminName,
          isActive: false,
        },
      });

      // 4. Audit Log
      try {
        await tx.auditLog.create({
          data: {
            tenantId: member.tenantId,
            userId: user?.id || null,
            branchId: member.branchId,
            action: 'ARCHIVE_MEMBER',
            entity: 'Member',
            entityId: member.id,
            metadata: JSON.stringify({
              memberCode: member.memberCode,
              name: member.name,
              archivedBy: adminName,
              archivedAt: now.toISOString(),
            }),
          },
        });
      } catch (_) {}
    });

    return {
      success: true,
      message: `Member ${member.name} (${member.memberCode}) has been safely archived. Assigned seats and lockers have been released.`,
    };
  }

  async restoreMember(id: string, user?: any) {
    const member = await this.prisma.member.findUnique({ where: { id } });
    if (!member) throw new NotFoundException('Member not found');
    if (!member.isArchived) {
      throw new BadRequestException(`Member ${member.name} is not archived.`);
    }

    const updated = await this.prisma.member.update({
      where: { id },
      data: {
        isArchived: false,
        archivedAt: null,
        archivedBy: null,
        isActive: true,
      },
    });

    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: member.tenantId,
          userId: user?.id || null,
          branchId: member.branchId,
          action: 'RESTORE_MEMBER',
          entity: 'Member',
          entityId: member.id,
          metadata: JSON.stringify({
            memberCode: member.memberCode,
            name: member.name,
            restoredBy: user?.name || 'Admin',
            restoredAt: new Date().toISOString(),
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Member ${member.name} (${member.memberCode}) has been restored to active directory.`,
      member: updated,
    };
  }

  async permanentDelete(id: string, user?: any) {
    const member = await this.prisma.member.findUnique({
      where: { id },
      include: {
        subscriptions: true,
        payments: true,
      },
    });

    if (!member) throw new NotFoundException('Member not found');

    if (!member.isArchived) {
      throw new BadRequestException(
        `Direct permanent deletion is prohibited. Member ${member.name} must first be moved to Archive. Permanent deletion can only be performed from the Archive section.`
      );
    }

    const adminName = user?.name || 'Admin';

    await this.prisma.$transaction(async (tx) => {
      // 1. Release any residual seats/lockers
      for (const sub of member.subscriptions) {
        if (sub.assignedSeatId) {
          await tx.seat.update({
            where: { id: sub.assignedSeatId },
            data: { status: 'AVAILABLE' },
          });
          await tx.seatAssignment.updateMany({
            where: { seatId: sub.assignedSeatId, subscriptionId: sub.id },
            data: { releasedAt: new Date() },
          });
        }
        if (sub.assignedLockerId) {
          await tx.locker.update({
            where: { id: sub.assignedLockerId },
            data: { status: 'AVAILABLE' },
          });
          await tx.lockerAssignment.updateMany({
            where: { lockerId: sub.assignedLockerId, subscriptionId: sub.id },
            data: { releasedAt: new Date() },
          });
        }
      }

      // 2. Delete related records safely
      await tx.attendance.deleteMany({ where: { memberId: id } });
      await tx.paymentVerification.deleteMany({ where: { memberId: id } });

      const paymentIds = member.payments.map((p) => p.id);
      if (paymentIds.length > 0) {
        await tx.paymentTransaction.deleteMany({ where: { paymentId: { in: paymentIds } } });
        await tx.payment.deleteMany({ where: { memberId: id } });
      }

      const subIds = member.subscriptions.map((s) => s.id);
      if (subIds.length > 0) {
        await tx.seatAssignment.deleteMany({ where: { subscriptionId: { in: subIds } } });
        await tx.lockerAssignment.deleteMany({ where: { subscriptionId: { in: subIds } } });
        await tx.subscription.deleteMany({ where: { memberId: id } });
      }

      await tx.complaint.deleteMany({ where: { memberId: id } });
      await tx.feedback.deleteMany({ where: { memberId: id } });

      // 3. Delete member
      await tx.member.delete({ where: { id } });

      // 4. Audit Log
      try {
        await tx.auditLog.create({
          data: {
            tenantId: member.tenantId,
            userId: user?.id || null,
            branchId: member.branchId,
            action: 'PERMANENT_DELETE_MEMBER',
            entity: 'Member',
            entityId: id,
            metadata: JSON.stringify({
              memberCode: member.memberCode,
              name: member.name,
              deletedBy: adminName,
              deletedAt: new Date().toISOString(),
            }),
          },
        });
      } catch (_) {}
    });

    return {
      success: true,
      message: `Member ${member.name} (${member.memberCode}) and all associated records have been permanently deleted from Archive.`,
    };
  }

  async remove(id: string, user?: any) {
    return this.archiveMember(id, user);
  }

  async getPayments(id: string) {
    return this.prisma.payment.findMany({ where: { memberId: id }, orderBy: { createdAt: 'desc' } });
  }

  async getAttendance(id: string) {
    return this.prisma.attendance.findMany({ where: { memberId: id }, orderBy: { checkIn: 'desc' } });
  }

  async getSubscriptions(id: string) {
    return this.prisma.subscription.findMany({
      where: { memberId: id },
      include: { plan: true, seat: true, locker: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
