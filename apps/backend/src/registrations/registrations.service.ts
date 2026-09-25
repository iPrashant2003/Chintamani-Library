import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  QueryRegistrationsDto,
  ApproveRegistrationDto,
  RejectRegistrationDto,
  AssignSeatDto,
} from './dto/registrations.dto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class RegistrationsService {
  constructor(private readonly prisma: PrismaService) {}

  private generateMemberCode(prefix = 'LIB'): string {
    return `${prefix}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
  }

  async findAll(query: QueryRegistrationsDto) {
    const { status = 'PENDING', branchId, search, page = '1', limit = '20' } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (status && status !== 'ALL') {
      where.status = status;
    }
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
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
        { applicationId: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.memberRegistration.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          plan: true,
          reservedSeat: true,
          branch: { select: { id: true, name: true } },
        },
        orderBy: { submittedAt: 'desc' },
      }),
      this.prisma.memberRegistration.count({ where }),
    ]);

    return { data, total, page: pageNum, limit: limitNum };
  }

  async findOne(id: string) {
    const registration = await this.prisma.memberRegistration.findUnique({
      where: { id },
      include: {
        plan: true,
        reservedSeat: true,
        branch: { select: { id: true, name: true, phone: true } },
      },
    });

    if (!registration) {
      throw new NotFoundException('Registration application not found');
    }

    // Also fetch available seats in this branch for quick allocation
    const availableSeats = await this.prisma.seat.findMany({
      where: { branchId: registration.branchId, status: 'AVAILABLE' },
      orderBy: [{ floor: 'asc' }, { seatNumber: 'asc' }],
      select: { id: true, seatNumber: true, floor: true, status: true },
    });

    return { ...registration, availableSeats };
  }

  async assignSeat(id: string, dto: AssignSeatDto, adminUser?: any) {
    const reg = await this.prisma.memberRegistration.findUnique({
      where: { id },
      include: { branch: true },
    });

    if (!reg) throw new NotFoundException('Registration application not found');
    if (reg.status !== 'PENDING') {
      throw new BadRequestException(`Cannot assign seat to a ${reg.status} application`);
    }

    // Validate new seat exists and is AVAILABLE
    const newSeat = await this.prisma.seat.findUnique({
      where: { id: dto.seatId },
    });

    if (!newSeat) throw new NotFoundException('Seat not found');
    if (newSeat.branchId !== reg.branchId) {
      throw new BadRequestException('Seat belongs to a different branch');
    }
    if (newSeat.status !== 'AVAILABLE') {
      throw new BadRequestException(
        `Seat ${newSeat.seatNumber} is currently ${newSeat.status}. Only AVAILABLE seats can be allocated.`
      );
    }

    // If an existing seat was reserved, release it back to AVAILABLE
    if (reg.reservedSeatId && reg.reservedSeatId !== newSeat.id) {
      await this.prisma.seat.update({
        where: { id: reg.reservedSeatId },
        data: { status: 'AVAILABLE' },
      });
    }

    // Reserve new seat
    await this.prisma.seat.update({
      where: { id: newSeat.id },
      data: { status: 'RESERVED' },
    });

    // Link seat to registration
    const updated = await this.prisma.memberRegistration.update({
      where: { id },
      data: { reservedSeatId: newSeat.id },
      include: { reservedSeat: true },
    });

    // Audit Log
    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: reg.tenantId,
          userId: adminUser?.id || null,
          branchId: reg.branchId,
          action: 'ASSIGN_SEAT_REGISTRATION',
          entity: 'MemberRegistration',
          entityId: reg.id,
          metadata: JSON.stringify({
            applicationId: reg.applicationId,
            seatNumber: newSeat.seatNumber,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Seat ${newSeat.seatNumber} reserved for applicant ${reg.name}`,
      reservedSeat: updated.reservedSeat,
    };
  }

  async approve(id: string, dto: ApproveRegistrationDto, adminUser?: any) {
    const reg = await this.prisma.memberRegistration.findUnique({
      where: { id },
      include: { plan: true, reservedSeat: true, branch: { include: { tenant: true } } },
    });

    if (!reg) throw new NotFoundException('Registration application not found');
    if (reg.status !== 'PENDING') {
      throw new BadRequestException(`Application is already ${reg.status}`);
    }

    let finalSeatId = reg.reservedSeatId;

    // If admin passed a seatId during approval, assign that seat
    if (dto.seatId && dto.seatId !== reg.reservedSeatId) {
      const seat = await this.prisma.seat.findUnique({ where: { id: dto.seatId } });
      if (!seat || seat.status !== 'AVAILABLE') {
        throw new BadRequestException(
          `Selected seat is not available (currently ${seat?.status || 'Unknown'})`
        );
      }

      // Release old reserved seat if any
      if (reg.reservedSeatId) {
        await this.prisma.seat.update({
          where: { id: reg.reservedSeatId },
          data: { status: 'AVAILABLE' },
        });
      }

      finalSeatId = seat.id;
    }

    const tenantCode = reg.branch.tenant.code || 'LIB';
    const memberCode = this.generateMemberCode(tenantCode);

    let academicData: any = {};
    try {
      if (reg.academicInfo) academicData = JSON.parse(reg.academicInfo);
    } catch (_) {}
    if (reg.gender) academicData.gender = reg.gender;
    if (reg.aadhaarNumber) academicData.aadhaar = reg.aadhaarNumber;
    if (reg.emergencyContact) academicData.emergencyContact = reg.emergencyContact;
    if (reg.photoUrl) academicData.photoUrl = reg.photoUrl;

    // 1. Create Member
    const member = await this.prisma.member.create({
      data: {
        tenantId: reg.tenantId,
        branchId: reg.branchId,
        memberCode,
        name: reg.name,
        phone: reg.phone,
        email: reg.email,
        dob: reg.dob,
        address: reg.address,
        academicInfo: JSON.stringify(academicData),
        isActive: true, // Activated upon approval!
        registrationId: reg.id,
        portalAccess: true,
      },
    });

    // 2. Create Subscription if plan selected
    let subscription: any = null;
    if (reg.plan) {
      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + reg.plan.durationDays);

      subscription = await this.prisma.subscription.create({
        data: {
          tenantId: reg.tenantId,
          memberId: member.id,
          planId: reg.plan.id,
          startDate,
          endDate,
          status: 'ACTIVE',
          assignedSeatId: finalSeatId || null,
        },
      });

      // 3. Mark Seat as OCCUPIED and create SeatAssignment
      if (finalSeatId) {
        await this.prisma.seat.update({
          where: { id: finalSeatId },
          data: { status: 'OCCUPIED' },
        });

        await this.prisma.seatAssignment.create({
          data: {
            seatId: finalSeatId,
            subscriptionId: subscription.id,
          },
        });
      }
    }

    // 4. Update Registration status to APPROVED
    await this.prisma.memberRegistration.update({
      where: { id },
      data: {
        status: 'APPROVED',
        memberId: member.id,
        reservedSeatId: finalSeatId || null,
        reviewedBy: adminUser?.name || 'Admin',
        reviewedAt: new Date(),
      },
    });

    // Audit Log
    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: reg.tenantId,
          userId: adminUser?.id || null,
          branchId: reg.branchId,
          action: 'APPROVE_REGISTRATION',
          entity: 'MemberRegistration',
          entityId: reg.id,
          metadata: JSON.stringify({
            applicationId: reg.applicationId,
            memberId: member.id,
            memberCode: member.memberCode,
            seatId: finalSeatId,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Registration ${reg.applicationId} approved. Member ${member.name} (${member.memberCode}) created.`,
      member: {
        id: member.id,
        name: member.name,
        memberCode: member.memberCode,
        seatId: finalSeatId,
      },
    };
  }

  async reject(id: string, dto: RejectRegistrationDto, adminUser?: any) {
    const reg = await this.prisma.memberRegistration.findUnique({
      where: { id },
      include: { reservedSeat: true },
    });

    if (!reg) throw new NotFoundException('Registration application not found');
    if (reg.status !== 'PENDING') {
      throw new BadRequestException(`Application is already ${reg.status}`);
    }

    // CRITICAL: Release reserved seat back to AVAILABLE immediately
    if (reg.reservedSeatId) {
      await this.prisma.seat.update({
        where: { id: reg.reservedSeatId },
        data: { status: 'AVAILABLE' },
      });
    }

    // Update status to REJECTED
    await this.prisma.memberRegistration.update({
      where: { id },
      data: {
        status: 'REJECTED',
        rejectionReason: dto.reason || 'Application requirements not met',
        reviewedBy: adminUser?.name || 'Admin',
        reviewedAt: new Date(),
      },
    });

    // Audit Log
    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: reg.tenantId,
          userId: adminUser?.id || null,
          branchId: reg.branchId,
          action: 'REJECT_REGISTRATION',
          entity: 'MemberRegistration',
          entityId: reg.id,
          metadata: JSON.stringify({
            applicationId: reg.applicationId,
            reason: dto.reason,
            releasedSeat: reg.reservedSeat?.seatNumber,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Registration ${reg.applicationId} rejected.${
        reg.reservedSeat ? ` Seat ${reg.reservedSeat.seatNumber} has been released.` : ''
      }`,
    };
  }

  async getPendingCount(branchId?: string) {
    const where: any = { status: 'PENDING' };
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
    }
    return this.prisma.memberRegistration.count({ where });
  }
}
