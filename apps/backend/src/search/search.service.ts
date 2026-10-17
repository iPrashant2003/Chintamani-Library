import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class SearchService {
  constructor(private readonly prisma: PrismaService) {}

  async search(rawQuery: string, branchId?: string) {
    const q = (rawQuery || '').trim();
    if (!q) {
      return {
        query: '',
        members: [],
        seats: [],
        lockers: [],
        complaints: [],
        registrations: [],
        notifications: [],
      };
    }

    let resolvedBranchId = branchId;
    if (branchId) {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        resolvedBranchId = branchInfo.id;
      }
    }

    const validLockerNumbers = [
      'L01', 'L02', 'L03', 'L04', 'L05', 'L06', 'L07', 'L08', 'L09',
      'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7', 'L8', 'L9',
    ];

    const [members, seats, lockers, complaints, registrations, notifications] = await Promise.all([
      this.prisma.member.findMany({
        where: {
          ...(resolvedBranchId && { branchId: resolvedBranchId }),
          OR: [
            { name: { contains: q, mode: 'insensitive' } },
            { phone: { contains: q } },
            { memberCode: { contains: q, mode: 'insensitive' } },
            { email: { contains: q, mode: 'insensitive' } },
          ],
        },
        take: 15,
        include: {
          subscriptions: {
            where: { status: 'ACTIVE' },
            include: { seat: true, plan: true },
            take: 1,
          },
        },
        orderBy: { name: 'asc' },
      }),

      this.prisma.seat.findMany({
        where: {
          ...(resolvedBranchId && { branchId: resolvedBranchId }),
          seatNumber: { contains: q, mode: 'insensitive' },
        },
        take: 10,
        select: { id: true, seatNumber: true, floor: true, status: true, branchId: true },
        orderBy: { seatNumber: 'asc' },
      }),

      this.prisma.locker.findMany({
        where: {
          ...(resolvedBranchId && { branchId: resolvedBranchId }),
          lockerNumber: { in: validLockerNumbers, contains: q, mode: 'insensitive' },
        },
        take: 9,
        include: {
          subscriptions: {
            where: { status: 'ACTIVE' },
            include: { member: { select: { id: true, name: true, memberCode: true } } },
            take: 1,
          },
        },
        orderBy: { lockerNumber: 'asc' },
      }),

      this.prisma.complaint.findMany({
        where: {
          ...(resolvedBranchId && { branchId: resolvedBranchId }),
          OR: [
            { complaintId: { contains: q, mode: 'insensitive' } },
            { memberName: { contains: q, mode: 'insensitive' } },
            { description: { contains: q, mode: 'insensitive' } },
            { category: { contains: q, mode: 'insensitive' } },
          ],
        },
        take: 5,
        orderBy: { createdAt: 'desc' },
      }),

      this.prisma.memberRegistration.findMany({
        where: {
          ...(resolvedBranchId && { branchId: resolvedBranchId }),
          OR: [
            { applicationId: { contains: q, mode: 'insensitive' } },
            { name: { contains: q, mode: 'insensitive' } },
            { phone: { contains: q } },
          ],
        },
        take: 5,
        orderBy: { submittedAt: 'desc' },
      }),

      this.prisma.notification.findMany({
        where: {
          OR: [
            { title: { contains: q, mode: 'insensitive' } },
            { body: { contains: q, mode: 'insensitive' } },
          ],
        },
        take: 5,
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    // Format locker with authoritative Unassigned/Assigned status
    const formattedLockers = lockers.map((locker) => {
      const activeSub = locker.subscriptions[0];
      const isAssigned = !!activeSub;
      return {
        id: locker.id,
        lockerNumber: locker.lockerNumber,
        status: isAssigned ? 'OCCUPIED' : 'AVAILABLE',
        currentMemberName: activeSub?.member?.name || null,
        currentMemberId: activeSub?.member?.id || null,
        branchId: locker.branchId,
      };
    });

    return {
      query: q,
      members,
      seats,
      lockers: formattedLockers,
      complaints,
      registrations,
      notifications,
    };
  }
}
