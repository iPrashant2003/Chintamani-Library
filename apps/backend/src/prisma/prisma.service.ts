import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    // DATABASE_URL is set as a cloud environment variable on Railway/Render/Neon
    super({
      log: process.env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
    });
  }

  async onModuleInit() {
    await this.$connect();
    this.logger.log('Database connected successfully');
    await this.ensureSchemaIntegrity();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Idempotent schema integrity check: guarantees all required columns and tables
   * exist in the active PostgreSQL database, preventing schema-drift crashes.
   * Executes statements individually to comply with PostgreSQL prepared statement rules.
   */
  async ensureSchemaIntegrity(): Promise<{ success: boolean; message: string }> {
    try {
      this.logger.log('[SchemaIntegrity] Verifying database schema columns and tables...');

      // 1. Member table critical columns
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "isArchived" BOOLEAN NOT NULL DEFAULT false;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "photoUrl" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "aadhaarNumber" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "aadhaarFrontUrl" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "aadhaarBackUrl" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "otherDocUrls" TEXT;`);
      await this.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS "Member_isArchived_idx" ON "Member"("isArchived");`);
      await this.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS "Member_branchId_isArchived_idx" ON "Member"("branchId", "isArchived");`);

      // 2. BackupLog table & indexes
      await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS "BackupLog" (
          "id"          TEXT NOT NULL,
          "tenantId"    TEXT,
          "backupName"  TEXT NOT NULL,
          "filePath"    TEXT NOT NULL,
          "fileSize"    INTEGER NOT NULL DEFAULT 0,
          "itemCount"   INTEGER NOT NULL DEFAULT 0,
          "status"      TEXT NOT NULL DEFAULT 'SUCCESS',
          "triggerType" TEXT NOT NULL DEFAULT 'AUTOMATIC',
          "details"     TEXT,
          "errorMsg"    TEXT,
          "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
          "completedAt" TIMESTAMP(3),
          "restoredAt"  TIMESTAMP(3),
          "restoredBy"  TEXT,
          CONSTRAINT "BackupLog_pkey" PRIMARY KEY ("id")
        )
      `);
      await this.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS "BackupLog_createdAt_idx" ON "BackupLog"("createdAt");`);
      await this.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS "BackupLog_status_idx" ON "BackupLog"("status");`);

      // 3. Complaint table columns
      await this.$executeRawUnsafe(`ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "internalNotes" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "statusHistory" TEXT;`);
      await this.$executeRawUnsafe(`ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "whatsappSentAt" TIMESTAMP(3);`);
      await this.$executeRawUnsafe(`ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "whatsappMessageId" TEXT;`);

      // 4. ComplaintStatus enum values (guarded via pg_enum check)
      const enumValues = ['SUBMITTED', 'UNDER_REVIEW', 'REJECTED', 'REOPENED', 'RESOLVED_PENDING'];
      for (const val of enumValues) {
        await this.$executeRawUnsafe(`
          DO $$
          BEGIN
              IF NOT EXISTS (
                  SELECT 1 FROM pg_enum
                  WHERE enumlabel = '${val}'
                    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
              ) THEN
                  ALTER TYPE "ComplaintStatus" ADD VALUE '${val}';
              END IF;
          END$$;
        `);
      }

      this.logger.log('[SchemaIntegrity] All schema tables and columns are verified and in sync.');
      return { success: true, message: 'Schema integrity check passed. All tables & columns are synchronized.' };
    } catch (err: any) {
      this.logger.error(`[SchemaIntegrity] Schema integrity check error: ${err?.message}`, err?.stack);
      return { success: false, message: `Schema integrity warning: ${err?.message}` };
    }
  }
}
