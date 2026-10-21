import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import * as path from 'path';

const execAsync = promisify(exec);

@Injectable()
export class BackupService {
  private readonly logger = new Logger(BackupService.name);
  private readonly backupDir = path.resolve(process.cwd(), 'backups');

  constructor(private readonly prisma: PrismaService) {
    if (!fs.existsSync(this.backupDir)) {
      fs.mkdirSync(this.backupDir, { recursive: true });
    }
  }

  async performBackup(triggerType: 'AUTOMATIC' | 'MANUAL' = 'AUTOMATIC', user?: any) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupName = `backup_${timestamp}`;
    const sqlFilePath = path.join(this.backupDir, `${backupName}.sql`);
    const jsonFilePath = path.join(this.backupDir, `${backupName}.json`);

    this.logger.log(`Starting ${triggerType} database backup: ${backupName}`);

    // Create initial BackupLog entry
    const logEntry = await this.prisma.backupLog.create({
      data: {
        backupName,
        filePath: sqlFilePath,
        triggerType,
        status: 'RUNNING',
      },
    });

    try {
      // 1. Run SQL Dump via WSL PostgreSQL pg_dump
      const dumpCmd = `wsl -u root -d Ubuntu -e bash -c "PGPASSWORD=chintamani_secret pg_dump -U chintamani -h localhost chintamani_library"`;
      const { stdout: sqlDump } = await execAsync(dumpCmd, {
        maxBuffer: 100 * 1024 * 1024, // 100MB buffer
      });

      fs.writeFileSync(sqlFilePath, sqlDump, 'utf8');
      const sqlStat = fs.statSync(sqlFilePath);

      // 2. Export Structured JSON Snapshot of all core tables
      const [
        tenants,
        branches,
        users,
        members,
        plans,
        subscriptions,
        seats,
        seatAssignments,
        lockers,
        lockerAssignments,
        payments,
        paymentVerifications,
        complaints,
        attendances,
        auditLogs,
      ] = await Promise.all([
        this.prisma.tenant.findMany(),
        this.prisma.branch.findMany(),
        this.prisma.user.findMany({ select: { id: true, name: true, email: true, role: true, phone: true, isActive: true, createdAt: true } }),
        this.prisma.member.findMany(),
        this.prisma.membershipPlan.findMany(),
        this.prisma.subscription.findMany(),
        this.prisma.seat.findMany(),
        this.prisma.seatAssignment.findMany(),
        this.prisma.locker.findMany(),
        this.prisma.lockerAssignment.findMany(),
        this.prisma.payment.findMany(),
        this.prisma.paymentVerification.findMany(),
        this.prisma.complaint.findMany(),
        this.prisma.attendance.findMany(),
        this.prisma.auditLog.findMany({ take: 5000, orderBy: { createdAt: 'desc' } }),
      ]);

      const tableCounts = {
        tenants: tenants.length,
        branches: branches.length,
        users: users.length,
        members: members.length,
        plans: plans.length,
        subscriptions: subscriptions.length,
        seats: seats.length,
        seatAssignments: seatAssignments.length,
        lockers: lockers.length,
        lockerAssignments: lockerAssignments.length,
        payments: payments.length,
        paymentVerifications: paymentVerifications.length,
        complaints: complaints.length,
        attendances: attendances.length,
        auditLogs: auditLogs.length,
      };

      const totalRecords = Object.values(tableCounts).reduce((a, b) => a + b, 0);

      const jsonPayload = {
        metadata: {
          backupName,
          createdAt: new Date().toISOString(),
          triggerType,
          tableCounts,
          totalRecords,
          createdBy: user?.name || 'System Scheduler',
        },
        data: {
          tenants,
          branches,
          users,
          members,
          plans,
          subscriptions,
          seats,
          seatAssignments,
          lockers,
          lockerAssignments,
          payments,
          paymentVerifications,
          complaints,
          attendances,
          auditLogs,
        },
      };

      fs.writeFileSync(jsonFilePath, JSON.stringify(jsonPayload, null, 2), 'utf8');
      const jsonStat = fs.statSync(jsonFilePath);
      const totalBytes = sqlStat.size + jsonStat.size;

      // 3. Update BackupLog entry
      const updatedLog = await this.prisma.backupLog.update({
        where: { id: logEntry.id },
        data: {
          status: 'SUCCESS',
          fileSize: totalBytes,
          itemCount: totalRecords,
          completedAt: new Date(),
          details: JSON.stringify({
            sqlFile: `${backupName}.sql`,
            jsonFile: `${backupName}.json`,
            sqlSize: sqlStat.size,
            jsonSize: jsonStat.size,
            tableCounts,
          }),
        },
      });

      this.logger.log(
        `Backup completed successfully: ${backupName} (${(totalBytes / 1024).toFixed(1)} KB, ${totalRecords} records)`
      );

      // 4. Prune older backups keeping last 30 days
      this.cleanupOldBackups(30);

      return {
        success: true,
        backup: updatedLog,
        tableCounts,
        totalRecords,
        fileSizeKb: (totalBytes / 1024).toFixed(1),
      };
    } catch (err: any) {
      this.logger.error(`Backup failed: ${err.message}`, err.stack);
      await this.prisma.backupLog.update({
        where: { id: logEntry.id },
        data: {
          status: 'FAILED',
          errorMsg: err.message,
          completedAt: new Date(),
        },
      });
      throw err;
    }
  }

  async findAll(page = 1, limit = 20) {
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    const [logs, total] = await Promise.all([
      this.prisma.backupLog.findMany({
        skip,
        take: limitNum,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.backupLog.count(),
    ]);

    return { data: logs, total, page: pageNum, limit: limitNum };
  }

  async getLatest() {
    const latest = await this.prisma.backupLog.findFirst({
      orderBy: { createdAt: 'desc' },
    });
    return latest;
  }

  private cleanupOldBackups(retentionDays = 30) {
    try {
      const files = fs.readdirSync(this.backupDir);
      const cutoff = Date.now() - retentionDays * 24 * 60 * 60 * 1000;

      for (const file of files) {
        if (!file.startsWith('backup_')) continue;
        const filePath = path.join(this.backupDir, file);
        const stat = fs.statSync(filePath);
        if (stat.mtimeMs < cutoff) {
          fs.unlinkSync(filePath);
          this.logger.log(`Pruned old backup file: ${file}`);
        }
      }
    } catch (err: any) {
      this.logger.warn(`Backup cleanup warning: ${err.message}`);
    }
  }
}
