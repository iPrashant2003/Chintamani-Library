import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SearchService {
  constructor(private readonly prisma: PrismaService) {}

  async search(q: string, branchId: string) {
    const [members, seats, lockers] = await Promise.all([
      this.prisma.member.findMany({
        where: { 
          branchId, 
          OR: [
            { name: { contains: q, mode: 'insensitive' } }, 
            { phone: { contains: q } }, 
            { memberCode: { contains: q, mode: 'insensitive' } }
          ] 
        },
        take: 10, 
        select: { id: true, name: true, memberCode: true, phone: true, isActive: true } // adjust schema match
      }),
      this.prisma.seat.findMany({
        where: { branchId, seatNumber: { contains: q, mode: 'insensitive' } },
        take: 5, 
        select: { id: true, seatNumber: true, floor: true, status: true }
      }),
      this.prisma.locker.findMany({
        where: { branchId, lockerNumber: { contains: q, mode: 'insensitive' } },
        take: 5, 
        select: { id: true, lockerNumber: true, status: true }
      })
    ]);
    return { members, seats, lockers, query: q };
  }
}
