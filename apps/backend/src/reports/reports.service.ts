import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async getMemberReport(branchId: string, status?: string) {
    const where: any = { branchId };
    if (status === 'active') where.isActive = true;
    if (status === 'inactive') where.isActive = false;

    const members = await this.prisma.member.findMany({
      where,
      include: {
        subscriptions: {
          orderBy: { endDate: 'desc' },
          take: 1,
          include: { plan: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    return members.map((m) => ({
      memberCode: m.memberCode,
      name: m.name,
      phone: m.phone,
      plan: m.subscriptions[0]?.plan?.name || 'N/A',
      startDate: m.subscriptions[0]?.startDate || null,
      endDate: m.subscriptions[0]?.endDate || null,
      status: m.subscriptions[0]?.status || 'NO_SUBSCRIPTION',
      isActive: m.isActive,
    }));
  }

  async getCollectionReport(branchId: string, dateFrom?: string, dateTo?: string) {
    const where: any = { status: 'PAID', member: { branchId } };
    if (dateFrom || dateTo) {
      where.paidAt = {};
      if (dateFrom) where.paidAt.gte = new Date(dateFrom);
      if (dateTo) where.paidAt.lte = new Date(dateTo);
    }

    const payments = await this.prisma.payment.findMany({
      where,
      include: { member: { select: { name: true, memberCode: true } } },
      orderBy: { paidAt: 'desc' },
    });

    const total = payments.reduce((sum, p) => sum + p.amount, 0);
    const byMethod: Record<string, number> = {};
    payments.forEach((p) => {
      byMethod[p.method] = (byMethod[p.method] || 0) + p.amount;
    });

    return { payments, total, count: payments.length, byMethod };
  }

  async getDueReport(branchId: string) {
    const members = await this.prisma.member.findMany({
      where: { branchId, isActive: true },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { plan: true },
          take: 1,
        },
        payments: {
          where: { status: 'PENDING' },
        },
      },
    });

    return members
      .filter((m) => m.payments.length > 0)
      .map((m) => ({
        memberCode: m.memberCode,
        name: m.name,
        phone: m.phone,
        plan: m.subscriptions[0]?.plan?.name || 'N/A',
        dueAmount: m.payments.reduce((sum, p) => sum + p.amount, 0),
        pendingPayments: m.payments.length,
      }));
  }

  async getAttendanceReport(branchId: string, dateFrom?: string, dateTo?: string) {
    const where: any = { branchId };
    if (dateFrom || dateTo) {
      where.checkIn = {};
      if (dateFrom) where.checkIn.gte = new Date(dateFrom);
      if (dateTo) where.checkIn.lte = new Date(dateTo);
    }

    const records = await this.prisma.attendance.findMany({
      where,
      include: { member: { select: { name: true, memberCode: true } } },
      orderBy: { checkIn: 'desc' },
    });

    const uniqueMembers = new Set(records.map((r) => r.memberId)).size;
    return { records, totalCheckIns: records.length, uniqueMembers };
  }

  async getExpenseReport(branchId: string, month?: number, year?: number) {
    const now = new Date();
    const m = month || now.getMonth() + 1;
    const y = year || now.getFullYear();
    const start = new Date(y, m - 1, 1);
    const end = new Date(y, m, 0, 23, 59, 59);

    const expenses = await this.prisma.expense.findMany({
      where: { branchId, date: { gte: start, lte: end } },
      orderBy: { date: 'desc' },
    });

    const byCategory: Record<string, number> = {};
    expenses.forEach((e) => {
      byCategory[e.category] = (byCategory[e.category] || 0) + e.amount;
    });
    const total = expenses.reduce((sum, e) => sum + e.amount, 0);

    return { expenses, byCategory, total, month: m, year: y };
  }

  async getExpiryReport(branchId: string, daysAhead = 15) {
    const now = new Date();
    const future = new Date();
    future.setDate(now.getDate() + daysAhead);

    const subscriptions = await this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        endDate: { gte: now, lte: future },
        member: { branchId },
      },
      include: {
        member: { select: { name: true, memberCode: true, phone: true } },
        plan: { select: { name: true } },
      },
      orderBy: { endDate: 'asc' },
    });

    return subscriptions.map((s) => ({
      memberCode: s.member.memberCode,
      name: s.member.name,
      phone: s.member.phone,
      plan: s.plan.name,
      endDate: s.endDate,
      daysRemaining: Math.ceil((s.endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)),
    }));
  }

  async getSeatOccupancyReport(branchId: string) {
    const seats = await this.prisma.seat.findMany({
      where: { branchId },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: {
            member: { select: { name: true, memberCode: true } },
            plan: { select: { name: true } },
          },
          take: 1,
        },
      },
      orderBy: [{ floor: 'asc' }, { seatNumber: 'asc' }],
    });

    const total = seats.length;
    const occupied = seats.filter((s) => s.status === 'OCCUPIED').length;
    const available = seats.filter((s) => s.status === 'AVAILABLE').length;
    const maintenance = seats.filter((s) => s.status === 'MAINTENANCE').length;

    return { seats, total, occupied, available, maintenance, occupancyRate: total > 0 ? Math.round((occupied / total) * 100) : 0 };
  }
}
