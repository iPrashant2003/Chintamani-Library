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
}
