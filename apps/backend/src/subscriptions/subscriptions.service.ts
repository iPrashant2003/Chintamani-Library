import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { RenewSubscriptionDto } from './dto/renew-subscription.dto';

@Injectable()
export class SubscriptionsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateSubscriptionDto) {
    return this.prisma.$transaction(async (tx) => {
      const plan = await tx.membershipPlan.findUniqueOrThrow({ where: { id: dto.planId } });
      const startDate = dto.startDate ? new Date(dto.startDate) : new Date();
      const endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + plan.durationDays);

      const subscription = await tx.subscription.create({
        data: {
          tenantId: plan.tenantId,
          memberId: dto.memberId,
          planId: dto.planId,
          startDate,
          endDate,
          status: 'ACTIVE',
          assignedSeatId: dto.seatId || null,
          assignedLockerId: dto.lockerId || null,
        },
      });

      if (dto.seatId) {
        await tx.seat.update({ where: { id: dto.seatId }, data: { status: 'OCCUPIED' } });
        await tx.seatAssignment.create({ data: { seatId: dto.seatId, subscriptionId: subscription.id } });
      }
      if (dto.lockerId) {
        await tx.locker.update({ where: { id: dto.lockerId }, data: { status: 'OCCUPIED' } });
        await tx.lockerAssignment.create({ data: { lockerId: dto.lockerId, subscriptionId: subscription.id } });
      }
      if (dto.amount && dto.amount > 0) {
        const method = (dto.paymentMethod === 'BANK_TRANSFER' ? 'BANK' : (dto.paymentMethod || 'CASH')) as any;
        await tx.payment.create({
          data: {
            tenantId: plan.tenantId,
            memberId: dto.memberId,
            amount: dto.amount,
            method,
            status: 'PAID',
            paidAt: new Date(),
            txnRef: dto.txnRef,
          },
        });
      }
      return subscription;
    });
  }

  async findOne(id: string) {
    const sub = await this.prisma.subscription.findUnique({
      where: { id },
      include: { plan: true, member: true, seat: true, locker: true }
    });
    if (!sub) throw new NotFoundException('Subscription not found');
    return sub;
  }

  async renew(id: string, dto: RenewSubscriptionDto) {
    return this.prisma.$transaction(async (tx) => {
      const sub = await tx.subscription.findUniqueOrThrow({ where: { id }, include: { plan: true } });
      const newEndDate = new Date(sub.endDate);
      newEndDate.setDate(newEndDate.getDate() + sub.plan.durationDays);
      return tx.subscription.update({ where: { id }, data: { endDate: newEndDate, status: 'ACTIVE' } });
    });
  }

  async cancel(id: string) {
    return this.prisma.$transaction(async (tx) => {
      const sub = await tx.subscription.findUniqueOrThrow({ where: { id } });
      if (sub.assignedSeatId) await tx.seat.update({ where: { id: sub.assignedSeatId }, data: { status: 'AVAILABLE' } });
      if (sub.assignedLockerId) await tx.locker.update({ where: { id: sub.assignedLockerId }, data: { status: 'AVAILABLE' } });
      return tx.subscription.update({ where: { id }, data: { status: 'CANCELLED' } });
    });
  }
}
