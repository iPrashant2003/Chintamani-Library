-- Migration: add_archive_backup_complaint_fields
-- Adds isArchived/archivedAt/archivedBy to Member, creates BackupLog table,
-- adds new ComplaintStatus enum values, and adds new Complaint columns.
-- Required for v2.8.8+ features to work on production database.

-- ─── Member archive columns ───────────────────────────────────────────────────
ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "isArchived" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "archivedAt" TIMESTAMP(3);
ALTER TABLE "Member" ADD COLUMN IF NOT EXISTS "archivedBy" TEXT;

CREATE INDEX IF NOT EXISTS "Member_isArchived_idx" ON "Member"("isArchived");
CREATE INDEX IF NOT EXISTS "Member_branchId_isArchived_idx" ON "Member"("branchId", "isArchived");

-- ─── BackupLog table ──────────────────────────────────────────────────────────
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
);

CREATE INDEX IF NOT EXISTS "BackupLog_createdAt_idx" ON "BackupLog"("createdAt");
CREATE INDEX IF NOT EXISTS "BackupLog_status_idx"    ON "BackupLog"("status");

-- ─── ComplaintStatus enum new values ─────────────────────────────────────────
-- PostgreSQL does not support IF NOT EXISTS for ALTER TYPE ADD VALUE directly;
-- use DO block to guard each value safely.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'SUBMITTED'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
    ) THEN
        ALTER TYPE "ComplaintStatus" ADD VALUE 'SUBMITTED';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'UNDER_REVIEW'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
    ) THEN
        ALTER TYPE "ComplaintStatus" ADD VALUE 'UNDER_REVIEW';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'REJECTED'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
    ) THEN
        ALTER TYPE "ComplaintStatus" ADD VALUE 'REJECTED';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'REOPENED'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
    ) THEN
        ALTER TYPE "ComplaintStatus" ADD VALUE 'REOPENED';
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum
        WHERE enumlabel = 'RESOLVED_PENDING'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'ComplaintStatus')
    ) THEN
        ALTER TYPE "ComplaintStatus" ADD VALUE 'RESOLVED_PENDING';
    END IF;
END$$;

-- ─── Complaint table new columns ──────────────────────────────────────────────
ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "internalNotes"     TEXT;
ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "statusHistory"     TEXT;
ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "whatsappSentAt"    TIMESTAMP(3);
ALTER TABLE "Complaint" ADD COLUMN IF NOT EXISTS "whatsappMessageId" TEXT;
