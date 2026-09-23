-- CreateEnum
CREATE TYPE "RegistrationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ComplaintStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "PaymentVerificationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterEnum
ALTER TYPE "SeatStatus" ADD VALUE 'BLOCKED';

-- AlterTable
ALTER TABLE "Member" ADD COLUMN "portalAccess" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "registrationId" TEXT;

-- AlterTable
ALTER TABLE "MembershipPlan" ADD COLUMN "seatAllocation" TEXT NOT NULL DEFAULT 'ADMIN';

-- AlterTable
ALTER TABLE "Notification" ADD COLUMN "memberId" TEXT;

-- AlterTable
ALTER TABLE "Payment" ADD COLUMN "notes" TEXT,
ADD COLUMN "paymentType" TEXT;

-- AlterTable
ALTER TABLE "QrCode" ADD COLUMN "url" TEXT;

-- AlterTable
ALTER TABLE "Seat" ADD COLUMN "notes" TEXT;

-- CreateTable
CREATE TABLE "MemberRegistration" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "applicationId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT,
    "dob" TIMESTAMP(3),
    "gender" TEXT,
    "address" TEXT,
    "aadhaarNumber" TEXT,
    "emergencyContact" TEXT,
    "academicInfo" TEXT,
    "planId" TEXT,
    "photoUrl" TEXT,
    "aadhaarFrontUrl" TEXT,
    "aadhaarBackUrl" TEXT,
    "otherDocUrls" TEXT,
    "status" "RegistrationStatus" NOT NULL DEFAULT 'PENDING',
    "rejectionReason" TEXT,
    "reservedSeatId" TEXT,
    "memberId" TEXT,
    "reviewedBy" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MemberRegistration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Complaint" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "branchId" TEXT NOT NULL,
    "complaintId" TEXT NOT NULL,
    "memberId" TEXT,
    "memberName" TEXT NOT NULL,
    "memberPhone" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "attachmentUrls" TEXT,
    "status" "ComplaintStatus" NOT NULL DEFAULT 'OPEN',
    "resolution" TEXT,
    "assignedTo" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Complaint_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentVerification" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "paymentId" TEXT NOT NULL,
    "memberId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "paymentType" TEXT NOT NULL,
    "screenshotUrl" TEXT,
    "txnRef" TEXT,
    "upiId" TEXT,
    "status" "PaymentVerificationStatus" NOT NULL DEFAULT 'PENDING',
    "rejectionReason" TEXT,
    "verifiedBy" TEXT,
    "verifiedAt" TIMESTAMP(3),
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MemberPortalSession" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "otp" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "memberId" TEXT,
    "token" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MemberPortalSession_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "MemberRegistration_applicationId_key" ON "MemberRegistration"("applicationId");
CREATE INDEX "MemberRegistration_tenantId_idx" ON "MemberRegistration"("tenantId");
CREATE INDEX "MemberRegistration_phone_idx" ON "MemberRegistration"("phone");
CREATE INDEX "MemberRegistration_status_idx" ON "MemberRegistration"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Complaint_complaintId_key" ON "Complaint"("complaintId");
CREATE INDEX "Complaint_tenantId_idx" ON "Complaint"("tenantId");
CREATE INDEX "Complaint_status_idx" ON "Complaint"("status");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentVerification_paymentId_key" ON "PaymentVerification"("paymentId");
CREATE INDEX "PaymentVerification_tenantId_idx" ON "PaymentVerification"("tenantId");
CREATE INDEX "PaymentVerification_status_idx" ON "PaymentVerification"("status");

-- CreateIndex
CREATE UNIQUE INDEX "MemberPortalSession_token_key" ON "MemberPortalSession"("token");
CREATE INDEX "MemberPortalSession_phone_idx" ON "MemberPortalSession"("phone");
CREATE INDEX "MemberPortalSession_token_idx" ON "MemberPortalSession"("token");

-- CreateIndex
CREATE INDEX "QrCode_entityType_entityId_idx" ON "QrCode"("entityType", "entityId");

-- AddForeignKey
ALTER TABLE "Member" ADD CONSTRAINT "Member_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES "MemberRegistration"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "MemberRegistration" ADD CONSTRAINT "MemberRegistration_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "MemberRegistration" ADD CONSTRAINT "MemberRegistration_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "MemberRegistration" ADD CONSTRAINT "MemberRegistration_planId_fkey" FOREIGN KEY ("planId") REFERENCES "MembershipPlan"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "MemberRegistration" ADD CONSTRAINT "MemberRegistration_reservedSeatId_fkey" FOREIGN KEY ("reservedSeatId") REFERENCES "Seat"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Complaint" ADD CONSTRAINT "Complaint_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Complaint" ADD CONSTRAINT "Complaint_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Complaint" ADD CONSTRAINT "Complaint_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "Member"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "PaymentVerification" ADD CONSTRAINT "PaymentVerification_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "PaymentVerification" ADD CONSTRAINT "PaymentVerification_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "PaymentVerification" ADD CONSTRAINT "PaymentVerification_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "Member"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
