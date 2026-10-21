import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { BackupService } from '../backup/backup.service';

@Injectable()
export class SchedulerService {
  private readonly logger = new Logger(SchedulerService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly backupService: BackupService,
  ) {}

  // Daily automated backup at 02:00 AM IST (20:30 UTC)
  @Cron('30 20 * * *')
  async handleDailyBackup() {
    this.logger.log('Executing automated daily database backup...');
    try {
      await this.backupService.performBackup('AUTOMATIC');
      this.logger.log('Automated daily database backup finished successfully.');
    } catch (err: any) {
      this.logger.error(`Automated daily backup failed: ${err.message}`);
    }
  }

  // Seat & Subscription auto-expiry reconciliation: runs every hour & at midnight
  @Cron(CronExpression.EVERY_HOUR)
  async handleSubscriptionAndSeatReconciliation() {
    return this.reconcileSubscriptionsAndSeats();
  }

  async reconcileSubscriptionsAndSeats() {
    const now = new Date();
    this.logger.log(`Running subscription and seat vacancy reconciliation at ${now.toISOString()}...`);

    let expiredSubsCount = 0;
    let releasedSeatsCount = 0;
    let releasedLockersCount = 0;

    // 1. Find all ACTIVE subscriptions whose endDate has passed
    const expiredSubscriptions = await this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        endDate: { lt: now },
      },
      include: {
        member: true,
        seat: true,
        locker: true,
      },
    });

    for (const sub of expiredSubscriptions) {
      try {
        await this.prisma.$transaction(async (tx) => {
          // Release Seat if allocated
          if (sub.assignedSeatId) {
            await tx.seat.update({
              where: { id: sub.assignedSeatId },
              data: { status: 'AVAILABLE' },
            });
            await tx.seatAssignment.updateMany({
              where: { seatId: sub.assignedSeatId, subscriptionId: sub.id, releasedAt: null },
              data: { releasedAt: now },
            });
            releasedSeatsCount++;
          }

          // Release Locker if allocated
          if (sub.assignedLockerId) {
            await tx.locker.update({
              where: { id: sub.assignedLockerId },
              data: { status: 'AVAILABLE' },
            });
            await tx.lockerAssignment.updateMany({
              where: { lockerId: sub.assignedLockerId, subscriptionId: sub.id, releasedAt: null },
              data: { releasedAt: now },
            });
            releasedLockersCount++;
          }

          // Update Subscription Status to EXPIRED
          await tx.subscription.update({
            where: { id: sub.id },
            data: {
              status: 'EXPIRED',
              assignedSeatId: null,
              assignedLockerId: null,
            },
          });

          expiredSubsCount++;
        });
      } catch (subErr: any) {
        this.logger.warn(`Failed reconciling expired subscription ${sub.id}: ${subErr.message}`);
      }
    }

    // 2. Authoritative check: Find any seats marked OCCUPIED that don't have an ACTIVE, non-expired subscription
    const occupiedSeats = await this.prisma.seat.findMany({
      where: { status: 'OCCUPIED' },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE', endDate: { gte: now } },
          include: { member: true },
        },
      },
    });

    let orphanedSeatsFreed = 0;
    for (const seat of occupiedSeats) {
      const activeValidSub = seat.subscriptions.find((s) => s.member && s.member.isActive && !s.member.isArchived);
      if (!activeValidSub) {
        try {
          await this.prisma.$transaction([
            this.prisma.seat.update({
              where: { id: seat.id },
              data: { status: 'AVAILABLE' },
            }),
            this.prisma.seatAssignment.updateMany({
              where: { seatId: seat.id, releasedAt: null },
              data: { releasedAt: now },
            }),
          ]);
          orphanedSeatsFreed++;
        } catch (_) {}
      }
    }

    const summary = {
      reconciledAt: now.toISOString(),
      expiredSubsCount,
      releasedSeatsCount,
      releasedLockersCount,
      orphanedSeatsFreed,
    };

    this.logger.log(`Reconciliation finished: ${JSON.stringify(summary)}`);
    return summary;
  }
}
