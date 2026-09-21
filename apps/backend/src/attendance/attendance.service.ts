import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MarkAttendanceDto } from './dto/mark-attendance.dto';

@Injectable()
export class AttendanceService {
  constructor(private prisma: PrismaService) {}

  async markAttendance(dto: MarkAttendanceDto, method: 'MANUAL' | 'QR') {
    const member = await this.prisma.member.findUnique({
      where: { id: dto.memberId },
    });

    if (!member) {
      throw new NotFoundException('Member not found');
    }

    if (member.branchId !== dto.branchId) {
      throw new BadRequestException('Member does not belong to this branch');
    }

    // Check active subscription
    const activeSub = await this.prisma.subscription.findFirst({
      where: {
        memberId: member.id,
        status: 'ACTIVE',
        endDate: { gte: new Date() },
      },
    });

    if (!activeSub) {
      throw new BadRequestException('Member does not have an active subscription');
    }

    // Find today's latest check-in without a checkout
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const openAttendance = await this.prisma.attendance.findFirst({
      where: {
        memberId: member.id,
        branchId: dto.branchId,
        checkIn: { gte: today },
        checkOut: null,
      },
      orderBy: { checkIn: 'desc' },
    });

    if (openAttendance) {
      // Perform Check-Out
      return this.prisma.attendance.update({
        where: { id: openAttendance.id },
        data: { checkOut: new Date() },
      });
    }

    // Perform Check-In
    return this.prisma.attendance.create({
      data: {
        tenantId: member.tenantId,
        memberId: member.id,
        branchId: dto.branchId,
        method,
      },
    });
  }

  async getTodayAttendance(branchId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const records = await this.prisma.attendance.findMany({
      where: {
        branchId,
        checkIn: { gte: today },
      },
      include: {
        member: {
          select: {
            id: true,
            name: true,
            memberCode: true,
            phone: true,
          },
        },
      },
      orderBy: { checkIn: 'desc' },
    });

    return records.map((r) => ({
      id: r.id,
      memberId: r.memberId,
      memberName: r.member?.name || 'Student',
      memberCode: r.member?.memberCode || 'CML-948122',
      checkInTime: r.checkIn,
      checkOutTime: r.checkOut,
      method: r.method,
    }));
  }

  async getAttendanceHistory(branchId: string, limit = 50) {
    const records = await this.prisma.attendance.findMany({
      where: { branchId },
      include: {
        member: {
          select: {
            name: true,
            memberCode: true,
          },
        },
      },
      take: limit,
      orderBy: { checkIn: 'desc' },
    });

    return records.map((r) => ({
      id: r.id,
      memberId: r.memberId,
      memberName: r.member?.name || 'Student',
      memberCode: r.member?.memberCode || 'CML-948122',
      checkInTime: r.checkIn,
      checkOutTime: r.checkOut,
      method: r.method,
    }));
  }
}
