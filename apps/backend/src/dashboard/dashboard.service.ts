import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats(user: any, branchId?: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const endOfToday = new Date();
    endOfToday.setHours(23, 59, 59, 999);

    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const firstDayOfPrevMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
    const lastDayOfPrevMonth = new Date(today.getFullYear(), today.getMonth(), 0, 23, 59, 59, 999);

    const tenantFilter = user?.tenantId ? { tenantId: user.tenantId } : {};
    const branchFilter = branchId ? { branchId } : {};
    const memberRelFilter = branchId ? { member: { branchId } } : {};

    // Execute parallel queries with strict tenant filtering
    const [
      liveMembersCount,
      totalMembersCount,
      expiredMembershipsCount,
      expiring1to3,
      expiring4to7,
      expiring8to15,
      todayPayments,
      monthPayments,
      prevMonthPayments,
      todayCheckIns,
      pendingPayments,
      todayExpenses,
      todayFollowups,
      totalEnquiries,
      totalSeats,
      occupiedSeats,
      members,
    ] = await this.prisma.$transaction([
      // 1. liveMembers (active subscriptions today)
      this.prisma.subscription.count({
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'ACTIVE',
          startDate: { lte: today },
          endDate: { gte: today },
        },
      }),
      // 2. totalMembers
      this.prisma.member.count({
        where: { ...tenantFilter, ...branchFilter, isActive: true },
      }),
      // 3. expiredMemberships
      this.prisma.subscription.count({
        where: { ...tenantFilter, ...memberRelFilter, status: 'EXPIRED' },
      }),
      // 4. expiringIn1to3Days
      this.prisma.subscription.count({
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'ACTIVE',
          endDate: {
            gte: new Date(today.getTime() + 1 * 24 * 60 * 60 * 1000),
            lte: new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000),
          },
        },
      }),
      // 5. expiringIn4to7Days
      this.prisma.subscription.count({
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'ACTIVE',
          endDate: {
            gt: new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000),
            lte: new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000),
          },
        },
      }),
      // 6. expiringIn8to15Days
      this.prisma.subscription.count({
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'ACTIVE',
          endDate: {
            gt: new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000),
            lte: new Date(today.getTime() + 15 * 24 * 60 * 60 * 1000),
          },
        },
      }),
      // 7. todayCollection
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'PAID',
          paidAt: { gte: today, lte: endOfToday },
        },
      }),
      // 8. monthCollection
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'PAID',
          paidAt: { gte: firstDayOfMonth },
        },
      }),
      // 9. prevMonthCollection
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'PAID',
          paidAt: { gte: firstDayOfPrevMonth, lte: lastDayOfPrevMonth },
        },
      }),
      // 10. todayCheckIns
      this.prisma.attendance.count({
        where: {
          ...tenantFilter,
          ...branchFilter,
          checkIn: { gte: today, lte: endOfToday },
        },
      }),
      // 11. dueAmount
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          ...tenantFilter,
          ...memberRelFilter,
          status: 'PENDING',
        },
      }),
      // 12. todayExpenses
      this.prisma.expense.aggregate({
        _sum: { amount: true },
        where: {
          ...tenantFilter,
          ...branchFilter,
          date: { gte: today, lte: endOfToday },
        },
      }),
      // 13. todayFollowups
      this.prisma.enquiry.count({
        where: {
          ...tenantFilter,
          ...branchFilter,
          followUpDate: { gte: today, lte: endOfToday },
        },
      }),
      // 14. totalEnquiries
      this.prisma.enquiry.count({
        where: { ...tenantFilter, ...branchFilter },
      }),
      // 15. totalSeats
      this.prisma.seat.count({
        where: { ...tenantFilter, ...branchFilter },
      }),
      // 16. occupiedSeats
      this.prisma.seat.count({
        where: { ...tenantFilter, ...branchFilter, status: 'OCCUPIED' },
      }),
      // 17. members for birthdays
      this.prisma.member.findMany({
        where: { ...tenantFilter, ...branchFilter, isActive: true, dob: { not: null } },
        select: { id: true, dob: true },
      }),
    ]);

    const currentMonthDay = `${today.getMonth() + 1}-${today.getDate()}`;
    const todayBirthdays = members.filter((m) => {
      const dob = m.dob;
      if (!dob) return false;
      return `${dob.getMonth() + 1}-${dob.getDate()}` === currentMonthDay;
    }).length;

    const availableSeats = totalSeats - occupiedSeats;

    return {
      liveMembers: liveMembersCount,
      totalMembers: totalMembersCount,
      expiredMemberships: expiredMembershipsCount,
      expiringIn1to3Days: expiring1to3,
      expiringIn4to7Days: expiring4to7,
      expiringIn8to15Days: expiring8to15,
      todayCollection: todayPayments._sum.amount || 0,
      monthCollection: monthPayments._sum.amount || 0,
      prevMonthCollection: prevMonthPayments._sum.amount || 0,
      todayCheckIns,
      dueAmount: pendingPayments._sum.amount || 0,
      todayExpenses: todayExpenses._sum.amount || 0,
      todayFollowups,
      totalEnquiries,
      todayBirthdays,
      occupiedSeats,
      totalSeats,
      availableSeats,
    };
  }
}
