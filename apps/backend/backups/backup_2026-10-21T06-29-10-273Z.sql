--
-- PostgreSQL database dump
--

\restrict jRdUYkBrDMQLo7tAcNJu0HloG6lTFABqhrOt7lBV7PvXxvOidiB1inNwbJcRSb6

-- Dumped from database version 14.24 (Ubuntu 14.24-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.24 (Ubuntu 14.24-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AttendanceMethod; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."AttendanceMethod" AS ENUM (
    'MANUAL',
    'QR'
);


ALTER TYPE public."AttendanceMethod" OWNER TO chintamani;

--
-- Name: CommunicationChannel; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."CommunicationChannel" AS ENUM (
    'SMS',
    'WHATSAPP',
    'PUSH'
);


ALTER TYPE public."CommunicationChannel" OWNER TO chintamani;

--
-- Name: ComplaintStatus; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."ComplaintStatus" AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED',
    'SUBMITTED',
    'UNDER_REVIEW',
    'REJECTED',
    'REOPENED',
    'RESOLVED_PENDING'
);


ALTER TYPE public."ComplaintStatus" OWNER TO chintamani;

--
-- Name: EnquiryStatus; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."EnquiryStatus" AS ENUM (
    'NEW',
    'CONTACTED',
    'INTERESTED',
    'CONVERTED',
    'NOT_INTERESTED'
);


ALTER TYPE public."EnquiryStatus" OWNER TO chintamani;

--
-- Name: ExpenseCategory; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."ExpenseCategory" AS ENUM (
    'ELECTRICITY',
    'INTERNET',
    'MAINTENANCE',
    'SALARY',
    'CLEANING',
    'EQUIPMENT',
    'OTHER'
);


ALTER TYPE public."ExpenseCategory" OWNER TO chintamani;

--
-- Name: PaymentMethod; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."PaymentMethod" AS ENUM (
    'CASH',
    'UPI',
    'CARD',
    'BANK',
    'OTHER'
);


ALTER TYPE public."PaymentMethod" OWNER TO chintamani;

--
-- Name: PaymentVerificationStatus; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."PaymentVerificationStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."PaymentVerificationStatus" OWNER TO chintamani;

--
-- Name: RegistrationStatus; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."RegistrationStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."RegistrationStatus" OWNER TO chintamani;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."Role" AS ENUM (
    'SUPER_ADMIN',
    'OWNER',
    'ADMIN',
    'BRANCH_MANAGER',
    'STAFF'
);


ALTER TYPE public."Role" OWNER TO chintamani;

--
-- Name: SeatStatus; Type: TYPE; Schema: public; Owner: chintamani
--

CREATE TYPE public."SeatStatus" AS ENUM (
    'AVAILABLE',
    'OCCUPIED',
    'RESERVED',
    'MAINTENANCE',
    'BLOCKED'
);


ALTER TYPE public."SeatStatus" OWNER TO chintamani;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Attendance; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Attendance" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "memberId" text NOT NULL,
    "branchId" text NOT NULL,
    "checkIn" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "checkOut" timestamp(3) without time zone,
    method public."AttendanceMethod" DEFAULT 'MANUAL'::public."AttendanceMethod" NOT NULL
);


ALTER TABLE public."Attendance" OWNER TO chintamani;

--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    "tenantId" text,
    "userId" text,
    "branchId" text,
    action text NOT NULL,
    entity text NOT NULL,
    "entityId" text NOT NULL,
    metadata text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AuditLog" OWNER TO chintamani;

--
-- Name: BackupLog; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."BackupLog" (
    id text NOT NULL,
    "tenantId" text,
    "backupName" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" integer DEFAULT 0 NOT NULL,
    "itemCount" integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'SUCCESS'::text NOT NULL,
    "triggerType" text DEFAULT 'AUTOMATIC'::text NOT NULL,
    details text,
    "errorMsg" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "completedAt" timestamp(3) without time zone,
    "restoredAt" timestamp(3) without time zone,
    "restoredBy" text
);


ALTER TABLE public."BackupLog" OWNER TO chintamani;

--
-- Name: Branch; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Branch" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    name text NOT NULL,
    address text,
    phone text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Branch" OWNER TO chintamani;

--
-- Name: CommunicationLog; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."CommunicationLog" (
    id text NOT NULL,
    "tenantId" text,
    channel public."CommunicationChannel" NOT NULL,
    recipient text NOT NULL,
    message text NOT NULL,
    status text DEFAULT 'SENT'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."CommunicationLog" OWNER TO chintamani;

--
-- Name: Complaint; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Complaint" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "complaintId" text NOT NULL,
    "memberId" text,
    "memberName" text NOT NULL,
    "memberPhone" text NOT NULL,
    category text NOT NULL,
    description text NOT NULL,
    "attachmentUrls" text,
    status public."ComplaintStatus" DEFAULT 'OPEN'::public."ComplaintStatus" NOT NULL,
    resolution text,
    "assignedTo" text,
    "resolvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "internalNotes" text,
    "statusHistory" text,
    "whatsappMessageId" text,
    "whatsappSentAt" timestamp(3) without time zone
);


ALTER TABLE public."Complaint" OWNER TO chintamani;

--
-- Name: Enquiry; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Enquiry" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    email text,
    status public."EnquiryStatus" DEFAULT 'NEW'::public."EnquiryStatus" NOT NULL,
    "followUpDate" timestamp(3) without time zone,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Enquiry" OWNER TO chintamani;

--
-- Name: Expense; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Expense" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    category public."ExpenseCategory" NOT NULL,
    amount double precision NOT NULL,
    description text,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Expense" OWNER TO chintamani;

--
-- Name: Feedback; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Feedback" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "memberId" text,
    "memberName" text NOT NULL,
    "memberPhone" text,
    rating integer DEFAULT 5 NOT NULL,
    category text NOT NULL,
    review text NOT NULL,
    status text DEFAULT 'NEW'::text NOT NULL,
    response text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Feedback" OWNER TO chintamani;

--
-- Name: Locker; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Locker" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "lockerNumber" text NOT NULL,
    status public."SeatStatus" DEFAULT 'AVAILABLE'::public."SeatStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Locker" OWNER TO chintamani;

--
-- Name: LockerAssignment; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."LockerAssignment" (
    id text NOT NULL,
    "lockerId" text NOT NULL,
    "subscriptionId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "releasedAt" timestamp(3) without time zone
);


ALTER TABLE public."LockerAssignment" OWNER TO chintamani;

--
-- Name: Member; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Member" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "memberCode" text NOT NULL,
    name text NOT NULL,
    email text,
    phone text NOT NULL,
    dob timestamp(3) without time zone,
    address text,
    "academicInfo" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "portalAccess" boolean DEFAULT false NOT NULL,
    "registrationId" text,
    "archivedAt" timestamp(3) without time zone,
    "archivedBy" text,
    "isArchived" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Member" OWNER TO chintamani;

--
-- Name: MemberPortalSession; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."MemberPortalSession" (
    id text NOT NULL,
    phone text NOT NULL,
    otp text NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    "memberId" text,
    token text,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."MemberPortalSession" OWNER TO chintamani;

--
-- Name: MemberRegistration; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."MemberRegistration" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "applicationId" text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    email text,
    dob timestamp(3) without time zone,
    gender text,
    address text,
    "aadhaarNumber" text,
    "emergencyContact" text,
    "academicInfo" text,
    "planId" text,
    "photoUrl" text,
    "aadhaarFrontUrl" text,
    "aadhaarBackUrl" text,
    "otherDocUrls" text,
    status public."RegistrationStatus" DEFAULT 'PENDING'::public."RegistrationStatus" NOT NULL,
    "rejectionReason" text,
    "reservedSeatId" text,
    "memberId" text,
    "reviewedBy" text,
    "reviewedAt" timestamp(3) without time zone,
    "submittedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."MemberRegistration" OWNER TO chintamani;

--
-- Name: MembershipPlan; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."MembershipPlan" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    name text NOT NULL,
    "durationDays" integer NOT NULL,
    price double precision NOT NULL,
    "includesSeat" boolean DEFAULT true NOT NULL,
    "includesLocker" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "seatAllocation" text DEFAULT 'ADMIN'::text NOT NULL
);


ALTER TABLE public."MembershipPlan" OWNER TO chintamani;

--
-- Name: Notification; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Notification" (
    id text NOT NULL,
    "tenantId" text,
    "userId" text,
    type text NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "memberId" text
);


ALTER TABLE public."Notification" OWNER TO chintamani;

--
-- Name: Payment; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Payment" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "memberId" text NOT NULL,
    amount double precision NOT NULL,
    method public."PaymentMethod" NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    "txnRef" text,
    "paidAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    notes text,
    "paymentType" text
);


ALTER TABLE public."Payment" OWNER TO chintamani;

--
-- Name: PaymentTransaction; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."PaymentTransaction" (
    id text NOT NULL,
    "paymentId" text NOT NULL,
    amount double precision NOT NULL,
    status text NOT NULL,
    "providerRef" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."PaymentTransaction" OWNER TO chintamani;

--
-- Name: PaymentVerification; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."PaymentVerification" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "paymentId" text NOT NULL,
    "memberId" text NOT NULL,
    amount double precision NOT NULL,
    "paymentType" text NOT NULL,
    "screenshotUrl" text,
    "txnRef" text,
    "upiId" text,
    status public."PaymentVerificationStatus" DEFAULT 'PENDING'::public."PaymentVerificationStatus" NOT NULL,
    "rejectionReason" text,
    "verifiedBy" text,
    "verifiedAt" timestamp(3) without time zone,
    "submittedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PaymentVerification" OWNER TO chintamani;

--
-- Name: Permission; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Permission" (
    id text NOT NULL,
    "userId" text NOT NULL,
    action text NOT NULL
);


ALTER TABLE public."Permission" OWNER TO chintamani;

--
-- Name: QrCode; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."QrCode" (
    id text NOT NULL,
    "tenantId" text,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    url text
);


ALTER TABLE public."QrCode" OWNER TO chintamani;

--
-- Name: Seat; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Seat" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "branchId" text NOT NULL,
    "seatNumber" text NOT NULL,
    floor text NOT NULL,
    status public."SeatStatus" DEFAULT 'AVAILABLE'::public."SeatStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    notes text
);


ALTER TABLE public."Seat" OWNER TO chintamani;

--
-- Name: SeatAssignment; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."SeatAssignment" (
    id text NOT NULL,
    "seatId" text NOT NULL,
    "subscriptionId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "releasedAt" timestamp(3) without time zone
);


ALTER TABLE public."SeatAssignment" OWNER TO chintamani;

--
-- Name: Settings; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Settings" (
    id text NOT NULL,
    "tenantId" text,
    "branchId" text,
    key text NOT NULL,
    value text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Settings" OWNER TO chintamani;

--
-- Name: Subscription; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Subscription" (
    id text NOT NULL,
    "tenantId" text NOT NULL,
    "memberId" text NOT NULL,
    "planId" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    "assignedSeatId" text,
    "assignedLockerId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Subscription" OWNER TO chintamani;

--
-- Name: Tenant; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."Tenant" (
    id text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    slug text NOT NULL,
    logo text,
    phone text,
    email text,
    address text,
    city text,
    state text,
    country text DEFAULT 'India'::text NOT NULL,
    plan text DEFAULT 'STANDARD'::text NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    settings text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Tenant" OWNER TO chintamani;

--
-- Name: User; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."User" (
    id text NOT NULL,
    "tenantId" text,
    name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role public."Role" DEFAULT 'STAFF'::public."Role" NOT NULL,
    phone text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."User" OWNER TO chintamani;

--
-- Name: UserBranchAccess; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public."UserBranchAccess" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "branchId" text NOT NULL
);


ALTER TABLE public."UserBranchAccess" OWNER TO chintamani;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: chintamani
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO chintamani;

--
-- Data for Name: Attendance; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Attendance" (id, "tenantId", "memberId", "branchId", "checkIn", "checkOut", method) FROM stdin;
8e449052-6019-4835-88a6-e4d6506a0888	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 04:40:00	\N	MANUAL
00d9c1b7-c02b-4998-bd25-7c84f930f38a	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 05:00:00	2026-10-19 13:00:00	MANUAL
4bfdde50-8a47-443f-8add-91354fc80d20	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 01:48:00	2026-10-17 08:48:00	MANUAL
e01835fd-7a98-4bab-a3fe-c9febdb45849	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 05:09:00	2026-10-15 15:09:00	MANUAL
b9d0d292-bbc1-4aeb-adb0-4e13e2a04f1a	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 03:22:00	2026-10-13 12:22:00	MANUAL
9071a835-e114-48f1-9282-74831ca73a0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 03:12:00	2026-10-12 10:12:00	MANUAL
1a6c2810-c0dd-46c1-9c20-560279a0be5d	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 03:27:00	2026-10-11 07:27:00	QR
fb3db49c-1156-4b7f-bc23-6bed57aada31	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:45:00	2026-10-09 10:45:00	MANUAL
ddffb7bc-3434-4104-928a-c0a63da0641d	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:33:00	2026-10-06 11:33:00	MANUAL
48087034-49f2-435a-afd6-28c311666e8c	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 01:30:00	2026-10-05 10:30:00	QR
c2828611-137e-4682-a868-91b0805e8860	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 04:13:00	2026-10-04 09:13:00	QR
342a96fc-ddbc-449d-a7a7-27f6da78791a	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:18:00	2026-10-03 10:18:00	MANUAL
9ca94d0c-c18a-49dd-8657-58e0974f81ba	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 05:04:00	2026-10-02 16:04:00	MANUAL
9c881b24-298f-44ec-b30c-aea03a1f7322	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 01:41:00	2026-10-01 10:41:00	QR
e83a5867-3e2f-4e5c-8ca2-980755fa00be	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:06:00	\N	QR
fe0dfe9b-19d0-4fad-aad1-095dfbc377c1	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 02:50:00	2026-10-18 10:50:00	QR
f285cae7-21bd-4c32-8b2c-016214ef1974	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 01:53:00	2026-10-17 11:53:00	QR
4028ba1a-db4f-418b-b8b3-463be38b8f16	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 02:15:00	2026-10-15 12:15:00	QR
1b2f398f-a05f-4f71-ad90-6ee8a85f0cd6	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 03:34:00	2026-10-14 10:34:00	MANUAL
d48de123-70d9-4f3d-801a-bbd6221dfd55	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 04:15:00	2026-10-13 15:15:00	MANUAL
acbddd45-75c0-4f55-a632-839157d1207c	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:31:00	2026-10-12 08:31:00	MANUAL
8384cbb8-58bc-4122-9a3b-495aa6dc3f9d	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 04:02:00	2026-10-11 13:02:00	QR
620ec8ec-64aa-46ef-9d29-d7da316a88ca	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 04:26:00	2026-10-10 09:26:00	QR
395978e9-71ae-4868-8dbf-a89687dad711	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:37:00	2026-10-08 11:37:00	MANUAL
5276979e-9753-44af-9055-9daa41904486	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 04:41:00	2026-10-07 10:41:00	MANUAL
a105211d-6b70-425c-9733-20bc5dd6900a	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 02:59:00	2026-10-06 08:59:00	QR
04bfbb27-026f-4b15-a948-1c17d9629573	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 03:00:00	2026-10-05 13:00:00	MANUAL
b19459bc-72b1-4cb0-b86d-ceea913f61d7	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:53:00	2026-10-04 12:53:00	MANUAL
58623613-a3e8-4a98-b6f9-ac66a66665cd	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:36:00	2026-10-02 09:36:00	MANUAL
f5dd134d-239d-4fc8-96f8-ba211f4e3b95	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:36:00	2026-10-01 13:36:00	MANUAL
af211d3f-6213-43fa-b66b-4808cb0dd617	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:57:00	\N	MANUAL
5e3a259b-9d41-4b04-85d8-66709100a048	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 02:22:00	2026-10-19 10:22:00	MANUAL
2e7ce48b-6471-4900-9834-401b475cc54e	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 01:35:00	2026-10-18 07:35:00	MANUAL
a4475509-8a37-4cf8-a22b-b0244619eea1	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 03:23:00	2026-10-17 08:23:00	MANUAL
96c110c4-5443-413d-944e-0d4d0134c385	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:06:00	2026-10-16 13:06:00	QR
47781326-fe16-4ded-b6b2-b2c7087995f7	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 05:17:00	2026-10-15 14:17:00	MANUAL
c640228f-559b-4882-b2cb-a87ffb2fa89b	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 05:05:00	2026-10-14 12:05:00	QR
174224b1-8878-4975-94ac-424ab7cc639c	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 01:58:00	2026-10-13 09:58:00	MANUAL
684be6c1-b893-450c-9294-48994bdeb94e	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 01:55:00	2026-10-11 09:55:00	MANUAL
78b5db7b-db1a-46ff-9b6c-2f9ffbe70a56	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:01:00	2026-10-09 07:01:00	QR
8d2d7638-bfef-47aa-8b8e-840b4e384ac0	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 01:55:00	2026-10-08 07:55:00	MANUAL
5ff0e3e8-2d67-4f89-8b30-235ca3cadb70	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 05:22:00	2026-10-07 09:22:00	MANUAL
e0b723b4-3b37-4eaf-894f-91e18f47e8ed	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 05:06:00	2026-10-06 09:06:00	MANUAL
9a3529cf-f7f2-4cc8-9426-d5056481d692	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 05:06:00	2026-10-05 12:06:00	MANUAL
77373ada-ba0c-4546-bd71-14b39589c0a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 01:50:00	2026-10-04 11:50:00	MANUAL
3353eb37-1580-4d1b-8ae3-cfff949c4c25	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:33:00	2026-10-01 09:33:00	MANUAL
90c70a39-21a3-414d-964b-18fad2006cff	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:23:00	\N	MANUAL
dc809fc2-3c19-4a0f-bdd5-9c448c1e6c20	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 04:00:00	2026-10-19 11:00:00	MANUAL
62142bda-976d-4939-b765-c60dc7bd4703	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 03:11:00	2026-10-18 10:11:00	MANUAL
8697577b-3bd8-442f-9ecb-a25f7f96689b	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:52:00	2026-10-14 08:52:00	MANUAL
71f3249c-0582-4dd0-bcb7-81c73a9f2a0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 04:24:00	2026-10-13 14:24:00	MANUAL
f8023456-5e65-4532-abce-ddf357c95909	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 04:51:00	2026-10-12 09:51:00	MANUAL
2d2546a9-ac97-454b-98e8-ccb150544173	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 03:12:00	2026-10-11 07:12:00	MANUAL
99e83816-95bf-4332-b68e-a86036268614	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:40:00	2026-10-10 08:40:00	QR
075cba71-b033-4da9-a911-646f117526ff	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:05:00	2026-10-09 07:05:00	QR
84922f2e-5930-4a27-9255-3a3106ef117b	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 04:09:00	2026-10-08 09:09:00	QR
15058d00-e648-4c53-b52c-8f8289d0a567	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 04:58:00	2026-10-06 15:58:00	MANUAL
62195ce6-d65e-4b23-bb2c-1a1e5a81a896	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 03:13:00	2026-10-05 10:13:00	QR
ace6cf3e-83d1-44b6-868d-ded46754f811	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:13:00	2026-10-03 14:13:00	MANUAL
e072af0c-3e35-4b1a-aad4-6b0e6821b61c	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 04:10:00	2026-10-01 10:10:00	MANUAL
c4630d2f-832f-4304-b958-1a297f2643ea	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 04:38:00	\N	QR
1edf35d6-ac78-4501-a2e3-c3bb629750e8	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 03:06:00	2026-10-19 07:06:00	MANUAL
a9eca2d0-183b-4752-935f-0ce1d7a9af35	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:32:00	2026-10-18 13:32:00	MANUAL
0705094c-a1cb-46f9-9da7-11ed10b003bf	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:31:00	2026-10-17 10:31:00	MANUAL
33693449-852a-473d-ba53-7ca946f9404a	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 02:25:00	2026-10-16 13:25:00	MANUAL
5aecee19-6a90-4655-a44e-efc47559bf9d	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 04:34:00	2026-10-15 10:34:00	QR
c1b38567-3ece-44a7-b79c-d9b0fc3820bf	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 02:31:00	2026-10-14 09:31:00	MANUAL
00e248ba-cbaf-4920-ab99-e97b48b809b4	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 01:45:00	2026-10-12 12:45:00	MANUAL
f390b53b-ad98-447e-819c-e778468a3eca	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:04:00	2026-10-11 09:04:00	MANUAL
20ada597-fcb6-483d-8b6b-d3fdda7f318e	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 04:20:00	2026-10-10 09:20:00	MANUAL
f64a66e5-71ba-4c6d-a494-83f8c1cab1b3	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 04:26:00	2026-10-09 14:26:00	MANUAL
8722f30b-ba33-469b-92a1-2ab0fc0509cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 03:26:00	2026-10-07 12:26:00	MANUAL
c231f253-56de-48ef-ab13-2e7120a9b02c	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:14:00	2026-10-04 06:14:00	MANUAL
a61ffb4a-8697-4b72-a5e9-b0533962c96b	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:24:00	2026-10-03 06:24:00	QR
d65b3ebe-582d-4108-a8c2-751a95ca0b5f	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:02:00	2026-10-02 13:02:00	MANUAL
d2464e5c-b64e-4def-b0d9-08b3cb3a4bb0	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:37:00	\N	QR
80a32986-7729-4078-b436-be1916459242	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:41:00	2026-10-17 15:41:00	MANUAL
51156eae-e7f0-4202-b381-6663ebaa3b5d	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 04:58:00	2026-10-16 12:58:00	QR
a40ffcd3-3ca6-4b17-be35-55b1246c24bb	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 02:19:00	2026-10-15 13:19:00	MANUAL
c338fff2-3858-4b33-bf8c-bebdaee5a4f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:50:00	2026-10-14 09:50:00	MANUAL
e9a66f26-a45a-487f-a0b1-1e274f86fa73	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:52:00	2026-10-12 10:52:00	MANUAL
174a4c65-69bb-413c-b5d3-d976df058ee7	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 04:00:00	2026-10-11 09:00:00	MANUAL
f9a9b45f-0973-4ba8-919d-f727e6ab24f6	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:54:00	2026-10-10 14:54:00	QR
62aa688b-a26e-4f75-ac45-0a9a26ef83ad	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:33:00	2026-10-09 14:33:00	MANUAL
68625e9a-7e4f-4ec6-98ef-590f533cd55d	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 04:25:00	2026-10-08 09:25:00	MANUAL
a7c68ee7-ffc4-475c-ab2d-ed7b9f02ef74	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:24:00	2026-10-06 08:24:00	MANUAL
b291380e-64cb-4b9e-807b-e1fc78c93e68	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 02:34:00	2026-10-05 09:34:00	MANUAL
4057f38a-9959-4e7c-ae46-59032c3bc1e9	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:45:00	2026-10-03 06:45:00	MANUAL
6f8bf2cb-a4aa-4ff3-972d-586a0533bffb	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:34:00	2026-10-01 10:34:00	MANUAL
96aa6734-ca4e-4f09-8c67-15c3407bd7ea	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 01:57:00	2026-10-18 10:57:00	MANUAL
65decdbb-c5a1-461e-b9f1-f8b0e471f1db	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 05:04:00	2026-10-17 09:04:00	MANUAL
401dd5b5-969b-49a9-9e1b-f6e3ea21f13d	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:42:00	2026-10-16 14:42:00	MANUAL
a791545b-d044-4944-984b-9a8dedf315ac	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:19:00	2026-10-15 12:19:00	MANUAL
29759674-8b14-448a-982d-52860e222a2e	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 02:48:00	2026-10-14 06:48:00	MANUAL
445d91c6-0b1f-421f-a898-29f8326e7197	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:43:00	2026-10-12 08:43:00	MANUAL
63c5355d-51ac-4de0-b4b0-e3f9b2aecd96	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 01:46:00	2026-10-10 10:46:00	QR
9ec63fd2-99ee-4d78-8bbf-460b784f9a0b	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 01:38:00	2026-10-09 09:38:00	MANUAL
2213e73b-09fe-44f5-bc53-e197ea51a2cb	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 04:22:00	2026-10-07 12:22:00	MANUAL
09cde9b4-8ea7-42c0-b7f3-a7f8e3bafb61	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:02:00	2026-10-06 08:02:00	MANUAL
786d4399-91ea-4e93-a473-cf928b96115d	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 01:57:00	2026-10-05 06:57:00	QR
2a3601cd-5227-4acc-8e43-c5f38c638b3d	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 04:45:00	2026-10-03 13:45:00	MANUAL
2ef41ee3-9fbc-4d98-b9a0-b8d6a244465e	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:01:00	2026-10-01 10:01:00	MANUAL
d5eeda31-fe32-495b-a200-ba1f10153e1b	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:33:00	\N	QR
292b533d-e975-43d7-8e56-737f17484ed4	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 02:04:00	2026-10-19 08:04:00	MANUAL
a821d7c4-80ee-45c8-b62f-8c231a792b94	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 05:17:00	2026-10-18 12:17:00	MANUAL
20e817b5-60e8-4120-a0ee-f47382e3a553	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:44:00	2026-10-12 06:44:00	MANUAL
5112a93d-af5c-48ab-b39e-592d0c1147cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:51:00	2026-10-11 12:51:00	MANUAL
4543a968-dc4f-49bc-b717-15f8027d7684	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 02:11:00	2026-10-10 12:11:00	MANUAL
be96f00a-19c4-44b6-a389-5263c308e400	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:06:00	2026-10-09 08:06:00	MANUAL
15d6b380-6836-4052-8ecb-cbf52edf7a79	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:22:00	2026-10-08 11:22:00	QR
5d70632a-0d30-4405-87d0-5d53b53f608a	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 02:49:00	2026-10-07 06:49:00	MANUAL
7e99cc2e-e6cb-4c8e-a3ab-c38cea7ad0b4	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:46:00	2026-10-06 10:46:00	MANUAL
e8a42df5-7ccb-4800-9351-f9c4c7599379	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 03:00:00	2026-10-05 08:00:00	MANUAL
e59fe4a6-d39b-4911-bace-b18775d5d68b	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 03:39:00	2026-10-04 14:39:00	MANUAL
45be1d8b-070f-447f-a92e-597e21cf0894	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:34:00	2026-10-03 09:34:00	MANUAL
9d67d180-349e-420e-b679-eab044fa290c	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:52:00	2026-10-02 12:52:00	QR
c367bc33-f2f0-49e3-890b-5f86280ad925	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:35:00	2026-10-18 08:35:00	MANUAL
d461e520-2cb0-4e67-bccd-4693ae6b67c8	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 05:07:00	2026-10-17 09:07:00	MANUAL
02bcc1cc-9f3b-43c2-88ee-f0c3ba52463a	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 04:37:00	2026-10-16 14:37:00	MANUAL
d4831033-5019-40e1-97e1-d496a32e4f17	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:21:00	2026-10-14 11:21:00	MANUAL
1dc4d982-a331-4fd7-b9df-6d5af55915d4	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 03:05:00	2026-10-13 11:05:00	QR
158c1b51-c13e-47ba-96ea-0cf5f15ac7cb	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:57:00	2026-10-12 09:57:00	MANUAL
57f80319-d001-4d3f-9d97-bf2888ba4816	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 04:10:00	2026-10-11 10:10:00	MANUAL
4e2800b4-d768-48ba-88b5-1e737c6e6110	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 04:33:00	2026-10-10 09:33:00	MANUAL
e8ab82cc-7a0b-483c-8f50-51535ab680ad	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:26:00	2026-10-09 13:26:00	QR
f327b4c6-1c30-40ab-a88f-1421b9564091	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:52:00	2026-10-08 09:52:00	MANUAL
95f732c8-584e-4ce1-9e7d-445df8828521	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 02:38:00	2026-10-07 13:38:00	QR
95ff5ebf-42cd-4632-9b59-b43a0beebdf3	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 04:05:00	2026-10-06 15:05:00	MANUAL
b3d8620a-2924-44f3-b739-f02a369a3ed3	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 01:53:00	2026-10-05 05:53:00	QR
440a3479-635b-47c7-a94a-f8dc8c7652a1	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:22:00	2026-10-03 08:22:00	MANUAL
fc86e2df-6fc4-49ac-beed-e27a5185a33c	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 05:15:00	\N	MANUAL
7a2fdfaa-61c5-4167-8074-56f4694bd3af	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 02:19:00	2026-10-16 11:19:00	QR
9e7d8de7-bf8f-413b-a6ed-bf25480a0348	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:18:00	2026-10-15 09:18:00	MANUAL
c579882a-8c78-43ac-ba8a-737cb70a9bc6	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 03:29:00	2026-10-14 09:29:00	QR
71563e72-f7e6-4cb9-b59f-81cefbe529ff	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 03:05:00	2026-10-12 10:05:00	MANUAL
0366a692-7031-4bde-9293-843b311b6e3f	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:21:00	2026-10-11 10:21:00	QR
89290b3c-4f70-4612-9ce7-f0650d524278	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 02:20:00	2026-10-09 08:20:00	QR
18ca161e-a28d-43c3-ac9b-194c899231e2	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:26:00	2026-10-08 12:26:00	MANUAL
644fded4-fb67-479b-ab65-6eb7ed6788f8	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 03:07:00	2026-10-07 11:07:00	MANUAL
8814c6b5-c74a-4d0e-a80e-40a28a008576	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 05:04:00	2026-10-06 11:04:00	MANUAL
926f08b5-2512-49a2-b117-8df6b7f49f45	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 04:43:00	2026-10-05 08:43:00	MANUAL
a368dc5a-e5d4-485a-91ed-cf10fbeca757	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:30:00	2026-10-04 13:30:00	MANUAL
54a10fba-2270-4913-b518-55c4bec7c674	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:36:00	2026-10-02 11:36:00	MANUAL
56273623-0994-4863-b216-52d1fc97cddb	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:33:00	2026-10-01 12:33:00	QR
1f2696e9-5529-4509-bb0e-4dc7b9741f8b	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 04:51:00	\N	MANUAL
706084f8-9713-484a-82cd-b6c1dfd1dec4	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 04:04:00	2026-10-19 13:04:00	MANUAL
f9cf6874-281f-4bb1-b83c-95f3a477ba01	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:20:00	2026-10-18 12:20:00	MANUAL
d168a112-41fc-4012-b6b0-ba6c7f07a581	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:27:00	2026-10-16 07:27:00	QR
354e9fad-34a8-4270-8b00-2b4aa04f10bf	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 01:38:00	2026-10-15 07:38:00	MANUAL
e7f53094-1d6e-4452-a01e-bf18e2f7b523	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 01:49:00	2026-10-14 06:49:00	QR
42d25b1d-cfe4-4b2e-90f3-0377218c6809	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 04:11:00	2026-10-13 08:11:00	MANUAL
a2be303a-5211-44bc-b1a8-d72885c8503e	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 05:15:00	2026-10-12 12:15:00	QR
416494fe-8172-4d4c-8cbd-4f1eca824868	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:50:00	2026-10-11 13:50:00	MANUAL
1a93325f-30bc-4f9a-969b-8260252f83fc	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:27:00	2026-10-10 14:27:00	MANUAL
07bb2bfd-254e-4eac-94a4-a32893d3b44a	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:23:00	2026-10-09 07:23:00	MANUAL
e20b1a25-feb1-4413-a3be-e0e86d6e2fda	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 04:33:00	2026-10-08 13:33:00	MANUAL
b080b9bc-7b94-4bee-8596-0e08c87e7c18	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 01:40:00	2026-10-07 11:40:00	QR
bd682a2e-1ca0-4151-a2bd-b54226539071	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:08:00	2026-10-03 13:08:00	MANUAL
6b2f1713-bd0c-4407-91ad-a6f5525b4960	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 01:52:00	2026-10-02 09:52:00	MANUAL
fd2d611f-d0fb-4ba0-aa54-0715123c979e	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 03:17:00	2026-10-01 08:17:00	MANUAL
ead3557a-376f-475f-a674-8016b0fd74e2	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 05:00:00	\N	MANUAL
28086316-5a8b-4de0-a068-0a03b6cc0d45	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:44:00	2026-10-18 12:44:00	MANUAL
037ee9c4-c86b-42ee-a9a9-ac9a3d225246	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 01:31:00	2026-10-17 09:31:00	MANUAL
22f92e4a-ff72-4c65-b839-e32c6d443c6b	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:17:00	2026-10-15 12:17:00	MANUAL
2ea4eadc-3150-4b55-bca8-d86c5335a5e6	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 01:50:00	2026-10-14 12:50:00	QR
9053aaa7-57c2-4e84-b2a4-909a75c7f119	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 04:34:00	2026-10-13 13:34:00	MANUAL
f6e60e2d-3f5f-41f1-9c9c-d8a837d81520	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 05:08:00	2026-10-12 09:08:00	MANUAL
afb663ef-eaa1-4df2-825d-d735982dcf7f	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:40:00	2026-10-11 10:40:00	MANUAL
70e30e2b-d7ee-493b-be8c-a2cf6b9bd904	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 01:30:00	2026-10-10 08:30:00	QR
29b93577-855e-4423-be51-e89146008a0f	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 02:27:00	2026-10-09 07:27:00	MANUAL
1507e7c6-a68b-4f95-b7de-1e011543192b	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:28:00	2026-10-08 09:28:00	MANUAL
13fa4195-79e0-460b-b7d3-1f88ef10b300	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 01:36:00	2026-10-07 05:36:00	QR
0661f562-4869-4626-bd13-bfdae5724b7b	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 01:36:00	2026-10-06 07:36:00	QR
669a7028-a849-4cfb-88ca-20b7586a4563	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 04:55:00	2026-10-05 12:55:00	QR
c041369f-d028-4bf1-8acb-0eea44b82ce8	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 04:10:00	2026-10-03 12:10:00	MANUAL
f905087d-c587-4e86-b634-e90f3060fc23	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 04:27:00	2026-10-02 08:27:00	QR
335941dd-442f-44cd-be46-6b432d586b5d	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:28:00	2026-10-01 08:28:00	QR
42306e83-4fcd-40ea-bb57-fed768f668cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:24:00	\N	MANUAL
8c3df889-fede-4093-b179-fdc3b9f31b71	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:31:00	2026-10-17 13:31:00	QR
e39de04e-733b-4825-bd6e-9307833492e2	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 02:04:00	2026-10-16 10:04:00	MANUAL
4970d4e1-6cf8-4414-9d0f-f2f8cac964d6	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:01:00	2026-10-15 08:01:00	MANUAL
9198f46c-9405-41b9-864c-3f0d78681639	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:37:00	2026-10-14 15:37:00	MANUAL
0294f339-ca26-412c-8dfe-4736dcb0c1af	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 03:14:00	2026-10-13 14:14:00	MANUAL
f78bd127-2b8a-45d4-94fa-ea5c8559739a	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 03:06:00	2026-10-12 12:06:00	QR
59c5bdad-fbe4-4f5c-9f62-3a194e6dd85d	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 04:47:00	2026-10-11 14:47:00	MANUAL
8e98edcc-60f3-4326-ad92-df734d2e75ec	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:38:00	2026-10-09 07:38:00	MANUAL
35d890a3-ea14-4571-8844-4666183340f5	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:29:00	2026-10-08 12:29:00	MANUAL
fce3af6b-91c6-45fb-9f56-05d73d850101	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 04:35:00	2026-10-07 08:35:00	QR
28f1e410-b3ee-417d-b2aa-8ec4e9667762	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 02:30:00	2026-10-05 08:30:00	MANUAL
442055c7-dd8e-4fba-ad13-a8c48c6e20a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 03:50:00	2026-10-04 11:50:00	QR
c70666e8-7be2-4087-9286-fb7b593a7934	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:43:00	2026-10-03 07:43:00	MANUAL
7f97beca-6879-4a1c-90ad-11ac073ac678	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:09:00	2026-10-02 09:09:00	MANUAL
ac37893e-9174-4ed9-ad5f-a2693418c98c	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 03:24:00	2026-10-01 13:24:00	QR
b6d547db-0394-4976-aa60-c838b0d1bc47	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 03:50:00	\N	MANUAL
0606387d-6a8b-4d95-89d7-ef3b8c9b54db	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 03:58:00	2026-10-18 13:58:00	QR
37b83c88-5d60-49bd-823c-6b89090510b5	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:53:00	2026-10-17 12:53:00	MANUAL
ab72910c-d6ef-43b9-8f04-ebf1c9f15b12	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:04:00	2026-10-16 09:04:00	MANUAL
b0d52990-b342-47b1-a915-f85ea00b9407	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 01:59:00	2026-10-14 05:59:00	MANUAL
33535947-ab85-4b41-b044-e859aa4576d6	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 01:39:00	2026-10-11 08:39:00	QR
ac7c9729-b508-4293-a233-3d99c7ca4f78	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 02:36:00	2026-10-10 08:36:00	MANUAL
d8094ac3-c0de-406b-88c1-d30d64a15dbc	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:01:00	2026-10-09 09:01:00	MANUAL
482be1f2-8f80-4a43-b17f-526298daae51	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 01:58:00	2026-10-08 09:58:00	MANUAL
b755fa5c-33d9-4e7b-ba96-384af3036137	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 05:01:00	2026-10-07 15:01:00	QR
253a9eb7-d86a-41d6-b498-4d7e3347bcee	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 05:05:00	2026-10-05 14:05:00	QR
cc447830-948b-472a-8b1f-5c8dbbcc1f9f	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 04:10:00	2026-10-04 13:10:00	QR
6dd2d043-872e-4881-b057-b36e3dce2f07	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:49:00	2026-10-03 13:49:00	QR
2b71e19d-3cfe-44e4-be84-027abcc1d3ee	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 04:22:00	2026-10-01 14:22:00	MANUAL
463072e3-7497-42a1-af93-ea6cba552f31	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 01:55:00	2026-10-18 09:55:00	MANUAL
dd408a4a-6f9f-4d12-b73a-871285e55c02	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 01:50:00	2026-10-17 08:50:00	QR
47b6e23e-113c-4164-a5ff-a7226734df84	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 04:18:00	2026-10-12 11:18:00	QR
88ddb72c-e1b0-4232-90d7-a2e3aecd1284	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 04:33:00	2026-10-09 12:33:00	MANUAL
db645456-0ab2-4447-a7ba-fd44c0cfb35d	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 01:50:00	2026-10-08 12:50:00	MANUAL
843c007c-9b5e-4009-896c-65be26e78aec	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 02:57:00	2026-10-07 12:57:00	QR
d443ff27-4a08-491b-a0c1-97ad573521d4	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 02:38:00	2026-10-05 13:38:00	MANUAL
0a086717-9857-41b5-9c83-071ffd246d25	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:50:00	2026-10-04 12:50:00	MANUAL
2dd791f7-c388-46ee-b089-49e75062cbcf	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:21:00	2026-10-02 13:21:00	MANUAL
45f0aa0f-17b1-418d-ae1d-a016e23c597d	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:13:00	2026-10-18 14:13:00	MANUAL
01531b50-ff6f-463a-9078-2ce396053438	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 04:33:00	2026-10-16 08:33:00	MANUAL
ddd4b3b7-bd2f-4eb7-9b8b-6da83886eb89	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 04:03:00	2026-10-15 08:03:00	MANUAL
acc5d4d5-6daf-44eb-bcd9-f4d8aeaab899	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 03:09:00	2026-10-14 10:09:00	QR
21af4958-dafa-4386-8537-63489f28253e	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 05:19:00	2026-10-11 14:19:00	MANUAL
d2808824-af77-45a6-8e40-45e577cb0f77	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:31:00	2026-10-10 08:31:00	MANUAL
fa393cb1-293c-4e1a-a7d0-7c47b7825580	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:53:00	2026-10-09 13:53:00	QR
d1dc4bfd-354d-48b6-b31b-66f9a3b78c3e	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 04:12:00	2026-10-06 09:12:00	QR
8ab3b91a-23a4-4222-a289-825cd088656a	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 03:07:00	2026-10-04 14:07:00	QR
51e9f385-89ec-4647-a46c-a4c9db40f363	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 01:58:00	2026-10-03 12:58:00	MANUAL
5bfed65e-1b41-41e3-a782-b16088289f0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:49:00	2026-10-02 08:49:00	MANUAL
c773a915-0836-4293-9364-ffc95b84bef5	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 03:05:00	2026-10-01 12:05:00	MANUAL
55002108-7bd2-478b-b93f-81b5f1d39a2e	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:09:00	\N	MANUAL
25562d65-3577-4e21-82bf-1b3419494e25	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 01:45:00	2026-10-19 07:45:00	QR
a1a08c0e-aafb-4196-b20e-eaa301924814	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:12:00	2026-10-17 15:12:00	QR
e2583c88-22a0-43ad-a451-c27f312bd8af	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 01:40:00	2026-10-16 06:40:00	MANUAL
dc7d5b01-820c-4540-9ac2-202f55b9463f	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 01:37:00	2026-10-15 05:37:00	MANUAL
6dc83a82-e971-482b-b763-3447c0b260c0	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 03:49:00	2026-10-14 08:49:00	MANUAL
e4339a5d-01e0-484b-a86e-b167dfba7715	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 04:56:00	2026-10-12 14:56:00	MANUAL
60001617-9b93-49a7-9f5d-dfc890710261	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 04:49:00	2026-10-10 11:49:00	MANUAL
b8ea1ef8-d1da-4953-a492-6c11f3c3f834	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 04:19:00	2026-10-09 10:19:00	QR
dcf160cb-668c-4da4-99fd-03925920ab0e	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:30:00	2026-10-08 07:30:00	QR
d69ce222-7705-43f5-846d-f3cb823f3630	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 05:10:00	2026-10-07 16:10:00	MANUAL
2678f3d8-51f3-416f-9e7a-7ed97100aa2e	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 04:37:00	2026-10-06 10:37:00	MANUAL
e01e162e-c108-4f08-ab4b-d98969caadcc	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 04:37:00	2026-10-05 09:37:00	QR
42176391-79bb-4466-af13-896a8193f433	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 01:36:00	2026-10-03 10:36:00	MANUAL
5b780ad2-c530-4ba3-9fab-da5b5fe898b7	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 04:37:00	2026-10-02 12:37:00	MANUAL
5e9a05db-c806-4e11-9510-b4ad96087f2d	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 01:32:00	2026-10-01 06:32:00	MANUAL
5141d8e4-30f1-47a5-9eb1-013911b0e805	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 02:31:00	2026-10-19 11:31:00	QR
040ce639-bd84-455d-b232-936b07ab49cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 03:16:00	2026-10-18 13:16:00	MANUAL
0ec06f8d-8bda-423a-aede-42e4b61e3dac	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:41:00	2026-10-16 11:41:00	MANUAL
25ddcec1-c112-40a5-abb6-ff7c4f5bcf99	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 04:56:00	2026-10-15 14:56:00	QR
8f79da82-7941-4ab5-97f8-b7f30f5fb8b0	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 01:46:00	2026-10-14 06:46:00	MANUAL
95537b06-5f54-47d7-91a4-1ede1c6c6222	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 02:35:00	2026-10-12 07:35:00	MANUAL
5b3e9ac4-3e3e-4ca8-9fab-227e996647a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 04:04:00	2026-10-11 13:04:00	MANUAL
33ad5feb-d4e8-4ef5-b08d-32b8057a46a2	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 01:53:00	2026-10-08 06:53:00	MANUAL
1d4868b4-404b-4b7c-8db0-6bfa6d08efe9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 03:20:00	2026-10-07 13:20:00	MANUAL
5707107d-d73c-4306-8357-c3247fa259fa	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:17:00	2026-10-06 13:17:00	QR
713b99bf-db6a-4a7a-a739-ad12512faad2	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:03:00	2026-10-04 10:03:00	MANUAL
ce1a9b8e-d49d-4c34-8a80-c048c00efd82	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:10:00	2026-10-02 12:10:00	QR
9a798dda-bf1d-4b87-8c9a-14693418786d	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 01:54:00	2026-10-19 12:54:00	MANUAL
b7f39b81-a610-4b20-8d91-cd72c1e2918f	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 04:48:00	2026-10-18 15:48:00	MANUAL
adffa137-fc69-4375-88e2-5d5e2d333db2	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 02:52:00	2026-10-17 07:52:00	QR
ccc4e200-2902-42f1-a67b-69ecfdafc14a	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 04:01:00	2026-10-15 12:01:00	QR
47dabf85-ddcc-440f-b8af-9030604da486	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 03:56:00	2026-10-14 13:56:00	MANUAL
02ad6991-bd99-4d22-931b-5208c8a80f57	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 02:16:00	2026-10-13 07:16:00	MANUAL
2da60b61-6cf4-4ad5-906a-8aac37b3a42b	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 03:53:00	2026-10-12 09:53:00	MANUAL
4e10d2ae-0f45-400e-b010-d452960da77c	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:56:00	2026-10-08 11:56:00	MANUAL
0366f226-d79e-452f-b7aa-a4b2ceab92da	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 03:14:00	2026-10-07 08:14:00	QR
f53b34fb-7d7e-4006-b2d3-e057a2dc7b7b	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 04:24:00	2026-10-06 15:24:00	QR
7b484bea-8523-41a2-9999-9312cb74188c	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 02:13:00	2026-10-05 06:13:00	MANUAL
1b22b66f-af27-45cf-81e2-88249a80033c	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:06:00	2026-10-03 14:06:00	QR
978c877a-8ead-4658-9cc7-5c3f4e363746	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:19:00	2026-10-02 06:19:00	QR
fced35eb-a9d1-4729-86a1-6855e04c08d9	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 04:58:00	2026-10-01 15:58:00	QR
8750474b-f22b-41bd-86e5-bb0e5a14414a	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 04:56:00	\N	QR
4018980c-a543-41d2-a2c4-597c8bdc22d5	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 04:18:00	2026-10-19 10:18:00	MANUAL
34f6e8f4-c5c6-4012-8187-b848d3220a16	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:43:00	2026-10-17 09:43:00	MANUAL
0765e2a3-b315-4df2-b5ad-6da690c92388	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 04:30:00	2026-10-16 13:30:00	QR
336280b0-d273-4df5-a32c-cc1ffa2783a0	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:00:00	2026-10-14 09:00:00	MANUAL
cb6f3083-bb24-4a76-85f1-eac9d47060f9	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 02:29:00	2026-10-13 10:29:00	MANUAL
d84c5665-53ba-45cb-a16a-5ce9861c55b3	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 04:54:00	2026-10-12 09:54:00	MANUAL
508208eb-bd44-47ea-ab00-d84d9d0b4860	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 02:33:00	2026-10-11 06:33:00	QR
fbe95a70-d72e-4064-aa72-510a37c0ef37	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 04:55:00	2026-10-10 12:55:00	MANUAL
e5fccbcd-6f2f-4c88-b038-d26677e04ab1	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:21:00	2026-10-08 13:21:00	MANUAL
8e25a4c8-da38-4b21-9adf-357c31af6cbb	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 03:51:00	2026-10-06 12:51:00	QR
0012d6ed-fc31-4aa4-8d83-7d426563f2da	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 04:47:00	2026-10-05 14:47:00	MANUAL
c35ade4e-db3e-4035-9c4c-153d8768f83e	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 02:25:00	2026-10-04 13:25:00	QR
23d0d7ae-1b78-4be9-af47-958260a5caad	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 04:24:00	2026-10-03 14:24:00	MANUAL
7cc2a1ad-f6c3-4093-8f37-ef37f88cd96b	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:29:00	2026-10-02 09:29:00	QR
db2aaec4-0e01-44a7-8a20-9e313db2a722	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 03:28:00	2026-10-01 13:28:00	MANUAL
21309cf3-0660-483e-ac2f-f85c3977bd84	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 04:28:00	2026-10-19 10:28:00	MANUAL
c7984168-8032-424d-9dec-521eebd3c595	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 03:39:00	2026-10-18 07:39:00	QR
b9b71086-199d-44e8-9449-fbe1ea2edffa	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 02:17:00	2026-10-16 12:17:00	MANUAL
71468895-81a6-41c1-8d99-d7b9396e368b	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:48:00	2026-10-15 07:48:00	QR
d817dcd9-648b-4d3d-bb15-01730e07f587	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 01:51:00	2026-10-14 05:51:00	QR
e10dc862-4752-4076-8abd-b05b124ed717	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 05:19:00	2026-10-13 11:19:00	MANUAL
e2fda511-6f37-474b-8c7c-cf47f30b3b49	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 05:20:00	2026-10-12 11:20:00	MANUAL
f1cc17c7-ca96-4f87-8afd-a66792f9e217	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:09:00	2026-10-10 07:09:00	MANUAL
faf567bf-9ea6-4790-9c27-a5a70a1fa8ea	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 05:14:00	2026-10-07 09:14:00	MANUAL
8093de30-c595-453b-a0f0-3430feb66955	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 02:52:00	2026-10-02 10:52:00	MANUAL
eb51a005-9bd2-4d5d-a6f1-3792da1bfba6	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:30:00	\N	MANUAL
e97e73d7-9308-4e4e-9b4c-23f9d51f3375	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:06:00	2026-10-17 15:06:00	MANUAL
4bac1db3-c78e-4460-9d2c-5aa66d78eebf	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 04:41:00	2026-10-12 10:41:00	MANUAL
8de80dad-33ab-425a-9529-8ca681065dd2	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-11 05:13:00	2026-10-11 13:13:00	QR
a6528128-5a2e-4bd2-829c-4bce447eeec3	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:16:00	2026-10-10 08:16:00	MANUAL
2b476f98-514c-4cc5-83f4-ada63c524458	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 03:18:00	2026-10-09 11:18:00	QR
e99a5aa8-a6e3-4cd4-af40-36a1e3d75945	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 05:25:00	2026-10-07 13:25:00	MANUAL
62c203c4-d0b7-4ce0-b1a5-c5044cc8157f	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 04:54:00	2026-10-05 08:54:00	MANUAL
dc9eeefa-69db-4c86-9c24-ba7b5f608337	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 02:52:00	2026-10-03 12:52:00	MANUAL
d61a95de-4934-42f8-a6ab-d68cb606f4a3	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 01:54:00	2026-10-01 05:54:00	MANUAL
060a8a27-1191-468d-9fcb-9fb3719d3587	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 02:06:00	\N	MANUAL
60868e91-aaff-4262-be96-fd703779bb33	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 03:02:00	2026-10-19 12:02:00	MANUAL
ad497a5d-a045-48a4-8491-59f60df3248d	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:31:00	2026-10-16 10:31:00	MANUAL
c56efd12-b03e-4f3c-8bbe-ae8c3e1319ab	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 03:27:00	2026-10-13 13:27:00	MANUAL
f49edfe0-4700-4498-897e-738781553ea9	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 02:54:00	2026-10-09 07:54:00	QR
68161012-fd0a-497f-a205-5e72e95a22c0	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:09:00	2026-10-08 11:09:00	MANUAL
9e87b647-b2fe-4418-98ea-e14bf07ef847	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 02:03:00	2026-10-07 09:03:00	MANUAL
c9968af2-88e9-4e18-9d6e-8c97cfb47fca	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 05:26:00	2026-10-06 14:26:00	MANUAL
1916910c-962f-48c9-98ff-3c47dc781729	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 05:07:00	2026-10-05 16:07:00	MANUAL
e5e1a63b-f76b-429e-b703-5e5dd14164e9	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 01:50:00	2026-10-04 10:50:00	QR
86618a0f-6273-41da-9e47-7d07aea6b1b1	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:18:00	2026-10-02 11:18:00	MANUAL
b2d0db3b-e6a0-4003-9d84-e5315cdf3e90	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 01:30:00	2026-10-01 11:30:00	MANUAL
52398d55-fd9a-4e7c-b98a-eafa90f9df96	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 01:56:00	\N	MANUAL
2dc4fe52-49b8-42ce-9be7-660a1a253124	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 03:36:00	2026-10-19 14:36:00	MANUAL
310c45f5-2afe-4bbe-82f7-30f1b52d9414	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-18 02:31:00	2026-10-18 11:31:00	MANUAL
b2ab8867-d6ab-47c7-8555-faa01b394517	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 04:29:00	2026-10-17 14:29:00	MANUAL
286a9317-f37e-4b59-be6f-c37d7275fecb	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-16 03:40:00	2026-10-16 07:40:00	MANUAL
c0a29166-e68e-41b3-9a0f-3937c38b1141	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-15 03:28:00	2026-10-15 10:28:00	MANUAL
b168e727-fb3e-4480-8148-179e9afcde92	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 04:12:00	2026-10-14 12:12:00	QR
0cb0b654-627b-42f1-9a83-caacb1d76aab	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-13 03:50:00	2026-10-13 07:50:00	MANUAL
43bf443d-ee31-4aeb-8d31-c45490c32e11	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 05:24:00	2026-10-12 09:24:00	QR
531618d4-fd9a-4da8-adb0-260567e02fba	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 02:43:00	2026-10-10 12:43:00	MANUAL
ac31aceb-4953-404e-b408-c94c39befa45	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-09 02:02:00	2026-10-09 12:02:00	MANUAL
c38fbc4b-3be1-4df7-81dd-3fd8fc21e046	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 02:39:00	2026-10-08 07:39:00	MANUAL
0e8aed4e-7799-48dc-a927-cb2a92b64f5a	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-06 02:15:00	2026-10-06 11:15:00	MANUAL
24db6fcc-ac4e-422b-a66e-9157887b6589	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 05:16:00	2026-10-04 16:16:00	MANUAL
669eedc4-a061-4311-84a8-ff4e350aa36f	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 05:11:00	2026-10-03 09:11:00	MANUAL
e10becef-8134-4a17-af15-afeb48ac0e38	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-02 03:12:00	2026-10-02 09:12:00	QR
fbdb4f72-6de1-461d-ba49-55bfb81a05a7	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 01:32:00	2026-10-01 07:32:00	MANUAL
704250b2-4549-4253-ab98-f16a6d2926e3	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-20 04:01:00	\N	MANUAL
ea1bae80-1bae-491a-b512-68005253546e	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-19 02:43:00	2026-10-19 09:43:00	QR
10c41791-1dfe-47a7-a963-e01a605b5f1b	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-17 02:12:00	2026-10-17 11:12:00	MANUAL
bfc8e734-60dd-4b0f-940d-bce56945e27c	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-14 05:26:00	2026-10-14 16:26:00	MANUAL
c53bb571-d864-4d86-b636-a62c8f7d4fb3	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-12 03:30:00	2026-10-12 08:30:00	MANUAL
65aac498-8ad6-48c5-bc4a-756261766db2	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-10 03:24:00	2026-10-10 09:24:00	QR
61560baa-13bb-4237-b3fe-7d622fc48dd3	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-08 03:35:00	2026-10-08 10:35:00	MANUAL
cec65d36-c5e4-4d67-9c0a-fb9d1f18f746	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-07 02:50:00	2026-10-07 08:50:00	QR
788aba2b-fd71-499c-a5d2-c6b8640113bb	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-05 02:54:00	2026-10-05 13:54:00	QR
00880034-3c91-4c59-97ec-d210cb46728b	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-04 01:36:00	2026-10-04 08:36:00	MANUAL
0a1743ca-a86d-4564-b657-ced34f25e07a	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-03 03:03:00	2026-10-03 11:03:00	MANUAL
2855e91d-e1d8-40af-9c64-3bfe170659ee	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	b38737cd-11f6-461a-9a07-8f91a478f6a2	2026-10-01 02:14:00	2026-10-01 07:14:00	MANUAL
cec36709-aed1-4c41-a4d9-2a6b1fce2dd5	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 01:59:00	\N	MANUAL
4c87638e-c8f6-4341-b8f0-e3df8e662254	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:35:00	2026-10-19 09:35:00	MANUAL
89968899-2980-459f-a15e-d327ec96b9ec	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 02:48:00	2026-10-16 10:48:00	MANUAL
e6e0a53b-e2d3-4e89-aabf-6a1052e74776	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:30:00	2026-10-15 10:30:00	MANUAL
13c34766-0c1d-4050-9967-e7d7c2c84a27	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 03:01:00	2026-10-14 14:01:00	MANUAL
9f8c641e-87ce-4a47-afb8-f1d12145f2f2	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 01:32:00	2026-10-13 12:32:00	MANUAL
859a6d80-1ece-4d1b-9819-a2beb4fd0bfe	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:15:00	2026-10-12 13:15:00	MANUAL
e9824fd0-ecbd-4fc1-b633-bda1cba850ed	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 03:37:00	2026-10-09 10:37:00	MANUAL
1aabe7a0-bc4f-47c6-9ebe-2b2ec87826f4	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 05:08:00	2026-10-08 13:08:00	QR
3962b282-29fc-47d6-948a-613633811664	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 04:08:00	2026-10-07 10:08:00	MANUAL
e09efc65-3078-42d2-bbcb-3dbabbb0dddd	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 02:25:00	2026-10-05 08:25:00	MANUAL
9d3e78ff-3882-4b59-aeff-a4e1b27d5b8c	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:27:00	2026-10-04 10:27:00	QR
e45f6c4b-b1e6-4f1d-b1dd-73c5b613584e	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 01:34:00	2026-10-03 08:34:00	MANUAL
f66229d2-d8aa-487e-be9a-55f5c1954f43	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 01:45:00	2026-10-01 06:45:00	MANUAL
7ddf97bb-ac26-4f73-adea-4fdda6ada86d	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 05:10:00	\N	MANUAL
6b7eeb38-7d90-401a-b36a-4428acc631db	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:24:00	2026-10-19 06:24:00	QR
771e3d52-c3bd-4ada-94bf-b3f547f14bf3	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 01:34:00	2026-10-17 12:34:00	MANUAL
1ba362bf-d538-479c-a22a-ef27f44aa816	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 04:04:00	2026-10-16 15:04:00	QR
babc08a3-8e14-4905-a92a-3878018ef9a6	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 01:38:00	2026-10-14 09:38:00	MANUAL
fe5ead24-6fa0-4613-922e-de7dee8e627f	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 03:32:00	2026-10-11 12:32:00	MANUAL
4bbaa894-1d95-478e-8741-80f8a03d68e4	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 03:37:00	2026-10-10 14:37:00	MANUAL
4f442d5c-6d49-4882-8552-9446def4f2d6	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 04:49:00	2026-10-09 13:49:00	QR
0289fdef-af0e-4806-9983-645fa44cd5b0	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 03:19:00	2026-10-07 08:19:00	MANUAL
4e011976-ff58-4c82-ac06-f8970220b0c6	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 03:12:00	2026-10-06 11:12:00	MANUAL
53451402-210c-438a-a1c3-62c368115dbd	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 03:10:00	2026-10-05 08:10:00	QR
fe15e0a5-3830-4d78-9340-e436c9ec4a52	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 05:21:00	2026-10-19 11:21:00	QR
885c3b1a-aaf0-40b1-b2ab-de61b4845733	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:15:00	2026-10-18 09:15:00	MANUAL
f820db71-d05c-4e01-aaa0-40043c86c258	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:48:00	2026-10-17 14:48:00	MANUAL
4c753eef-6f5e-4658-97f7-4f4045b86367	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 05:17:00	2026-10-15 11:17:00	MANUAL
928e54a7-e187-4a58-a1b0-507515c79e0c	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 05:16:00	2026-10-14 10:16:00	MANUAL
e384ff91-c9ec-4c04-a323-c4c11d4d2443	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:02:00	2026-10-13 12:02:00	MANUAL
64d34421-693a-45fd-8c30-021e91b3fde0	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:17:00	2026-10-12 09:17:00	QR
505af16d-ac96-4a78-be0b-537ae1d6e8db	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 05:27:00	2026-10-11 13:27:00	QR
889fedc5-bdaf-4031-8ffe-3b675102c525	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 02:01:00	2026-10-09 06:01:00	MANUAL
8fa6c3a5-a10a-4272-b453-c51065b9a535	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 03:21:00	2026-10-08 14:21:00	QR
9d28daad-5495-49ea-92c1-4b69c46c1af1	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 02:16:00	2026-10-07 12:16:00	MANUAL
7ae89b2c-53f5-44d2-850a-e04e0e74fd5e	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 03:39:00	2026-10-06 14:39:00	MANUAL
f4a8d8ba-253c-418a-9aff-a4931e430434	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:20:00	2026-10-05 14:20:00	MANUAL
7220f544-16d8-424b-b805-6acd281ab05d	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:51:00	2026-10-04 12:51:00	MANUAL
5c53e989-0d68-4467-bd2c-67e800094048	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 05:00:00	2026-10-03 09:00:00	MANUAL
367294ab-1932-43cc-9732-6ebd0b102c0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 01:33:00	2026-10-02 05:33:00	QR
0fe1292d-3a12-4a20-8a8f-59e754bf5445	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:03:00	2026-10-01 09:03:00	MANUAL
d0e3bcf2-a1f0-4eb3-82b0-bdda2aa5f752	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:56:00	\N	MANUAL
ed5eb541-c60e-4d5b-8452-c2a112858470	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:57:00	2026-10-19 09:57:00	QR
f24fc562-8612-4c24-aae4-355223bc251a	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 04:57:00	2026-10-18 14:57:00	MANUAL
c6911192-f3f5-4c68-91fc-83126c69dc59	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 02:25:00	2026-10-17 10:25:00	QR
3ddaa81a-2d7b-4f21-9db5-bbe18dcacc2f	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 05:15:00	2026-10-14 15:15:00	MANUAL
60e0c688-87e3-4b87-b594-4e2daaa8f225	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:40:00	2026-10-13 14:40:00	QR
26bebe02-1a73-41e1-b2c9-049b015150f1	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:36:00	2026-10-10 09:36:00	MANUAL
f97b7449-c6c4-45d7-bcca-fde62954ddab	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 03:50:00	2026-10-09 10:50:00	MANUAL
5d051abd-089f-4217-a5c8-f02d9a901aef	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 02:27:00	2026-10-06 13:27:00	MANUAL
baea3146-2f98-4a15-a06a-73f07671481d	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 01:58:00	2026-10-05 12:58:00	MANUAL
3ef27370-4a42-4128-9612-d4ee830b2af2	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 05:04:00	2026-10-04 11:04:00	MANUAL
3aabb943-9404-4b43-8170-881fbd6bc9fb	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 02:44:00	2026-10-03 06:44:00	QR
9078b96e-e2de-4ef7-940c-531bc4e1dc99	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:02:00	2026-10-02 09:02:00	MANUAL
2afb5b7d-12d1-49f3-8ab6-23f48f5faaed	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:21:00	2026-10-01 10:21:00	MANUAL
5f876700-39ef-4fd8-bc31-7188ebbc5fe1	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:42:00	\N	QR
89c4bbdd-16c9-4b9d-848a-1c79a9b7d4c7	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:15:00	2026-10-19 12:15:00	MANUAL
d0a9e339-7a91-4f51-bbc3-536934533297	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:30:00	2026-10-18 13:30:00	MANUAL
80be7ef3-f1b3-49d5-96af-dd5d01d6176b	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 01:34:00	2026-10-17 11:34:00	MANUAL
3c9bbb63-2620-4458-aeee-efd9378df0af	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 02:55:00	2026-10-16 12:55:00	MANUAL
e5fc1a58-0864-4843-b28c-d1a59835d29c	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:14:00	2026-10-15 08:14:00	MANUAL
3eecfea0-e0dd-4d63-a023-6fbfff5248ec	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 04:40:00	2026-10-14 14:40:00	MANUAL
358fc64f-36d0-4d3a-a74e-9a33e30a812a	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:36:00	2026-10-12 11:36:00	MANUAL
f1420c31-24d6-42f5-9ace-f4bc7a92fdbd	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 03:31:00	2026-10-07 11:31:00	MANUAL
a1036f93-9cbc-45aa-94fb-8b5e6e0482e4	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 03:07:00	2026-10-06 08:07:00	MANUAL
e444f683-cd10-4d41-9bed-1eda6b3c67a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:03:00	2026-10-05 10:03:00	MANUAL
9cac2138-ff10-4ea0-85ef-10589d9273a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 03:25:00	2026-10-03 08:25:00	MANUAL
0d20a783-3e03-462f-92af-2fa8124323c5	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 01:33:00	2026-10-02 10:33:00	QR
c0135d79-2a24-4ab9-a28f-4c235303330d	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 05:22:00	2026-10-01 09:22:00	MANUAL
1b03d168-25dc-4773-a408-f8e94dbdf8fe	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:48:00	\N	MANUAL
d2c8242c-2fab-4471-be71-bde997c08ee5	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 01:55:00	2026-10-19 09:55:00	QR
74f0ab0e-4631-46c1-a62c-ea8532ecebdc	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 01:36:00	2026-10-18 11:36:00	QR
31d7d81f-6077-4a09-95fd-636e39a23796	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:15:00	2026-10-17 09:15:00	QR
b5679616-daed-4bb9-ab10-900ef5cb81f7	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:44:00	2026-10-16 10:44:00	MANUAL
fcd57a21-cc4f-4aeb-a11b-841ca82cb24b	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:55:00	2026-10-15 11:55:00	MANUAL
1289f59d-a3e6-422f-a63c-ca3bae5b5923	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 04:37:00	2026-10-14 09:37:00	MANUAL
9ccbac61-a822-4e03-ba8c-67082de28a49	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:07:00	2026-10-10 14:07:00	MANUAL
68a7862f-e33b-4830-bc54-a5d3b7fe8ab3	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 04:35:00	2026-10-09 13:35:00	MANUAL
34d90621-441a-4cc1-bb98-604e98e59ecc	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 05:14:00	2026-10-07 09:14:00	MANUAL
b6d54331-55f2-4ae4-a79b-27ed79d07b3d	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 02:02:00	2026-10-06 09:02:00	QR
6c02bb1e-0296-4e5d-999c-3a50ea072759	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 04:34:00	2026-10-05 12:34:00	MANUAL
0b2a8f9d-d244-48f0-a498-97ac1109fa58	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:06:00	2026-10-04 09:06:00	QR
5f69171c-8b14-4889-a79d-18094acb60cc	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 02:29:00	2026-10-03 10:29:00	QR
e4d5e8e0-25ed-4a5d-9cb4-ed08d324b69b	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:17:00	2026-10-01 14:17:00	MANUAL
136b3755-ee8d-4537-8790-51bac05b3e9e	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:03:00	\N	QR
05c452bc-792d-4c75-8ab8-dc19addc7eaa	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:36:00	2026-10-19 13:36:00	MANUAL
76b25e0c-1d18-406e-bad3-89b48682bc26	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:59:00	2026-10-18 14:59:00	MANUAL
fb138c4d-de71-48cb-a61c-cfb161cda52d	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 05:13:00	2026-10-17 12:13:00	MANUAL
b0530268-acaa-4d2a-9315-7566ddb073ea	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:48:00	2026-10-15 13:48:00	MANUAL
bd752f33-a72b-4192-8c9f-fa54189944a2	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 02:32:00	2026-10-14 12:32:00	QR
c789f49e-4e62-4525-a12f-da092a17cf2b	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 02:53:00	2026-10-13 09:53:00	QR
a0644fb8-0aca-403c-bfda-6fa223a3cdfc	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:31:00	2026-10-12 15:31:00	MANUAL
d604e1a9-09dc-49d3-8cc5-9367b09468e0	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 02:03:00	2026-10-10 13:03:00	MANUAL
bad122bd-f0f6-408d-9aba-58e259807fa7	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 02:01:00	2026-10-08 06:01:00	MANUAL
9db46f45-e28b-409a-9766-0cd159b8ead0	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 01:53:00	2026-10-07 07:53:00	MANUAL
76a8b2ba-5413-4df6-8037-4fb3967dce83	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 04:26:00	2026-10-06 10:26:00	QR
3b5e2a53-97f7-443f-bfe4-983da827cd93	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 04:58:00	2026-10-05 09:58:00	MANUAL
fe31c51d-a565-4782-8b0b-b46c455109d8	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 01:34:00	2026-10-03 09:34:00	MANUAL
0f2b2c80-5205-482f-82c7-dcdae095eb34	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:48:00	2026-10-01 08:48:00	QR
fd96c93c-e403-4503-b66a-3c1940d2ebdc	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 01:35:00	\N	MANUAL
39d00609-fe37-4d6e-8818-dbbc48d3a4dc	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 01:59:00	2026-10-19 06:59:00	MANUAL
9c31fca6-8bca-46c9-81d9-3d06a091af4f	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:59:00	2026-10-18 08:59:00	QR
86dd9c7b-e586-4730-8500-25194fb00908	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 05:19:00	2026-10-17 13:19:00	MANUAL
9e713588-99ce-4a0a-bf6b-37845b49920c	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 02:55:00	2026-10-16 07:55:00	MANUAL
2638afa5-e8ba-4abf-9839-3c310e1c7f5a	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 01:51:00	2026-10-12 10:51:00	MANUAL
c612d8a6-604f-4aa3-b92b-559172a51a19	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 03:24:00	2026-10-11 14:24:00	MANUAL
e05aa969-43bd-4528-8efc-c7d40b9de0b9	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 04:16:00	2026-10-08 08:16:00	MANUAL
0da14dbc-2574-4c6c-934a-d5faacf57bb9	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:35:00	\N	QR
79a73782-5d83-4640-8470-9faee3d1a36c	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 04:17:00	2026-10-19 09:17:00	QR
33119db7-bcbb-4da7-b381-31ee9e6a0cbf	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 02:39:00	2026-10-17 10:39:00	MANUAL
d3cae7f8-034a-46c7-93cd-b2b8815cee01	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 02:50:00	2026-10-16 08:50:00	MANUAL
d7a5bdec-cce5-46c8-b56c-d3cfe3dd9053	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:01:00	2026-10-15 14:01:00	QR
875e2ba8-27ef-4c2a-92fc-52332ef7131a	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 03:14:00	2026-10-14 09:14:00	MANUAL
8a45bac0-ccca-43ab-aa0b-930b12bded2d	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 02:24:00	2026-10-13 09:24:00	MANUAL
0fa0fdcf-6e9c-41bb-b5ee-f4a5fbde8a21	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 03:18:00	2026-10-11 07:18:00	MANUAL
6964150f-6388-4129-b339-dbfc1523d173	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:34:00	2026-10-10 08:34:00	MANUAL
cd6f99f8-67a5-409e-8e9b-aa4ca70a80c5	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 05:20:00	2026-10-09 10:20:00	QR
bee27d82-ac41-462f-b96c-6974a556c3d3	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 02:26:00	2026-10-07 12:26:00	MANUAL
2ca018bb-3a5b-4c8c-956e-9e6c4c392e6d	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 01:43:00	2026-10-06 11:43:00	QR
aea5316b-d1b2-4d7b-bf5f-d4f19efb49c0	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:55:00	2026-10-04 12:55:00	QR
4a07d7b6-8272-4bad-b1e9-a04460a10425	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 03:13:00	2026-10-03 08:13:00	MANUAL
9236cfc0-24b1-456d-850d-62fe5e20b5f6	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 04:16:00	2026-10-02 10:16:00	QR
950559af-38be-445f-8f55-bad9a5fbdc34	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 04:06:00	2026-10-01 12:06:00	MANUAL
f54c34d8-30ef-4cbd-92b8-90fb07cca329	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:23:00	\N	QR
5a2a911c-c325-474c-80af-77c5e018af73	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:18:00	2026-10-19 14:18:00	MANUAL
cc83aac4-f5e8-4670-8770-a3fb1ab0fb0d	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:57:00	2026-10-18 07:57:00	MANUAL
9e252397-3831-4546-bf5d-bad4a45c6a64	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 01:45:00	2026-10-17 05:45:00	MANUAL
e9147bb7-bd9a-4aff-bd60-5a305e0c5f47	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:56:00	2026-10-16 09:56:00	MANUAL
2dc7e5a3-4365-4e63-97f1-9638390be948	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:39:00	2026-10-15 09:39:00	MANUAL
592024ed-841e-4040-bb62-f0874c89aa69	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 02:26:00	2026-10-13 13:26:00	MANUAL
c507ef3a-ce4b-4508-b0d4-684543c78c13	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 02:10:00	2026-10-12 06:10:00	MANUAL
d8ee515d-b021-4119-9a02-9f4bca9fba2c	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 05:18:00	2026-10-10 15:18:00	MANUAL
efaa26c8-cdca-46f0-be99-293985ce6fad	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 03:36:00	2026-10-08 07:36:00	MANUAL
5c87ab51-3f9e-406c-9d77-e9c8c17df208	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 01:48:00	2026-10-07 07:48:00	MANUAL
190da3af-915c-408f-85ba-3ed72ada3451	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 02:27:00	2026-10-06 06:27:00	MANUAL
a14348a4-7966-4808-819c-fc514e5d8469	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 04:46:00	2026-10-05 11:46:00	MANUAL
159d92dc-5267-4da5-9de6-6940a00d4b99	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 04:33:00	2026-10-03 13:33:00	MANUAL
6f8b12eb-512b-4ed0-871b-c5fe5dbccee9	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:18:00	2026-10-02 07:18:00	MANUAL
9b20ad9e-b6a5-41d4-9362-31c256e47875	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:52:00	2026-10-01 07:52:00	QR
271ecb1a-4190-4e01-8103-016f9c06e564	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:25:00	2026-10-19 08:25:00	MANUAL
25ac29ef-0544-4ac4-bb01-b14dd58a7cf5	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:08:00	2026-10-18 11:08:00	QR
82988f10-9742-45d5-9301-64a3462454f2	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 05:14:00	2026-10-17 14:14:00	MANUAL
b483fc3a-dbca-4363-b6de-b3003cc55f82	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 02:11:00	2026-10-16 10:11:00	MANUAL
3a68366f-8761-4574-9911-cc016a7568b4	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:09:00	2026-10-15 09:09:00	MANUAL
81a1a1b5-e6c0-4947-8226-c05963df4ac4	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 05:09:00	2026-10-14 16:09:00	QR
4bbda79e-58f0-4cf6-bfb0-42d18fa16b43	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:21:00	2026-10-12 14:21:00	MANUAL
98c96b8f-d262-4063-88f1-47927606c36a	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:12:00	2026-10-11 09:12:00	MANUAL
7185d8da-e4a1-4a5e-a971-0c52c26f30da	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:42:00	2026-10-10 15:42:00	MANUAL
e518fbce-a4c1-45cf-ac03-4a4462556a0b	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 05:16:00	2026-10-08 11:16:00	MANUAL
254428e9-0537-4e48-9b0a-18830925bac6	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 02:34:00	2026-10-07 12:34:00	QR
1f384684-67b8-4c5f-8e4e-05ab24362915	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 01:38:00	2026-10-06 09:38:00	QR
8eb4d074-9cfe-460e-a3c0-92fc598c6a21	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 03:09:00	2026-10-05 09:09:00	MANUAL
58b230cd-8e32-4553-b7e7-c34768bd86cb	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:57:00	2026-10-04 13:57:00	QR
6909f7a7-1cbc-478b-987d-82bcf6f2111c	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 03:12:00	2026-10-02 13:12:00	MANUAL
fdecb7e7-9eca-457a-8a79-2f63895088fe	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 05:15:00	2026-10-01 11:15:00	MANUAL
90f5b76f-ccce-4a36-b9bd-3d8f4db4b521	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 03:04:00	\N	MANUAL
0a0494d6-167f-4216-9195-349fc2382308	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 01:38:00	2026-10-19 11:38:00	QR
c70dfa94-f652-49fc-8216-500258b44fb4	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:12:00	2026-10-18 14:12:00	MANUAL
54075a57-4b9a-460c-b39c-8c8e399ae03e	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 05:07:00	2026-10-17 12:07:00	QR
ab11dafc-6234-4fa8-aba6-53d60aecdcb8	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:29:00	2026-10-16 12:29:00	MANUAL
96187f9f-c95c-417c-b758-0487ae46116a	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:12:00	2026-10-15 10:12:00	MANUAL
0f66cd2d-5cc7-4584-9cd4-c427095e3143	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:29:00	2026-10-10 09:29:00	MANUAL
b7896026-c7b2-4304-ab69-b0a98ed0b301	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 04:58:00	2026-10-08 09:58:00	QR
f23bfc68-f73b-4f1a-bd3c-1378d09397a9	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 05:19:00	2026-10-07 16:19:00	MANUAL
412bd301-1132-4ff4-a17d-d6ab0680faee	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 04:34:00	2026-10-05 14:34:00	QR
7ce54f8a-eb59-4d02-b6b3-d65d93d1524c	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 03:54:00	2026-10-02 11:54:00	MANUAL
ce8e9918-0d51-4df4-a697-f0c3dba450ed	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:31:00	2026-10-01 07:31:00	MANUAL
2e9b50ce-6607-46b0-bd60-6560ab7fbac8	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:50:00	\N	QR
8efb9dd0-7cd8-4749-b1f3-af876f0bb8d6	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:02:00	2026-10-19 09:02:00	MANUAL
5983cd07-0a32-4558-b491-67e00ddfeff2	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:41:00	2026-10-18 07:41:00	QR
3f9dcf7f-1163-43fd-b933-839e86445ebe	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:42:00	2026-10-16 13:42:00	QR
720f9776-8554-444e-aeb4-01fbc2ebc209	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:44:00	2026-10-15 10:44:00	MANUAL
4bd743ff-00e5-4fea-92a5-f84837202b10	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 02:36:00	2026-10-13 13:36:00	QR
327d338a-a226-44e9-a1e4-4a8cd44da523	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 03:47:00	2026-10-12 11:47:00	QR
ee053ca1-8158-4f69-ad24-59399edb7b20	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 04:12:00	2026-10-11 11:12:00	MANUAL
4da92044-b92e-4eb1-80bb-406927cb8c20	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 04:29:00	2026-10-10 12:29:00	MANUAL
b9ad3e6c-66ed-4135-9fe6-2dcace2b356a	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 02:51:00	2026-10-07 12:51:00	MANUAL
407ec305-a797-40eb-ba8d-c007f24d265c	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 02:15:00	2026-10-05 09:15:00	MANUAL
760f5cb9-c414-4ade-84e1-3dbb36b82548	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 02:19:00	2026-10-03 11:19:00	QR
66e00516-27bd-48b6-b047-8646dc5810d9	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 03:00:00	\N	MANUAL
7e2fc5f8-ed03-456c-a814-fa66e29736d7	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 01:52:00	2026-10-19 12:52:00	MANUAL
d4a88ea2-0491-4a45-b27a-c70813d937ba	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:25:00	2026-10-18 13:25:00	QR
e8bae48d-1fd0-4850-97dd-72410a970511	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 02:24:00	2026-10-17 08:24:00	MANUAL
45da246f-a44a-455e-820c-0efd2177c47b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 01:54:00	2026-10-16 08:54:00	MANUAL
2f15fa76-f63e-469f-bc70-6e474ef2777d	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 03:07:00	2026-10-13 08:07:00	QR
98cd9d80-b0a7-4a90-bfee-86fb9a318958	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 05:24:00	2026-10-12 10:24:00	MANUAL
e5268ed6-4372-4561-af67-757e59cde29d	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 02:42:00	2026-10-08 06:42:00	MANUAL
df6362e5-690c-4ff2-a932-4efffd0c8232	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 05:00:00	2026-10-06 16:00:00	QR
9e167123-8389-410a-b833-1976e63545f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 03:58:00	2026-10-03 14:58:00	QR
7db3761c-23df-4d34-bb38-ba54a552b7cb	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 04:46:00	2026-10-01 10:46:00	MANUAL
93ee9f13-7bc8-4322-ad37-f4a1341bc2cd	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:01:00	\N	QR
faccabe6-ef96-416e-a577-400adfe47997	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 04:38:00	2026-10-19 15:38:00	MANUAL
e2c1e483-5a3c-45fc-8c38-37d6581104f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:35:00	2026-10-18 12:35:00	MANUAL
dbf9b677-90cc-49ce-b8d6-51964fc26fd9	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 02:44:00	2026-10-17 13:44:00	QR
9b3af59b-0175-4ecb-ade8-f10ac0073cfa	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:06:00	2026-10-16 09:06:00	QR
21de8b21-9fd4-4a60-8c61-c3ed51b35e15	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:20:00	2026-10-15 13:20:00	MANUAL
bfebedee-60e3-4672-8c15-f2af3b38cd88	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 01:47:00	2026-10-14 12:47:00	MANUAL
facb4062-6ea0-4c1c-abbd-0ba07a05df3d	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 02:15:00	2026-10-12 09:15:00	MANUAL
e9ffa0ab-d5d9-463f-8697-ee7c37fc9715	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:54:00	2026-10-11 06:54:00	MANUAL
b0a4bdda-711b-44e8-98a3-fbd1ba46f92f	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 01:53:00	2026-10-06 06:53:00	MANUAL
ae73d924-ebd1-49a1-a186-df9922ba0b08	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:28:00	2026-10-05 15:28:00	QR
eb14bec3-d6cd-4bd3-8d43-0df2c98302e3	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 03:40:00	2026-10-04 12:40:00	MANUAL
36ce373f-e4b6-437d-973a-5ff35caf4365	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 02:20:00	2026-10-03 06:20:00	MANUAL
01d7c461-d3b4-48bf-8238-8333b1f7c30a	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 02:59:00	2026-10-01 13:59:00	MANUAL
86ad8ec3-6743-4186-9590-5a705a2d18b2	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:25:00	\N	MANUAL
fd7173e0-51bb-42fd-bb97-9c67c0661635	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:47:00	2026-10-19 12:47:00	MANUAL
bbf4bb54-3e4a-44f1-b7f5-dbc3d1d41dc4	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 04:16:00	2026-10-18 12:16:00	MANUAL
7aab8609-f34a-4d3b-85e1-3b17a80c68dc	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:48:00	2026-10-17 11:48:00	MANUAL
41353e78-141d-4f99-b13e-e367071ae35a	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 03:06:00	2026-10-16 08:06:00	QR
246673a9-9cd2-48aa-bd9a-508508a10140	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:42:00	2026-10-15 15:42:00	MANUAL
82335ddc-59ce-4137-8152-f5cfc0d022bb	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:26:00	2026-10-13 11:26:00	MANUAL
8c3e86f1-486b-49ba-b749-309d6e12f036	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 04:55:00	2026-10-12 12:55:00	MANUAL
f3158fdf-3578-465a-9f19-27600936e96d	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:28:00	2026-10-11 07:28:00	MANUAL
f5276251-9c87-4084-b292-748d81b4f1c3	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 04:38:00	2026-10-08 08:38:00	MANUAL
1dde1281-750a-4a95-89d6-e2163012a7c7	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 03:39:00	2026-10-07 10:39:00	MANUAL
601662a4-ac55-400a-8a49-a9d34bbc70bc	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 01:58:00	2026-10-05 08:58:00	MANUAL
b742ae7d-8fa1-4376-91be-13ebda1e5f51	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 01:41:00	2026-10-04 07:41:00	MANUAL
ffdbbaef-839e-4f09-81b9-abd8830da8cc	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 04:26:00	2026-10-03 08:26:00	MANUAL
4c289de1-e885-4005-89a0-0a34108d106a	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 04:48:00	2026-10-02 11:48:00	MANUAL
76c9aa8d-be13-46b4-b5f5-af93a9c15861	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:10:00	\N	MANUAL
52068d83-19a2-4f79-8c40-0e39fa11bd14	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:40:00	2026-10-19 09:40:00	QR
c79095fc-52c4-41c0-9cf8-54f466bc4634	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 05:27:00	2026-10-18 15:27:00	MANUAL
d4d3738b-cc6a-40cd-863d-bceb564ebb28	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:50:00	2026-10-15 07:50:00	QR
235ce3fd-2824-4e46-a15d-55fdce3cdb6c	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 04:26:00	2026-10-14 14:26:00	QR
1f21a74e-5da2-43bc-9399-4fb79c48eaf2	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 03:03:00	2026-10-12 10:03:00	MANUAL
9cbec6e0-c95f-48ce-83e8-f1b0d49c3ac8	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 01:58:00	2026-10-10 12:58:00	MANUAL
1705e833-d8ef-46c3-a039-770c4da2918a	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 03:30:00	2026-10-09 12:30:00	MANUAL
0e7473da-e304-4920-b059-18db90b71794	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 01:53:00	2026-10-07 08:53:00	MANUAL
6f37c046-6f27-4a91-800a-c8be201bd6e7	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 04:57:00	2026-10-06 10:57:00	MANUAL
dec4922c-d74b-4dea-bada-a103fc34a3e4	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:02:00	2026-10-02 08:02:00	MANUAL
2b278859-ad3e-4464-a7d0-45d2fb50cda2	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 03:24:00	2026-10-01 07:24:00	MANUAL
0d2a40e5-fb43-48b3-bd45-b5358269e831	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:52:00	\N	MANUAL
8adb7edc-a7ca-4862-915b-dc295ca6afdf	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 04:46:00	2026-10-19 12:46:00	QR
893e5192-efa5-4df9-9a82-dea9a5a55d3f	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 04:38:00	2026-10-18 10:38:00	MANUAL
c783d059-4eb3-4515-8f5b-0be6813103da	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 02:00:00	2026-10-17 09:00:00	QR
ed71da4e-464b-453c-9308-d26e30f09fed	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 01:35:00	2026-10-16 07:35:00	MANUAL
84be4fa3-279e-43bc-8048-608cd3b9c97c	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:54:00	2026-10-15 09:54:00	QR
8f203c47-a929-4e8b-a580-00d8bb3b88ee	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 04:58:00	2026-10-14 09:58:00	QR
0c420b7a-a48b-48fb-bf4b-72956678d9d8	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 02:03:00	2026-10-13 10:03:00	QR
6a0fc923-a88f-49a9-879a-2cb098957344	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:08:00	2026-10-11 09:08:00	QR
26780c30-945c-4168-a9fe-48da6eb66a9d	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 02:14:00	2026-10-10 10:14:00	MANUAL
157c37eb-862c-400d-9a08-14dee3d7ae79	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 03:35:00	2026-10-08 10:35:00	MANUAL
642c3a68-5b11-45fa-94d8-6109446e0753	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 05:11:00	2026-10-07 10:11:00	QR
0e0770b4-318e-4877-92ac-8bc851e4a4fb	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 04:14:00	2026-10-06 09:14:00	MANUAL
b75198eb-8fbc-48ba-a4e1-1fd2b116c94f	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 03:47:00	2026-10-05 07:47:00	QR
5ef9aa95-8756-4c20-bdbb-3051ae925e66	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:40:00	2026-10-02 08:40:00	MANUAL
3f60b253-f541-45b8-8fa7-35d21f2fdbc0	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 01:32:00	2026-10-01 10:32:00	QR
201abe00-bbeb-4098-a6a2-86ace808b652	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:43:00	\N	MANUAL
cd73175c-a891-4cf0-b946-424fac2b613a	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:01:00	2026-10-19 12:01:00	MANUAL
26b094c5-58b1-42e3-9d0b-ddd3bee2def1	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 04:13:00	2026-10-18 08:13:00	MANUAL
b148ec10-0943-4447-86e6-06080bd6115a	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 05:13:00	2026-10-16 12:13:00	MANUAL
c1b239cf-50d7-45c3-a0ba-ed994996fa1e	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 04:23:00	2026-10-15 09:23:00	QR
48d5adaa-aded-4d7a-86e8-01078148f7aa	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 02:08:00	2026-10-14 08:08:00	MANUAL
a87cae06-9c61-43e0-b1c2-3507e36e7e45	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 05:01:00	2026-10-13 09:01:00	MANUAL
905cbe86-875a-4ff6-ab2e-f406ee972ef8	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 05:13:00	2026-10-12 13:13:00	QR
29a2ace5-9c92-46a3-93f1-57f473ff4d6c	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:39:00	2026-10-11 09:39:00	MANUAL
97f1d652-f2a6-464d-9555-b614fe3b4521	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 03:50:00	2026-10-10 12:50:00	QR
42fc0fc7-685d-4c97-b9c3-d041fde10c22	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 03:39:00	2026-10-09 07:39:00	MANUAL
65bb3a3c-b705-4bf4-b514-0b0c31630247	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 05:00:00	2026-10-08 13:00:00	MANUAL
922fcf54-db8e-4c06-859f-ffe589da4510	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 03:20:00	2026-10-07 11:20:00	MANUAL
f535bd06-b3dd-45dd-8d1a-2efa8eed91b8	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 04:52:00	2026-10-06 13:52:00	QR
f12800a5-8014-4c54-bfce-3e55dbf0c6eb	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 01:39:00	2026-10-05 06:39:00	MANUAL
86ba92d2-0012-48e6-a2ef-45db3cd2a06c	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 01:46:00	2026-10-03 05:46:00	MANUAL
e95267ec-d1db-41b9-a366-6afe9211c410	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:07:00	2026-10-02 13:07:00	QR
26d238b2-1cef-439c-bfcc-5f76ab653e65	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 03:32:00	\N	QR
5fc8b78a-7f92-47a9-bede-7f979d3c0b4b	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:47:00	2026-10-19 12:47:00	MANUAL
38128b5c-a0f4-4e30-9bf3-b454495fe57e	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 03:00:00	2026-10-18 08:00:00	QR
3ed9630f-c844-43d5-a28f-5ba794df5ed2	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 05:07:00	2026-10-17 14:07:00	QR
817fd94f-0fd3-4f72-8d2b-f8ac728026a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:47:00	2026-10-15 09:47:00	MANUAL
22808ee4-afb2-45c9-8858-f4b507ddda03	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:40:00	2026-10-13 15:40:00	MANUAL
209f4865-58e0-46eb-ab02-2c9b01882863	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 02:44:00	2026-10-12 11:44:00	MANUAL
64620c57-fc9b-40da-b1ed-8fe6a80bd3c0	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 04:10:00	2026-10-11 15:10:00	MANUAL
0df258bf-9212-4619-a4bf-c88f5dace636	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 02:42:00	2026-10-10 13:42:00	QR
d568779a-e649-48f3-a818-3970e2b8b181	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 05:08:00	2026-10-09 12:08:00	MANUAL
ad620f7e-9024-4668-b79d-0030b3ed8789	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 03:54:00	2026-10-08 12:54:00	MANUAL
3954bcdb-bc04-4548-8d4a-7bc1642e7727	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 04:20:00	2026-10-07 11:20:00	MANUAL
883f9a25-9e9c-4c7e-a829-c40f0f5383f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 03:46:00	2026-10-05 14:46:00	QR
bd5fad93-65c6-4430-8d85-336691789cae	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 05:25:00	2026-10-03 12:25:00	QR
7b519f3b-f2da-45c0-851e-e3571249437e	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 04:48:00	2026-10-01 11:48:00	MANUAL
fe0c14f5-1109-4cf6-95a5-4da7b0a56571	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 04:12:00	\N	MANUAL
f9fcafa7-767e-445f-9573-ee87af17d0e3	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 04:45:00	2026-10-16 09:45:00	MANUAL
3fe4ab6c-5067-4bdd-99e7-b34b70c68d1f	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:49:00	2026-10-15 08:49:00	MANUAL
86d9ebbb-591a-4068-a356-87e2593aa39d	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 03:59:00	2026-10-14 07:59:00	QR
648a2b8b-81c0-41f2-959d-e004424e5d07	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:33:00	2026-10-13 13:33:00	QR
c9980d95-468f-460f-bca4-40515f5a5da0	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 05:01:00	2026-10-12 09:01:00	MANUAL
5d30cd68-2f16-4165-afd5-bf1c914ee6b8	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 04:14:00	2026-10-11 08:14:00	MANUAL
cd873e48-35e6-4164-9c86-38b4759cfe92	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 01:33:00	2026-10-09 08:33:00	MANUAL
1c4465dc-9689-427b-a9e4-3fb9236576c7	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 04:02:00	2026-10-08 11:02:00	MANUAL
0852b630-e599-47e4-9f18-bbe4ffe18859	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 03:59:00	2026-10-07 11:59:00	MANUAL
11bd5a66-5a37-49e0-bf0e-5147e464abc5	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 05:21:00	2026-10-06 11:21:00	QR
9d87b670-cb83-4056-a5ee-534c07b382d6	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:02:00	2026-10-05 16:02:00	QR
262b1772-4b5c-4e8f-bd9c-d6c8bd97a2d1	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 01:31:00	2026-10-03 12:31:00	MANUAL
7dbe2b2d-6b1c-4f00-b2ec-dbf1cc12b79c	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 02:16:00	2026-10-02 07:16:00	QR
7b2babe6-c57f-443c-b36f-643b1ee87ba1	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 05:15:00	2026-10-01 11:15:00	MANUAL
9411d126-ee01-4a25-9d46-1e670215511d	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:52:00	2026-10-19 13:52:00	MANUAL
3b4c329c-4cb0-4464-842d-26e350a8a95d	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:05:00	2026-10-18 08:05:00	MANUAL
2372dc97-1ec4-41ee-a095-038d018781a2	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:56:00	2026-10-17 09:56:00	MANUAL
b8d27979-3e85-4695-9a5d-868b220ecedf	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 04:01:00	2026-10-16 08:01:00	MANUAL
c6ca2c30-2176-44f2-9b04-2ff7ae591a0e	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 02:19:00	2026-10-15 13:19:00	MANUAL
d94acb3f-4720-428f-94a4-96a571f856ed	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 02:40:00	2026-10-14 13:40:00	MANUAL
5998d635-128b-4d1b-b5e1-3aab7d613d2d	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 03:07:00	2026-10-13 13:07:00	MANUAL
1aded288-9354-446e-9c3a-3860db057bfc	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 04:47:00	2026-10-11 12:47:00	MANUAL
25d7430f-5317-4b49-88c6-9d8c2a92216c	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 03:02:00	2026-10-10 09:02:00	MANUAL
9f8d4801-ff04-464d-ba48-8072c3cb9b37	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 04:20:00	2026-10-09 11:20:00	MANUAL
c4cbb907-b55e-41bd-9f08-8796a1cdd534	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 01:32:00	2026-10-07 08:32:00	MANUAL
79675e3e-139d-4768-8216-8da7b4213202	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 02:42:00	2026-10-05 10:42:00	MANUAL
6ffa7075-de1a-4a4b-9529-c204c6399f51	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 02:43:00	2026-10-04 07:43:00	MANUAL
1217edfc-7821-4075-836a-ad6477cf928d	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 04:36:00	2026-10-02 09:36:00	MANUAL
885a1c6a-e634-4b23-8890-0c2b1149010a	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:01:00	\N	MANUAL
40b397b3-d299-47d9-a294-a43384b2af2b	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:34:00	2026-10-19 07:34:00	QR
2c1db21d-4c8d-4c8e-b5dd-7cea281b78bd	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 05:11:00	2026-10-18 16:11:00	MANUAL
5b040653-d26e-4faf-94e0-cdd62ffdc3c8	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 04:05:00	2026-10-16 15:05:00	QR
42db7dee-ab9b-4c7d-87e7-e195d06013db	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:41:00	2026-10-15 09:41:00	QR
d3bb821c-e337-40d5-87d1-e02faca94ae2	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 03:08:00	2026-10-14 14:08:00	QR
04eb6c7f-b66b-41ac-8d0a-30e47cb94627	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 03:15:00	2026-10-13 13:15:00	MANUAL
7c45d953-0936-4262-b49e-3a3ddce24fd8	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 02:55:00	2026-10-11 07:55:00	MANUAL
dcce119c-7d1e-4d82-a799-8c72691bcf67	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 03:53:00	2026-10-10 07:53:00	QR
f4e5ed9a-12ef-42ed-a48f-0aa41c3c2ba3	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 01:59:00	2026-10-08 05:59:00	MANUAL
65d75bab-7921-4f04-9aae-3bd069cd1f2f	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 04:57:00	2026-10-06 12:57:00	MANUAL
b15d9c64-294c-45a3-9aa1-beffad1047eb	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 03:38:00	2026-10-05 09:38:00	QR
54d86cd2-808e-4ab9-94d3-55bc513a2a1c	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 01:50:00	2026-10-04 11:50:00	MANUAL
26f56002-534b-4cb0-877a-d8473252019b	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 05:20:00	2026-10-03 16:20:00	QR
b26d6d28-13ed-4eac-8e28-70f377ea08de	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 04:02:00	2026-10-02 13:02:00	MANUAL
ab7ca98c-8c3d-4664-88a9-79edeaa22f50	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 02:40:00	2026-10-01 09:40:00	MANUAL
96997a99-11a8-4c0a-a77f-505a3a2c0344	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 03:55:00	\N	MANUAL
3ddc4287-f08a-41bd-a041-ed81a61dad7c	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 03:13:00	2026-10-19 11:13:00	MANUAL
c0b7c8a1-2862-4292-88a8-fa4f7d6e897f	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-18 02:38:00	2026-10-18 06:38:00	MANUAL
78b0c92b-b035-42ab-b144-8a5372add701	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:56:00	2026-10-17 09:56:00	MANUAL
a993346d-023e-4472-bcd2-01e3890681ee	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-16 05:06:00	2026-10-16 10:06:00	MANUAL
b4b047e0-b5f5-41d0-8d49-da76bf1b0a2c	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 01:48:00	2026-10-15 08:48:00	QR
6fd6620d-a780-4a9b-a53a-1950b8183fa6	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 03:27:00	2026-10-14 13:27:00	QR
1921defe-47db-441d-8370-289a650e2937	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 04:35:00	2026-10-13 12:35:00	QR
1304ebe4-9dab-4fbf-b9d7-7ba6969e3479	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-11 03:34:00	2026-10-11 13:34:00	MANUAL
5145b6ae-b3c1-47a7-90c6-8abddd2eb8a5	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 05:24:00	2026-10-10 09:24:00	MANUAL
edd27f62-3262-41ac-901c-c6f36e880e9f	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 02:39:00	2026-10-08 12:39:00	QR
59d50be3-c31c-499e-b434-236948354f1b	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-06 01:40:00	2026-10-06 08:40:00	MANUAL
f16e7f85-e792-4f38-b011-f9a662c81d67	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:23:00	2026-10-05 11:23:00	QR
e305a713-b5f8-4a85-b390-41a9b91e1d18	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 03:39:00	2026-10-04 12:39:00	MANUAL
9f47aee8-0665-47a6-bd54-1402e3d817aa	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 03:50:00	2026-10-03 09:50:00	MANUAL
6dd41f70-11d7-49ef-90cf-24d78ed031fd	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-02 03:07:00	2026-10-02 12:07:00	MANUAL
0123ed2b-a031-4924-9748-de1e28d664f0	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-20 02:20:00	\N	QR
5ffd10d6-6233-4234-bf6e-fcd0f8f965a1	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-19 02:21:00	2026-10-19 08:21:00	MANUAL
b83bb4bc-b024-43a1-b067-4213a6765464	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-17 03:04:00	2026-10-17 13:04:00	MANUAL
7fee43cd-9e2f-4c48-8ebd-fa91bd8cb839	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-15 03:52:00	2026-10-15 09:52:00	QR
06b25196-02ea-4909-9c68-8285ef4c2ac5	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-14 04:03:00	2026-10-14 14:03:00	MANUAL
460891c9-5016-4aff-8695-0ef7e79f101f	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-13 03:10:00	2026-10-13 07:10:00	MANUAL
0a61acf3-8018-45ee-b863-1022bae0a076	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-12 03:00:00	2026-10-12 13:00:00	MANUAL
6db15fae-a1bc-4541-8f6f-ff7ddab94074	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-10 02:05:00	2026-10-10 08:05:00	MANUAL
a1b08993-b926-4fb7-a8ac-b8f3d7c8b5f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-09 03:36:00	2026-10-09 10:36:00	MANUAL
c280a8a4-cae0-4003-a2cc-405ae18e5caa	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-08 03:43:00	2026-10-08 11:43:00	MANUAL
a32b7a42-4bc4-4b0a-b2aa-34b33194a56e	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-07 02:54:00	2026-10-07 06:54:00	MANUAL
7d5f9d1d-68c8-449a-87d7-ac92d64bbf02	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-05 05:02:00	2026-10-05 10:02:00	MANUAL
504f496f-8337-4eb0-b161-298e9980c3de	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-04 03:59:00	2026-10-04 10:59:00	MANUAL
6b8d909f-0406-4793-8a5e-a9d918702693	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-03 02:15:00	2026-10-03 10:15:00	QR
a720a94f-d1f9-4769-844a-d4b4a6bc7346	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	f859edc4-7244-4ac9-9b76-33a1fc6589d8	2026-10-01 04:45:00	2026-10-01 08:45:00	QR
\.


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."AuditLog" (id, "tenantId", "userId", "branchId", action, entity, "entityId", metadata, "createdAt") FROM stdin;
c723b3f8-a6a8-4097-8400-ca17760d4432	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	b38737cd-11f6-461a-9a07-8f91a478f6a2	UPDATE_COMPLAINT_STATUS	Complaint	8f270441-c102-4f68-ae72-1da5edcc9b3e	{"complaintId":"CMP-1003","oldStatus":"UNDER_REVIEW","newStatus":"UNDER_REVIEW","resolution":"Staff investigating","internalNotes":"Automated E2E test verification notes","whatsappSent":false,"admin":"Admin"}	2026-10-19 20:56:22.04
7926dbf7-5d82-45df-95ee-94a7c7e711b0	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	b38737cd-11f6-461a-9a07-8f91a478f6a2	UPDATE_COMPLAINT_STATUS	Complaint	8f270441-c102-4f68-ae72-1da5edcc9b3e	{"complaintId":"CMP-1003","oldStatus":"UNDER_REVIEW","newStatus":"UNDER_REVIEW","resolution":"Staff investigating","internalNotes":"Automated E2E test verification notes","whatsappSent":false,"admin":"Admin"}	2026-10-19 20:57:32.075
b51723af-63a8-4fb4-a2be-c72179550f2f	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	b38737cd-11f6-461a-9a07-8f91a478f6a2	DEALLOCATE_SEAT	Seat	080176c7-ce58-4a7f-ba60-653a69205d08	{"seatNumber":"K01","reason":"E2E Verification Test","admin":"Admin","membersAffected":[{"id":"80a9b93b-35af-4261-bd10-b6f34294d64c","name":"Aarav Mishra"}]}	2026-10-19 20:57:32.135
b1cfb8db-5fb9-4b5f-af4b-7e5b64d58451	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	f859edc4-7244-4ac9-9b76-33a1fc6589d8	DEALLOCATE_LOCKER	Locker	7ad752a0-8b3c-4a05-a322-def86fc01272	{"lockerNumber":"L01","reason":"E2E Verification Test","admin":"Admin","membersAffected":[{"id":"da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11","name":"Aarav Pandey"}]}	2026-10-19 20:57:32.19
88308392-746f-4f1d-b795-1fdfb1e69669	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	b38737cd-11f6-461a-9a07-8f91a478f6a2	UPDATE_COMPLAINT_STATUS	Complaint	8f270441-c102-4f68-ae72-1da5edcc9b3e	{"complaintId":"CMP-1003","oldStatus":"UNDER_REVIEW","newStatus":"RESOLVED","resolution":"Staff investigating and resolved","internalNotes":"Automated E2E test verification notes","whatsappSent":true,"admin":"Admin"}	2026-10-19 20:59:39.313
7017b775-c92c-4dd6-80a5-df1bffd6d201	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	f859edc4-7244-4ac9-9b76-33a1fc6589d8	DEALLOCATE_SEAT	Seat	4f18879e-11d8-46f4-bec7-4cf7849f9b7a	{"seatNumber":"M01","reason":"E2E Verification Test","admin":"Admin","membersAffected":[{"id":"da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11","name":"Aarav Pandey"}]}	2026-10-19 20:59:39.345
091477c8-ce08-4be6-bc45-434c328685a3	bc1c3e43-9c01-4f17-9b81-39430c671e34	\N	b38737cd-11f6-461a-9a07-8f91a478f6a2	DEALLOCATE_LOCKER	Locker	74c58e12-17db-4be5-99cd-22deb8b054d5	{"lockerNumber":"L01","reason":"E2E Verification Test","admin":"Admin","membersAffected":[{"id":"80a9b93b-35af-4261-bd10-b6f34294d64c","name":"Aarav Mishra"}]}	2026-10-19 20:59:39.369
\.


--
-- Data for Name: BackupLog; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."BackupLog" (id, "tenantId", "backupName", "filePath", "fileSize", "itemCount", status, "triggerType", details, "errorMsg", "createdAt", "completedAt", "restoredAt", "restoredBy") FROM stdin;
63b567ce-60a2-4f77-b9bd-f986c693c04c	\N	backup_2026-10-21T06-29-10-273Z	Z:\\Official\\Projects\\ChintaMani Library\\apps\\backend\\backups\\backup_2026-10-21T06-29-10-273Z.sql	0	0	RUNNING	MANUAL	\N	\N	2026-10-21 06:29:10.276	\N	\N	\N
\.


--
-- Data for Name: Branch; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Branch" (id, "tenantId", name, address, phone, "createdAt", "updatedAt") FROM stdin;
b38737cd-11f6-461a-9a07-8f91a478f6a2	bc1c3e43-9c01-4f17-9b81-39430c671e34	Chintamani Library – Khalilabad	Main Road, Khalilabad, Sant Kabir Nagar, UP 272175	9876543210	2026-10-19 20:54:36.325	2026-10-19 20:54:36.325
f859edc4-7244-4ac9-9b76-33a1fc6589d8	bc1c3e43-9c01-4f17-9b81-39430c671e34	Chintamani Library – Mehdawal	Station Road, Mehdawal, Sant Kabir Nagar, UP 272202	9876543211	2026-10-19 20:54:36.328	2026-10-19 20:54:36.328
dd04734e-f0cf-49a7-b956-3c655518a8a9	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	City Reading Hub – Central	Hazratganj, Lucknow, UP 226001	9811223344	2026-10-19 20:54:38.721	2026-10-19 20:54:38.721
\.


--
-- Data for Name: CommunicationLog; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."CommunicationLog" (id, "tenantId", channel, recipient, message, status, "createdAt") FROM stdin;
245c7520-5349-4b01-b276-4b12ddba694e	\N	WHATSAPP	+919866872239	Dear Aarav Mishra,\n\nYour complaint #CMP-1003 regarding WIFI has been marked as RESOLVED by the library administration.\n\nResolution Details: Staff investigating and resolved\n\nThank you for your patience and for helping us maintain Chintamani Library.\n\nWarm regards,\nChintamani Library Administration	SENT	2026-10-19 20:59:39.305
\.


--
-- Data for Name: Complaint; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Complaint" (id, "tenantId", "branchId", "complaintId", "memberId", "memberName", "memberPhone", category, description, "attachmentUrls", status, resolution, "assignedTo", "resolvedAt", "createdAt", "updatedAt", "internalNotes", "statusHistory", "whatsappMessageId", "whatsappSentAt") FROM stdin;
5a799fb3-c870-463a-8e50-e51f9b46fa1f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CMP-1001	80a9b93b-35af-4261-bd10-b6f34294d64c	Aarav Mishra	9866872239	AIR_CONDITIONER	The AC cooling in Hall A is insufficient between 2 PM and 4 PM.	\N	SUBMITTED	\N	\N	\N	2026-10-18 20:55:01.352	2026-10-19 20:55:01.357	\N	\N	\N	\N
5c4d0f61-8680-4a59-95a2-281bf0d34579	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CMP-1002	80a9b93b-35af-4261-bd10-b6f34294d64c	Aarav Mishra	9866872239	SEATS	Chair armrest on Seat K14 is loose and requires tightening.	\N	IN_PROGRESS	\N	\N	\N	2026-10-19 08:55:01.352	2026-10-19 20:55:01.367	Carpentry staff assigned on morning shift.	\N	\N	\N
3ee10662-5c4f-4900-af3f-50696a071b08	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CMP-1004	80a9b93b-35af-4261-bd10-b6f34294d64c	Aarav Mishra	9866872239	CLEANLINESS	Desk surface on study bay was cleaned and sanitized.	\N	RESOLVED	Sanitization team cleaned and polished the desk bay.	\N	\N	2026-10-17 20:55:01.352	2026-10-19 20:55:01.38	Completed by housekeeping lead.	\N	\N	2026-10-19 20:55:01.352
8f270441-c102-4f68-ae72-1da5edcc9b3e	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CMP-1003	80a9b93b-35af-4261-bd10-b6f34294d64c	Aarav Mishra	9866872239	WIFI	High latency and intermittent disconnection on second floor AP.	\N	RESOLVED	Staff investigating and resolved	\N	2026-10-19 20:59:39.295	2026-10-19 14:55:01.352	2026-10-19 20:59:39.31	Automated E2E test verification notes	[{"fromStatus":"UNDER_REVIEW","toStatus":"UNDER_REVIEW","adminName":"Admin","adminId":null,"timestamp":"2026-10-19T20:56:22.028Z","resolution":"Staff investigating","internalNotes":"Automated E2E test verification notes"},{"fromStatus":"UNDER_REVIEW","toStatus":"UNDER_REVIEW","adminName":"Admin","adminId":null,"timestamp":"2026-10-19T20:57:32.056Z","resolution":"Staff investigating","internalNotes":"Automated E2E test verification notes"},{"fromStatus":"UNDER_REVIEW","toStatus":"RESOLVED","adminName":"Admin","adminId":null,"timestamp":"2026-10-19T20:59:39.295Z","resolution":"Staff investigating and resolved","internalNotes":"Automated E2E test verification notes"}]	wa-mock-1792443579302	2026-10-19 20:59:39.308
\.


--
-- Data for Name: Enquiry; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Enquiry" (id, "tenantId", "branchId", name, phone, email, status, "followUpDate", notes, "createdAt", "updatedAt") FROM stdin;
11050cca-b378-4f50-9fd6-dc165617d6f1	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Rohit Mehra	9880523299	rohit@gmail.com	NEW	2026-10-23 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.591	2026-10-19 20:54:38.591
ba7d8b50-7f80-4831-bc7b-c34bb2ed8528	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Ankita Jain	9816170684	ankita@gmail.com	CONTACTED	2026-10-21 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.595	2026-10-19 20:54:38.595
827a968b-ed8e-40e9-9780-20e36a7eee51	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Vikram Rathore	9871462950	vikram@gmail.com	INTERESTED	2026-10-20 20:54:36.661	\N	2026-10-19 20:54:38.597	2026-10-19 20:54:38.597
9dbf7f4f-dc8c-468a-a6f0-dbafbd74202a	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Simran Kaur	9874300190	simran@gmail.com	CONVERTED	2026-10-18 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.6	2026-10-19 20:54:38.6
7d67563c-4421-4b95-982c-f77acb14f8b0	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Mohit Agarwal	9833550490	mohit@gmail.com	NOT_INTERESTED	2026-10-18 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.602	2026-10-19 20:54:38.602
fa6d229d-58fc-4d38-9962-f239c99970d3	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Nisha Patel	9894284278	nisha@gmail.com	NEW	2026-10-20 20:54:36.661	\N	2026-10-19 20:54:38.605	2026-10-19 20:54:38.605
e69edb11-70b2-45ac-9531-f1dd4ba9b5da	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Harsh Vardhan	9892358826	harsh@gmail.com	CONTACTED	2026-10-17 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.607	2026-10-19 20:54:38.607
ae07b898-47d0-4628-939e-9ec8a70c30ca	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Meera Iyer	9860271568	meera@gmail.com	INTERESTED	2026-10-21 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.61	2026-10-19 20:54:38.61
9fe0d89f-ce37-41f6-8a60-faf79c14bf70	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Sanjay Dubey	9834543272	sanjay@gmail.com	CONVERTED	2026-10-22 20:54:36.661	\N	2026-10-19 20:54:38.612	2026-10-19 20:54:38.612
51d004e1-35f9-4dc6-b9af-2efa1d3eb96a	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Komal Tiwari	9869533210	komal@gmail.com	NOT_INTERESTED	2026-10-20 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.614	2026-10-19 20:54:38.614
c172723b-578b-4b3b-abf8-df112ff162f7	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Rohit Mehra	9863107325	rohit@gmail.com	NEW	2026-10-22 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.617	2026-10-19 20:54:38.617
eb68b7f0-8d11-43db-b117-c386e50f063a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Ankita Jain	9884217558	ankita@gmail.com	CONTACTED	2026-10-20 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.619	2026-10-19 20:54:38.619
7ff63369-d773-4e6a-a19a-968699fcbd5b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Vikram Rathore	9880762703	vikram@gmail.com	INTERESTED	2026-10-23 20:54:36.661	\N	2026-10-19 20:54:38.622	2026-10-19 20:54:38.622
614e9c81-a0a8-47ba-a4e0-419ea5b1bcb6	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Simran Kaur	9836297435	simran@gmail.com	CONVERTED	2026-10-18 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.624	2026-10-19 20:54:38.624
662c9737-5151-4927-81c1-4a58f38fbe80	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Mohit Agarwal	9861149742	mohit@gmail.com	NOT_INTERESTED	2026-10-19 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.627	2026-10-19 20:54:38.627
3e6bdb51-9c96-4da0-b31d-891ff3ab877e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Nisha Patel	9864452789	nisha@gmail.com	NEW	2026-10-23 20:54:36.661	\N	2026-10-19 20:54:38.63	2026-10-19 20:54:38.63
42ddb71f-cd7b-4bc9-88ae-dd466ea431c1	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Harsh Vardhan	9882108184	harsh@gmail.com	CONTACTED	2026-10-21 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.632	2026-10-19 20:54:38.632
3463b66e-733f-490b-82a3-07aaefb58619	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Meera Iyer	9871953538	meera@gmail.com	INTERESTED	2026-10-18 20:54:36.661	Wants locker facility	2026-10-19 20:54:38.635	2026-10-19 20:54:38.635
b76f8b12-179a-4f57-92fb-baf9da6b9e7e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Sanjay Dubey	9838250378	sanjay@gmail.com	CONVERTED	2026-10-22 20:54:36.661	\N	2026-10-19 20:54:38.638	2026-10-19 20:54:38.638
58c33519-8ba8-479c-b809-835546db492c	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Komal Tiwari	9868288767	komal@gmail.com	NOT_INTERESTED	2026-10-17 20:54:36.661	Interested in monthly plan	2026-10-19 20:54:38.64	2026-10-19 20:54:38.64
\.


--
-- Data for Name: Expense; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Expense" (id, "tenantId", "branchId", category, amount, description, date, "createdAt", "updatedAt") FROM stdin;
86bf4be4-3dc5-4776-a814-4617cd15e22a	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	ELECTRICITY	2283	Electricity expense	2026-10-14 20:54:36.661	2026-10-19 20:54:38.643	2026-10-19 20:54:38.643
85b4e720-9d8d-43b1-8cc4-b58e44084c46	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	INTERNET	4610	Internet expense	2026-10-25 20:54:36.661	2026-10-19 20:54:38.646	2026-10-19 20:54:38.646
ad4033f9-51ec-4c0d-9491-c0e672ff714b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	MAINTENANCE	4934	Maintenance expense	2026-10-27 20:54:36.661	2026-10-19 20:54:38.648	2026-10-19 20:54:38.648
7a09e2f4-f346-474c-a80f-b767a094d38b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	SALARY	3487	Salary expense	2026-09-30 20:54:36.661	2026-10-19 20:54:38.65	2026-10-19 20:54:38.65
b0b4f3cb-e3ee-427d-9aa5-f80dc3a2065f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CLEANING	2556	Cleaning expense	2026-10-24 20:54:36.661	2026-10-19 20:54:38.653	2026-10-19 20:54:38.653
1f785f37-8c8d-4d1a-be4d-98386f5d2c79	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	EQUIPMENT	1485	Equipment expense	2026-10-18 20:54:36.661	2026-10-19 20:54:38.656	2026-10-19 20:54:38.656
296885bc-f052-4479-bd5e-e76c9f87c6bf	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	OTHER	2699	Other expense	2026-10-08 20:54:36.661	2026-10-19 20:54:38.658	2026-10-19 20:54:38.658
ea62d440-cf01-4ec1-8740-25c706c31b31	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	ELECTRICITY	1852	Electricity expense	2026-09-19 20:54:36.661	2026-10-19 20:54:38.66	2026-10-19 20:54:38.66
4b93e9cb-7dd9-46b0-ae13-b3df75f01573	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	INTERNET	1803	Internet expense	2026-09-17 20:54:36.661	2026-10-19 20:54:38.663	2026-10-19 20:54:38.663
5032abe7-ee03-4c7c-b3e4-b5c4e7794087	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	MAINTENANCE	1631	Maintenance expense	2026-09-23 20:54:36.661	2026-10-19 20:54:38.665	2026-10-19 20:54:38.665
b37152b7-d28d-4001-b334-eba14487918d	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	SALARY	3302	Salary expense	2026-09-04 20:54:36.661	2026-10-19 20:54:38.667	2026-10-19 20:54:38.667
8db91692-91dc-4ad5-8f5d-4f7d118bdd08	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CLEANING	1534	Cleaning expense	2026-09-12 20:54:36.661	2026-10-19 20:54:38.669	2026-10-19 20:54:38.669
99c8d1d2-32a9-4dbb-896b-e65e63b35808	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	EQUIPMENT	4405	Equipment expense	2026-09-15 20:54:36.661	2026-10-19 20:54:38.672	2026-10-19 20:54:38.672
f286307c-5c6b-4039-8ab7-ced049c88226	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	OTHER	1859	Other expense	2026-09-22 20:54:36.661	2026-10-19 20:54:38.675	2026-10-19 20:54:38.675
b00082bb-0446-4760-b810-5e6cd272ad45	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	ELECTRICITY	3186	Electricity expense	2026-10-14 20:54:36.661	2026-10-19 20:54:38.677	2026-10-19 20:54:38.677
1f682ec3-bbc3-4c79-bf34-3651ba2223e3	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	INTERNET	4864	Internet expense	2026-10-11 20:54:36.661	2026-10-19 20:54:38.68	2026-10-19 20:54:38.68
63aa8332-c77a-40b6-aa35-e2fc754f3485	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	MAINTENANCE	4270	Maintenance expense	2026-10-06 20:54:36.661	2026-10-19 20:54:38.682	2026-10-19 20:54:38.682
3217efcc-742b-4678-be43-61a1d99446f4	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	SALARY	3708	Salary expense	2026-10-24 20:54:36.661	2026-10-19 20:54:38.685	2026-10-19 20:54:38.685
d273a1aa-dc14-4575-9b09-768f8dc731a1	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CLEANING	3474	Cleaning expense	2026-10-06 20:54:36.661	2026-10-19 20:54:38.687	2026-10-19 20:54:38.687
0533072c-fd5d-41f2-b703-575ffa43be7e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	EQUIPMENT	1717	Equipment expense	2026-10-13 20:54:36.661	2026-10-19 20:54:38.689	2026-10-19 20:54:38.689
2cbccfa3-690b-4c41-805c-16c9bd581d92	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	OTHER	3399	Other expense	2026-10-21 20:54:36.661	2026-10-19 20:54:38.691	2026-10-19 20:54:38.691
869376f7-14be-40e1-81d7-40ab642ccf8c	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	ELECTRICITY	3853	Electricity expense	2026-08-31 20:54:36.661	2026-10-19 20:54:38.693	2026-10-19 20:54:38.693
3fb45071-39bd-4d7b-b3a6-205ccc785d79	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	INTERNET	4351	Internet expense	2026-09-21 20:54:36.661	2026-10-19 20:54:38.696	2026-10-19 20:54:38.696
823e9a1c-dc43-495e-8c55-b3628fbbb111	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	MAINTENANCE	1370	Maintenance expense	2026-09-17 20:54:36.661	2026-10-19 20:54:38.698	2026-10-19 20:54:38.698
495ff600-ff87-4f7a-9cf4-1cd648167cb2	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	SALARY	3203	Salary expense	2026-09-25 20:54:36.661	2026-10-19 20:54:38.701	2026-10-19 20:54:38.701
d62adb26-42b4-438f-9e9d-1b376392b820	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CLEANING	3980	Cleaning expense	2026-09-08 20:54:36.661	2026-10-19 20:54:38.703	2026-10-19 20:54:38.703
f62d08f1-e0d6-4ee5-8930-4a956a91bd6d	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	EQUIPMENT	1278	Equipment expense	2026-09-07 20:54:36.661	2026-10-19 20:54:38.705	2026-10-19 20:54:38.705
00967fbd-ab79-4f7f-8cd1-9a319054d14a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	OTHER	2066	Other expense	2026-09-16 20:54:36.661	2026-10-19 20:54:38.707	2026-10-19 20:54:38.707
\.


--
-- Data for Name: Feedback; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Feedback" (id, "tenantId", "branchId", "memberId", "memberName", "memberPhone", rating, category, review, status, response, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Locker; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Locker" (id, "tenantId", "branchId", "lockerNumber", status, "createdAt", "updatedAt") FROM stdin;
ca3b486a-8f90-4587-91df-fef60692c57b	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L05	AVAILABLE	2026-10-19 20:54:38.847	2026-10-19 20:57:32.162
d3e70638-fab8-40ba-af83-794b72800ee7	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L01	AVAILABLE	2026-10-19 20:54:38.838	2026-10-19 20:57:32.162
a8eba447-74bb-445f-be16-01bc69d0d280	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L02	AVAILABLE	2026-10-19 20:54:38.84	2026-10-19 20:57:32.162
7f01a5e3-39d2-4cb5-a855-216bb1502485	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L04	AVAILABLE	2026-10-19 20:54:38.844	2026-10-19 20:57:32.162
3b149fa1-2bed-4830-91fd-7e14a437cafa	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L03	AVAILABLE	2026-10-19 20:54:38.842	2026-10-19 20:57:32.162
7ad752a0-8b3c-4a05-a322-def86fc01272	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L01	AVAILABLE	2026-10-19 20:54:36.647	2026-10-19 20:57:32.185
4d81998b-a56a-4aa5-82dc-49f37c3c973c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L05	AVAILABLE	2026-10-19 20:54:36.638	2026-10-19 20:54:36.638
18e9388c-ac26-4037-9259-9d19f68f587b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L06	AVAILABLE	2026-10-19 20:54:36.64	2026-10-19 20:54:36.64
1cc80026-e25c-4b4d-9b6f-3cac3dd1c42c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L07	AVAILABLE	2026-10-19 20:54:36.642	2026-10-19 20:54:36.642
3b1e0ef6-847f-4d0c-8bb0-cbf12c3a5a84	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L08	AVAILABLE	2026-10-19 20:54:36.644	2026-10-19 20:54:36.644
42a783f4-894d-48ae-ba7d-c0ee9fa85298	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L09	AVAILABLE	2026-10-19 20:54:36.645	2026-10-19 20:54:36.645
74c58e12-17db-4be5-99cd-22deb8b054d5	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L01	AVAILABLE	2026-10-19 20:54:36.628	2026-10-19 20:59:39.366
0a0d4980-2e78-40ee-b6f5-a1c2df9ec557	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L05	AVAILABLE	2026-10-19 20:54:36.655	2026-10-19 20:54:36.655
aa63f12a-937f-46a3-8cbf-13670b55e106	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L06	AVAILABLE	2026-10-19 20:54:36.657	2026-10-19 20:54:36.657
a9626df4-1961-4eca-a9a2-95783cf2ebc5	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L07	AVAILABLE	2026-10-19 20:54:36.658	2026-10-19 20:54:36.658
3c46ea5f-00a4-48f6-afdb-ede391677618	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L08	AVAILABLE	2026-10-19 20:54:36.66	2026-10-19 20:54:36.66
42e67921-fe39-4a02-b9ab-deb9e0c7e1fd	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L09	AVAILABLE	2026-10-19 20:54:36.662	2026-10-19 20:54:36.662
84719b8c-cf00-40ba-993f-8d2c96571a82	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L02	OCCUPIED	2026-10-19 20:54:36.631	2026-10-19 20:54:36.734
6144a910-5201-41fb-bbb7-85176a51fbc5	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L03	OCCUPIED	2026-10-19 20:54:36.633	2026-10-19 20:54:36.775
5585b9a3-dffb-4a1b-8acb-00848d286af2	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	L04	OCCUPIED	2026-10-19 20:54:36.636	2026-10-19 20:54:36.814
18f9a7b8-6414-46a1-8fd7-f8b57b759a6d	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L02	OCCUPIED	2026-10-19 20:54:36.649	2026-10-19 20:54:37.654
af79803f-aa93-4eac-8b91-e335f1299051	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L03	OCCUPIED	2026-10-19 20:54:36.651	2026-10-19 20:54:37.689
5d307680-490e-464f-b1ba-b52b68322333	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	L04	OCCUPIED	2026-10-19 20:54:36.653	2026-10-19 20:54:37.73
345444cb-b8d9-4839-8f02-06470ae88328	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L06	AVAILABLE	2026-10-19 20:54:38.849	2026-10-19 20:54:38.849
3df78fb2-3be1-4fe4-95b6-9bf107d89eb5	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L07	AVAILABLE	2026-10-19 20:54:38.851	2026-10-19 20:54:38.851
f46069da-07f1-4046-a4e5-07a4e5eed62e	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L08	AVAILABLE	2026-10-19 20:54:38.854	2026-10-19 20:54:38.854
28889fe5-0585-4080-a1c8-81d005d04939	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L09	AVAILABLE	2026-10-19 20:54:38.857	2026-10-19 20:54:38.857
c4b6cae6-713c-459d-bf4d-d7ea68e278bc	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	L10	AVAILABLE	2026-10-19 20:54:38.859	2026-10-19 20:54:38.859
\.


--
-- Data for Name: LockerAssignment; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."LockerAssignment" (id, "lockerId", "subscriptionId", "assignedAt", "releasedAt") FROM stdin;
a32c03b6-8c75-48ef-9cd9-82e47b673227	84719b8c-cf00-40ba-993f-8d2c96571a82	049b892a-8f1e-49ec-8ae4-3e140f7bc373	2026-10-19 20:54:36.735	\N
fa5b9c17-e376-418a-98aa-c7f497825eec	6144a910-5201-41fb-bbb7-85176a51fbc5	52051875-e9d7-46b6-b8c0-ffb6e5a7aa64	2026-10-19 20:54:36.777	\N
126b17ad-4d2b-4d6b-baad-4f8c29cab148	5585b9a3-dffb-4a1b-8acb-00848d286af2	604edc38-be54-4e58-8b94-f30e7830456f	2026-10-19 20:54:36.816	\N
7c20887d-cd25-454e-84d4-adb52be94891	18f9a7b8-6414-46a1-8fd7-f8b57b759a6d	4df57773-1e13-4f64-a544-31ffbfd5431c	2026-10-19 20:54:37.656	\N
87409f10-3c5c-49d0-baca-3c21e91c694c	af79803f-aa93-4eac-8b91-e335f1299051	281f9dad-7a18-4a74-906b-410e973d4b80	2026-10-19 20:54:37.691	\N
3e06cb0e-3b8e-49f1-9f8e-8ac5c49601df	5d307680-490e-464f-b1ba-b52b68322333	4df6caee-ce62-45f3-8eca-6358b6fe80d3	2026-10-19 20:54:37.731	\N
49bbb3cd-5d54-4997-8a79-e984a3e56813	7ad752a0-8b3c-4a05-a322-def86fc01272	b0b4c032-2268-4a9e-ac39-16124429e2c9	2026-10-19 20:54:37.61	2026-10-19 20:57:32.186
b13c7b59-4cd1-4563-a42e-9ca6c820f1f2	74c58e12-17db-4be5-99cd-22deb8b054d5	bd8140bd-cf12-4c58-9bac-0030e6342c87	2026-10-19 20:54:36.687	2026-10-19 20:59:39.366
\.


--
-- Data for Name: Member; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Member" (id, "tenantId", "branchId", "memberCode", name, email, phone, dob, address, "academicInfo", "isActive", "createdAt", "updatedAt", "portalAccess", "registrationId", "archivedAt", "archivedBy", "isArchived") FROM stdin;
80a9b93b-35af-4261-bd10-b6f34294d64c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-T9L43K	Aarav Mishra	aarav.mishra0@gmail.com	9866872239	2001-10-27 05:03:57.718	974, Ward 10, Khalilabad	{"fatherName":"Gupta Mishra","gender":"Male","institute":"NEET Aspirant","course":"MBBS","batch":"2023"}	t	2026-10-19 20:54:36.665	2026-10-19 20:54:36.665	f	\N	\N	\N	f
966f4c83-927a-4cff-b31f-feda587ca954	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-DUJF1T	Vivaan Chauhan	vivaan.chauhan1@gmail.com	9813382765	1999-07-19 15:47:24.255	592, Ward 1, Khalilabad	{"fatherName":"Yadav Chauhan","gender":"Male","institute":"JEE Aspirant","course":"M.Tech","batch":"2024"}	t	2026-10-19 20:54:36.726	2026-10-19 20:54:36.726	f	\N	\N	\N	f
983e45a0-32d7-446b-9b42-8d194418e356	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-UGL02P	Aditya Yadav	aditya.yadav2@gmail.com	9835837083	1996-04-30 10:18:21.401	851, Ward 13, Khalilabad	{"fatherName":"Singh Yadav","gender":"Male","institute":"JEE Aspirant","course":"General Studies","batch":"2025"}	t	2026-10-19 20:54:36.766	2026-10-19 20:54:36.766	f	\N	\N	\N	f
66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-NIDCAR	Vihaan Tiwari	vihaan.tiwari3@gmail.com	9879917524	2001-05-12 17:24:55.241	136, Ward 7, Khalilabad	{"fatherName":"Patel Tiwari","gender":"Male","institute":"SSC Aspirant","course":"NEET Preparation","batch":"2024"}	t	2026-10-19 20:54:36.807	2026-10-19 20:54:36.807	f	\N	\N	\N	f
a16f37e6-15a1-44bf-90eb-a3d70e27992c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-T582C8	Arjun Verma	arjun.verma4@gmail.com	9828821950	2000-03-17 12:21:34.739	142, Ward 5, Khalilabad	{"fatherName":"Yadav Verma","gender":"Male","institute":"SSC Aspirant","course":"JEE Preparation","batch":"2025"}	t	2026-10-19 20:54:36.845	2026-10-19 20:54:36.845	f	\N	\N	\N	f
71e1c621-92af-40af-ba88-699ad0e37f07	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-7TR9S6	Sai Gupta	sai.gupta5@gmail.com	9872000587	2004-01-15 02:41:20.504	628, Ward 14, Khalilabad	{"fatherName":"Tiwari Gupta","gender":"Male","institute":"Self Study","course":"General Studies","batch":"2024"}	t	2026-10-19 20:54:36.879	2026-10-19 20:54:36.879	f	\N	\N	\N	f
cd164b6e-4f99-4237-8acb-5ca7e9e860d7	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-D2FEQJ	Reyansh Jaiswal	reyansh.jaiswal6@gmail.com	9857006861	2003-05-06 07:45:29.918	455, Ward 4, Khalilabad	{"fatherName":"Gupta Jaiswal","gender":"Male","institute":"NEET Aspirant","course":"M.Tech","batch":"2023"}	t	2026-10-19 20:54:36.914	2026-10-19 20:54:36.914	f	\N	\N	\N	f
10028bb5-3bd9-42a3-b5d8-d635b67456b3	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-9MXQSW	Krishna Verma	krishna.verma7@gmail.com	9833392902	1995-08-08 22:42:28.205	559, Ward 11, Khalilabad	{"fatherName":"Pandey Verma","gender":"Male","institute":"NEET Aspirant","course":"MBBS","batch":"2023"}	t	2026-10-19 20:54:36.948	2026-10-19 20:54:36.948	f	\N	\N	\N	f
ccb1528b-de83-4b6b-a79b-77971e869a78	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-9HOFF2	Ishaan Patel	ishaan.patel8@gmail.com	9870910000	1997-07-14 04:33:53.929	643, Ward 4, Khalilabad	{"fatherName":"Yadav Patel","gender":"Male","institute":"Self Study","course":"MBBS","batch":"2023"}	t	2026-10-19 20:54:36.986	2026-10-19 20:54:36.986	f	\N	\N	\N	f
4373d996-1b6d-4df3-b930-e8837fb6f339	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-WF1DR8	Shaurya Yadav	shaurya.yadav9@gmail.com	9820898444	2000-03-26 18:52:12.854	859, Ward 1, Khalilabad	{"fatherName":"Sharma Yadav","gender":"Male","institute":"Self Study","course":"B.Tech","batch":"2024"}	t	2026-10-19 20:54:37.025	2026-10-19 20:54:37.025	f	\N	\N	\N	f
9716ff52-823b-4830-9bbf-b831f03769a1	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-ELK4NV	Atharv Patel	atharv.patel10@gmail.com	9818700797	1996-10-22 09:04:06.715	820, Ward 7, Khalilabad	{"fatherName":"Chauhan Patel","gender":"Male","institute":"JEE Aspirant","course":"NEET Preparation","batch":"2024"}	t	2026-10-19 20:54:37.062	2026-10-19 20:54:37.062	f	\N	\N	\N	f
a3219ad2-c46a-4722-ab47-8a173dc78be7	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-C4GO8R	Advik Tripathi	advik.tripathi11@gmail.com	9891084672	2000-04-09 18:42:09.325	311, Ward 4, Khalilabad	{"fatherName":"Pandey Tripathi","gender":"Male","institute":"BHU","course":"SSC CGL","batch":"2025"}	t	2026-10-19 20:54:37.098	2026-10-19 20:54:37.098	f	\N	\N	\N	f
6e891504-a247-41c5-8aed-86c703b11e46	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-OJBK2H	Pranav Jaiswal	pranav.jaiswal12@gmail.com	9831359141	1995-09-19 03:41:08.326	131, Ward 6, Khalilabad	{"fatherName":"Gupta Jaiswal","gender":"Male","institute":"IIT BHU","course":"Civil Services","batch":"2023"}	t	2026-10-19 20:54:37.137	2026-10-19 20:54:37.137	f	\N	\N	\N	f
1d674052-35ab-4200-835b-ca52f506f055	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-HEEXMO	Advait Dubey	advait.dubey13@gmail.com	9886163364	2001-03-22 05:50:05.32	200, Ward 1, Khalilabad	{"fatherName":"Sharma Dubey","gender":"Male","institute":"UPSC Aspirant","course":"MBBS","batch":"2025"}	t	2026-10-19 20:54:37.176	2026-10-19 20:54:37.176	f	\N	\N	\N	f
a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-O6BDEQ	Dhruv Kumar	dhruv.kumar14@gmail.com	9820688869	1996-02-15 14:14:48.028	300, Ward 10, Khalilabad	{"fatherName":"Gupta Kumar","gender":"Male","institute":"MNNIT Allahabad","course":"SSC CGL","batch":"2024"}	t	2026-10-19 20:54:37.211	2026-10-19 20:54:37.211	f	\N	\N	\N	f
4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-VQPPV6	Kabir Pandey	kabir.pandey15@gmail.com	9871422015	2005-06-18 18:39:27.538	105, Ward 5, Khalilabad	{"fatherName":"Jaiswal Pandey","gender":"Male","institute":"JEE Aspirant","course":"JEE Preparation","batch":"2025"}	t	2026-10-19 20:54:37.239	2026-10-19 20:54:37.239	f	\N	\N	\N	f
d380cc18-2a3c-4a92-b54e-0eefba57c039	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-5SBC0N	Ritvik Yadav	ritvik.yadav16@gmail.com	9860157576	1999-01-28 02:14:07.09	526, Ward 13, Khalilabad	{"fatherName":"Patel Yadav","gender":"Male","institute":"NEET Aspirant","course":"SSC CGL","batch":"2023"}	t	2026-10-19 20:54:37.272	2026-10-19 20:54:37.272	f	\N	\N	\N	f
f2e21e7a-13f0-44ca-ad2e-231716100a72	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-L7NWVE	Aarush Sharma	aarush.sharma17@gmail.com	9830416264	1995-10-08 05:12:08.465	242, Ward 1, Khalilabad	{"fatherName":"Patel Sharma","gender":"Male","institute":"JEE Aspirant","course":"JEE Preparation","batch":"2025"}	t	2026-10-19 20:54:37.309	2026-10-19 20:54:37.309	f	\N	\N	\N	f
1a69dcaf-1408-4691-87e4-85faf49a9045	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-WA01Y5	Ayaan Singh	ayaan.singh18@gmail.com	9846947727	1996-05-27 21:04:13.756	250, Ward 10, Khalilabad	{"fatherName":"Verma Singh","gender":"Male","institute":"MNNIT Allahabad","course":"B.Tech","batch":"2023"}	t	2026-10-19 20:54:37.339	2026-10-19 20:54:37.339	f	\N	\N	\N	f
2a129842-c0ae-49e4-9811-b0dedf0bc1e7	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-X1H7LA	Ranveer Dubey	ranveer.dubey19@gmail.com	9851336211	1996-09-15 19:02:23.883	415, Ward 9, Khalilabad	{"fatherName":"Singh Dubey","gender":"Male","institute":"JEE Aspirant","course":"MBBS","batch":"2023"}	t	2026-10-19 20:54:37.374	2026-10-19 20:54:37.374	f	\N	\N	\N	f
3aaa92d4-de08-4fce-b7bb-f600e3a664d2	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-K3NJIA	Priya Patel	priya.patel20@gmail.com	9855530384	2001-06-07 15:19:02.307	572, Ward 8, Khalilabad	{"fatherName":"Maurya Patel","gender":"Female","institute":"MNNIT Allahabad","course":"Civil Services","batch":"2025"}	t	2026-10-19 20:54:37.41	2026-10-19 20:54:37.41	f	\N	\N	\N	f
1abaec6f-b752-42ff-8c14-3a99882ca61b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-TNZRVM	Ananya Chauhan	ananya.chauhan21@gmail.com	9888387965	1995-09-09 16:23:21.693	492, Ward 12, Khalilabad	{"fatherName":"Tiwari Chauhan","gender":"Female","institute":"IIT BHU","course":"SSC CGL","batch":"2023"}	t	2026-10-19 20:54:37.436	2026-10-19 20:54:37.436	f	\N	\N	\N	f
35e08d05-3694-4a5a-b044-6131fc6043f9	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-VUREPM	Isha Maurya	isha.maurya22@gmail.com	9839076865	1998-02-09 18:38:37.113	489, Ward 7, Khalilabad	{"fatherName":"Chauhan Maurya","gender":"Female","institute":"NEET Aspirant","course":"JEE Preparation","batch":"2023"}	t	2026-10-19 20:54:37.465	2026-10-19 20:54:37.465	f	\N	\N	\N	f
5d729459-dddd-4551-a0b1-9d4ed51073c5	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-IDA89V	Kavya Kumar	kavya.kumar23@gmail.com	9831595470	1997-04-07 05:14:28.434	524, Ward 12, Khalilabad	{"fatherName":"Mishra Kumar","gender":"Female","institute":"JEE Aspirant","course":"SSC CGL","batch":"2025"}	t	2026-10-19 20:54:37.493	2026-10-19 20:54:37.493	f	\N	\N	\N	f
41b999cb-9fa5-4868-996e-5c907ef1c967	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-TPSSEK	Riya Gupta	riya.gupta24@gmail.com	9860890768	1995-01-27 17:49:10.015	397, Ward 5, Khalilabad	{"fatherName":"Yadav Gupta","gender":"Female","institute":"Self Study","course":"M.Tech","batch":"2025"}	t	2026-10-19 20:54:37.531	2026-10-19 20:54:37.531	f	\N	\N	\N	f
f4791d23-2b5f-4550-a005-e849ed11cd18	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-5728YB	Sneha Verma	sneha.verma25@gmail.com	9878680139	1998-11-12 18:37:29.679	490, Ward 10, Khalilabad	{"fatherName":"Kumar Verma","gender":"Female","institute":"NEET Aspirant","course":"General Studies","batch":"2025"}	f	2026-10-19 20:54:37.564	2026-10-19 20:54:37.564	f	\N	\N	\N	f
70db2f3e-4dce-4e72-a8bd-6cd89c91e42f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-TG2T9D	Pooja Jaiswal	pooja.jaiswal26@gmail.com	9864945250	2002-06-30 07:47:17.334	220, Ward 11, Khalilabad	{"fatherName":"Patel Jaiswal","gender":"Female","institute":"Self Study","course":"B.Tech","batch":"2025"}	f	2026-10-19 20:54:37.569	2026-10-19 20:54:37.569	f	\N	\N	\N	f
a5ca208c-0154-4468-a5f9-83355a15fa01	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-B3HQ1S	Neha Sharma	neha.sharma27@gmail.com	9839209900	1998-12-03 07:40:50.189	199, Ward 6, Khalilabad	{"fatherName":"Singh Sharma","gender":"Female","institute":"MNNIT Allahabad","course":"JEE Preparation","batch":"2024"}	f	2026-10-19 20:54:37.576	2026-10-19 20:54:37.576	f	\N	\N	\N	f
4e0754b6-fb11-48d6-8fe8-3fd40c263652	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-ABUTPJ	Divya Mishra	divya.mishra28@gmail.com	9833599271	1995-07-25 13:22:27.394	549, Ward 2, Khalilabad	{"fatherName":"Maurya Mishra","gender":"Female","institute":"JEE Aspirant","course":"B.Tech","batch":"2024"}	f	2026-10-19 20:54:37.586	2026-10-19 20:54:37.586	f	\N	\N	\N	f
d0f0687d-842b-4156-87d8-31743f193f8c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	CML-Y8M4AV	Sakshi Singh	sakshi.singh29@gmail.com	9876123688	2005-03-03 08:50:14.57	460, Ward 9, Khalilabad	{"fatherName":"Mishra Singh","gender":"Female","institute":"BHU","course":"M.Tech","batch":"2023"}	f	2026-10-19 20:54:37.592	2026-10-19 20:54:37.592	f	\N	\N	\N	f
da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-HEZNL7	Aarav Pandey	aarav.pandey0@gmail.com	9893139930	2004-10-11 19:39:23.845	603, Ward 12, Mehdawal	{"fatherName":"Singh Pandey","gender":"Male","institute":"NEET Aspirant","course":"SSC CGL","batch":"2024"}	t	2026-10-19 20:54:37.599	2026-10-19 20:54:37.599	f	\N	\N	\N	f
46cbbfad-082b-4048-8d2c-89de79c4c40a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-0BKSI9	Vivaan Sharma	vivaan.sharma1@gmail.com	9825778523	1999-08-10 08:27:34.908	948, Ward 3, Mehdawal	{"fatherName":"Singh Sharma","gender":"Male","institute":"SSC Aspirant","course":"JEE Preparation","batch":"2023"}	t	2026-10-19 20:54:37.645	2026-10-19 20:54:37.645	f	\N	\N	\N	f
0949b3c4-5702-4ff7-a410-b02c68d1df88	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-FEKS7K	Aditya Sharma	aditya.sharma2@gmail.com	9848403075	1996-04-06 00:51:40.448	400, Ward 10, Mehdawal	{"fatherName":"Patel Sharma","gender":"Male","institute":"MNNIT Allahabad","course":"General Studies","batch":"2024"}	t	2026-10-19 20:54:37.68	2026-10-19 20:54:37.68	f	\N	\N	\N	f
8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-BYAZ4I	Vihaan Tripathi	vihaan.tripathi3@gmail.com	9815720387	1997-04-18 03:37:50.121	322, Ward 14, Mehdawal	{"fatherName":"Patel Tripathi","gender":"Male","institute":"SSC Aspirant","course":"NEET Preparation","batch":"2024"}	t	2026-10-19 20:54:37.723	2026-10-19 20:54:37.723	f	\N	\N	\N	f
d323833f-c228-4fba-9788-d86b4480f971	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-HC4AIT	Arjun Pandey	arjun.pandey4@gmail.com	9870018260	1997-10-23 01:09:37.948	527, Ward 12, Mehdawal	{"fatherName":"Verma Pandey","gender":"Male","institute":"SSC Aspirant","course":"M.Tech","batch":"2025"}	t	2026-10-19 20:54:37.76	2026-10-19 20:54:37.76	f	\N	\N	\N	f
8f25e9a8-859f-4f74-83fe-7d0565020dc4	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-S8QLTM	Sai Verma	sai.verma5@gmail.com	9870846356	1995-08-06 14:16:58.259	842, Ward 13, Mehdawal	{"fatherName":"Chauhan Verma","gender":"Male","institute":"BHU","course":"JEE Preparation","batch":"2025"}	t	2026-10-19 20:54:37.795	2026-10-19 20:54:37.795	f	\N	\N	\N	f
c4134a9e-bf2c-4603-9064-5643d58bfc24	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-N8FFF1	Reyansh Sharma	reyansh.sharma6@gmail.com	9866700418	1995-08-05 07:11:26.798	758, Ward 4, Mehdawal	{"fatherName":"Gupta Sharma","gender":"Male","institute":"BHU","course":"Civil Services","batch":"2025"}	t	2026-10-19 20:54:37.832	2026-10-19 20:54:37.832	f	\N	\N	\N	f
1bf73e54-0190-4e7b-a6da-f3fb538b21d9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-MPV5J8	Krishna Dubey	krishna.dubey7@gmail.com	9828668198	1997-11-07 06:30:21.819	134, Ward 15, Mehdawal	{"fatherName":"Singh Dubey","gender":"Male","institute":"MNNIT Allahabad","course":"B.Tech","batch":"2024"}	t	2026-10-19 20:54:37.878	2026-10-19 20:54:37.878	f	\N	\N	\N	f
4fb84b51-7cb5-4488-a20b-046b87c7d314	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-4IYU5J	Ishaan Verma	ishaan.verma8@gmail.com	9873914945	2003-12-15 11:09:54.481	553, Ward 5, Mehdawal	{"fatherName":"Gupta Verma","gender":"Male","institute":"JEE Aspirant","course":"JEE Preparation","batch":"2025"}	t	2026-10-19 20:54:37.904	2026-10-19 20:54:37.904	f	\N	\N	\N	f
3c67bf22-fbb9-4994-a0f3-2381b675474c	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-RAXHGN	Shaurya Maurya	shaurya.maurya9@gmail.com	9857081168	1996-07-18 03:06:39.875	634, Ward 12, Mehdawal	{"fatherName":"Singh Maurya","gender":"Male","institute":"IIT BHU","course":"B.Tech","batch":"2025"}	t	2026-10-19 20:54:37.944	2026-10-19 20:54:37.944	f	\N	\N	\N	f
729bbb15-024f-43c2-ab1f-59786d10b20c	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-15ADW8	Atharv Tiwari	atharv.tiwari10@gmail.com	9850064218	2005-08-17 09:00:22.242	984, Ward 7, Mehdawal	{"fatherName":"Patel Tiwari","gender":"Male","institute":"SSC Aspirant","course":"General Studies","batch":"2023"}	t	2026-10-19 20:54:37.983	2026-10-19 20:54:37.983	f	\N	\N	\N	f
1de3ace6-403d-4828-815b-7e490ed5f696	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-YZIKIE	Advik Mishra	advik.mishra11@gmail.com	9852007428	1995-06-14 12:30:37.895	367, Ward 14, Mehdawal	{"fatherName":"Gupta Mishra","gender":"Male","institute":"SSC Aspirant","course":"JEE Preparation","batch":"2024"}	t	2026-10-19 20:54:38.021	2026-10-19 20:54:38.021	f	\N	\N	\N	f
564dcba4-60c6-49df-a454-e2aa4cc804d9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-4AS1XT	Pranav Dubey	pranav.dubey12@gmail.com	9856382455	1997-03-16 03:49:48.822	937, Ward 7, Mehdawal	{"fatherName":"Patel Dubey","gender":"Male","institute":"BHU","course":"NEET Preparation","batch":"2025"}	t	2026-10-19 20:54:38.054	2026-10-19 20:54:38.054	f	\N	\N	\N	f
b82ead3c-eef7-46ff-ade9-93a8462a77bb	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-1YP41E	Advait Dubey	advait.dubey13@gmail.com	9836798314	1997-12-30 04:53:29.072	935, Ward 15, Mehdawal	{"fatherName":"Kumar Dubey","gender":"Male","institute":"SSC Aspirant","course":"NEET Preparation","batch":"2023"}	t	2026-10-19 20:54:38.091	2026-10-19 20:54:38.091	f	\N	\N	\N	f
12110c00-9f5f-4ae1-a193-9edaa64ddf24	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-XN480L	Dhruv Kumar	dhruv.kumar14@gmail.com	9889652772	1997-02-16 06:33:27.063	322, Ward 5, Mehdawal	{"fatherName":"Tripathi Kumar","gender":"Male","institute":"UPSC Aspirant","course":"SSC CGL","batch":"2025"}	t	2026-10-19 20:54:38.121	2026-10-19 20:54:38.121	f	\N	\N	\N	f
0d71421b-bce8-4b83-a054-8e49ad0cdefa	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-RUWEAS	Kabir Chauhan	kabir.chauhan15@gmail.com	9857958452	2003-09-04 08:37:51.307	315, Ward 11, Mehdawal	{"fatherName":"Chauhan Chauhan","gender":"Male","institute":"MNNIT Allahabad","course":"Civil Services","batch":"2025"}	t	2026-10-19 20:54:38.156	2026-10-19 20:54:38.156	f	\N	\N	\N	f
26f5b911-ace3-4197-aba0-c907779e8643	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-DQ471Y	Ritvik Kumar	ritvik.kumar16@gmail.com	9895555118	1998-05-28 06:15:16.136	338, Ward 14, Mehdawal	{"fatherName":"Maurya Kumar","gender":"Male","institute":"MNNIT Allahabad","course":"JEE Preparation","batch":"2023"}	t	2026-10-19 20:54:38.194	2026-10-19 20:54:38.194	f	\N	\N	\N	f
cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-5EADCH	Aarush Mishra	aarush.mishra17@gmail.com	9818717122	2003-08-22 10:42:41.479	664, Ward 3, Mehdawal	{"fatherName":"Tripathi Mishra","gender":"Male","institute":"UPSC Aspirant","course":"B.Tech","batch":"2023"}	t	2026-10-19 20:54:38.223	2026-10-19 20:54:38.223	f	\N	\N	\N	f
95c97cbb-324d-4f5f-aca4-789b3f9c79cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-JN998X	Ayaan Mishra	ayaan.mishra18@gmail.com	9876572295	2000-08-05 09:38:57.154	946, Ward 1, Mehdawal	{"fatherName":"Tiwari Mishra","gender":"Male","institute":"BHU","course":"SSC CGL","batch":"2023"}	t	2026-10-19 20:54:38.26	2026-10-19 20:54:38.26	f	\N	\N	\N	f
0633ccef-66f0-45d2-a2e1-69211cded599	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-2TYLTJ	Ranveer Verma	ranveer.verma19@gmail.com	9865311920	1999-06-23 23:50:45.498	245, Ward 10, Mehdawal	{"fatherName":"Verma Verma","gender":"Male","institute":"SSC Aspirant","course":"M.Tech","batch":"2024"}	t	2026-10-19 20:54:38.303	2026-10-19 20:54:38.303	f	\N	\N	\N	f
d51ec7cb-e65b-4460-8591-4652e2e3fbfb	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-BNRIFP	Priya Maurya	priya.maurya20@gmail.com	9844962626	1996-03-21 16:20:51.353	626, Ward 8, Mehdawal	{"fatherName":"Singh Maurya","gender":"Female","institute":"IIT BHU","course":"B.Tech","batch":"2023"}	t	2026-10-19 20:54:38.338	2026-10-19 20:54:38.338	f	\N	\N	\N	f
eb7efead-1b61-440e-b02d-2f6c1d57dcbe	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-IKRKC0	Ananya Gupta	ananya.gupta21@gmail.com	9852760385	1997-04-15 10:44:47.588	560, Ward 3, Mehdawal	{"fatherName":"Sharma Gupta","gender":"Female","institute":"IIT BHU","course":"SSC CGL","batch":"2023"}	t	2026-10-19 20:54:38.377	2026-10-19 20:54:38.377	f	\N	\N	\N	f
5b52d225-9d50-42a9-8136-b898a64dce95	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-0WK7ES	Isha Chauhan	isha.chauhan22@gmail.com	9858615011	2000-05-23 05:27:45.6	450, Ward 3, Mehdawal	{"fatherName":"Sharma Chauhan","gender":"Female","institute":"BHU","course":"NEET Preparation","batch":"2024"}	t	2026-10-19 20:54:38.416	2026-10-19 20:54:38.416	f	\N	\N	\N	f
121e8292-5549-4cc3-b708-82bbd0e95352	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-7HDNP2	Kavya Kumar	kavya.kumar23@gmail.com	9846134292	2002-08-25 15:16:32.065	409, Ward 1, Mehdawal	{"fatherName":"Chauhan Kumar","gender":"Female","institute":"JEE Aspirant","course":"B.Tech","batch":"2023"}	t	2026-10-19 20:54:38.458	2026-10-19 20:54:38.458	f	\N	\N	\N	f
17ad17c5-e3f0-46fd-934f-ac607c3a9810	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-4BBXSO	Riya Yadav	riya.yadav24@gmail.com	9831303449	2001-10-27 13:12:43.656	637, Ward 4, Mehdawal	{"fatherName":"Sharma Yadav","gender":"Female","institute":"JEE Aspirant","course":"MBBS","batch":"2023"}	t	2026-10-19 20:54:38.503	2026-10-19 20:54:38.503	f	\N	\N	\N	f
270e9f94-4554-4388-a5b2-020ab9e38ee0	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-8Z5THA	Sneha Mishra	sneha.mishra25@gmail.com	9865358027	1997-11-21 03:07:44.856	493, Ward 8, Mehdawal	{"fatherName":"Chauhan Mishra","gender":"Female","institute":"IIT BHU","course":"JEE Preparation","batch":"2023"}	f	2026-10-19 20:54:38.552	2026-10-19 20:54:38.552	f	\N	\N	\N	f
6cabf6b9-ee6b-4e3c-9186-0a82b4903fef	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-AKRDLZ	Pooja Chauhan	pooja.chauhan26@gmail.com	9894337871	1996-11-23 23:44:13.905	256, Ward 9, Mehdawal	{"fatherName":"Verma Chauhan","gender":"Female","institute":"BHU","course":"Civil Services","batch":"2025"}	f	2026-10-19 20:54:38.558	2026-10-19 20:54:38.558	f	\N	\N	\N	f
30948194-891b-4fe6-89a1-a7345e60a0e8	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-3K07E1	Neha Gupta	neha.gupta27@gmail.com	9861789890	2005-01-13 15:06:16.262	995, Ward 5, Mehdawal	{"fatherName":"Mishra Gupta","gender":"Female","institute":"Self Study","course":"SSC CGL","batch":"2025"}	f	2026-10-19 20:54:38.566	2026-10-19 20:54:38.566	f	\N	\N	\N	f
63e0dff3-aff1-43e6-8e97-f61745f66591	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-A03PE6	Divya Jaiswal	divya.jaiswal28@gmail.com	9856667991	2004-05-24 21:32:04.344	308, Ward 9, Mehdawal	{"fatherName":"Jaiswal Jaiswal","gender":"Female","institute":"BHU","course":"General Studies","batch":"2024"}	f	2026-10-19 20:54:38.575	2026-10-19 20:54:38.575	f	\N	\N	\N	f
1a279cb6-0b30-40d6-8d98-66ff27ea1e44	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	CML-XYGFZW	Sakshi Pandey	sakshi.pandey29@gmail.com	9863452400	1996-04-08 04:08:44.541	693, Ward 11, Mehdawal	{"fatherName":"Sharma Pandey","gender":"Female","institute":"IIT BHU","course":"MBBS","batch":"2024"}	f	2026-10-19 20:54:38.583	2026-10-19 20:54:38.583	f	\N	\N	\N	f
\.


--
-- Data for Name: MemberPortalSession; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."MemberPortalSession" (id, phone, otp, verified, "memberId", token, "expiresAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: MemberRegistration; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."MemberRegistration" (id, "tenantId", "branchId", "applicationId", name, phone, email, dob, gender, address, "aadhaarNumber", "emergencyContact", "academicInfo", "planId", "photoUrl", "aadhaarFrontUrl", "aadhaarBackUrl", "otherDocUrls", status, "rejectionReason", "reservedSeatId", "memberId", "reviewedBy", "reviewedAt", "submittedAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: MembershipPlan; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."MembershipPlan" (id, "tenantId", "branchId", name, "durationDays", price, "includesSeat", "includesLocker", "isActive", "createdAt", "updatedAt", "seatAllocation") FROM stdin;
d311a963-4f84-4d9c-810e-44822faa8486	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Daily	1	80	t	f	t	2026-10-19 20:54:36.347	2026-10-19 20:54:36.347	ADMIN
8032650d-d9f8-47ae-9be9-80f95ccca567	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Monthly	30	600	t	f	t	2026-10-19 20:54:36.353	2026-10-19 20:54:36.353	ADMIN
4a6eccdb-6045-4806-9845-705ef7f69175	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Quarterly	90	1700	t	t	t	2026-10-19 20:54:36.355	2026-10-19 20:54:36.355	ADMIN
3feadfca-4914-44ed-b1d6-c3c836fea678	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Half-Yearly	180	3200	t	t	t	2026-10-19 20:54:36.357	2026-10-19 20:54:36.357	ADMIN
4ec4a8b2-69e5-45c3-b242-6947e4116735	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	Yearly	365	6000	t	t	t	2026-10-19 20:54:36.358	2026-10-19 20:54:36.358	ADMIN
8b4de4a2-593f-411f-84ac-daa75340f291	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Daily	1	80	t	f	t	2026-10-19 20:54:36.36	2026-10-19 20:54:36.36	ADMIN
76551e16-a8a2-4f93-80fa-ee70993c2eed	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Monthly	30	600	t	f	t	2026-10-19 20:54:36.362	2026-10-19 20:54:36.362	ADMIN
6ae05492-26cf-4726-ad17-31dac2782000	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Quarterly	90	1700	t	t	t	2026-10-19 20:54:36.364	2026-10-19 20:54:36.364	ADMIN
450884d1-421a-4d9e-b722-94df6aa525db	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Half-Yearly	180	3200	t	t	t	2026-10-19 20:54:36.366	2026-10-19 20:54:36.366	ADMIN
c4d09045-f531-4f62-af46-78f5a3be90a3	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	Yearly	365	6000	t	t	t	2026-10-19 20:54:36.367	2026-10-19 20:54:36.367	ADMIN
72937d75-6eb3-427b-b873-80adfcf5c552	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	Day Pass	1	70	t	f	t	2026-10-19 20:54:38.732	2026-10-19 20:54:38.732	ADMIN
d2bad7a3-4530-4e19-9b84-182cef3dc2eb	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	Monthly Standard	30	550	t	f	t	2026-10-19 20:54:38.734	2026-10-19 20:54:38.734	ADMIN
a011bdca-6588-4299-8de9-dcaee5141978	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	Quarterly Pro	90	1500	t	t	t	2026-10-19 20:54:38.736	2026-10-19 20:54:38.736	ADMIN
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Notification" (id, "tenantId", "userId", type, title, body, "isRead", "createdAt", "memberId") FROM stdin;
\.


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Payment" (id, "tenantId", "memberId", amount, method, status, "txnRef", "paidAt", "createdAt", "updatedAt", notes, "paymentType") FROM stdin;
9145d849-781e-4ee6-a750-5ad59de1e10a	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	1700	BANK	PAID	TXN17924432766870	2026-09-09 20:54:36.661	2026-10-19 20:54:36.69	2026-10-19 20:54:36.69	\N	\N
5165f052-11df-4a36-811b-601eef888f14	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	3200	CARD	PAID	TXN17924432767341	2026-10-05 20:54:36.661	2026-10-19 20:54:36.738	2026-10-19 20:54:36.738	\N	\N
5a513358-6c1d-456c-bd98-f582113e65a3	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	3200	UPI	PAID	TXN17924432767752	2026-07-07 20:54:36.661	2026-10-19 20:54:36.778	2026-10-19 20:54:36.778	\N	\N
9fb3d6e0-ff28-4994-a3c1-adcee67eaf8a	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	3200	BANK	PAID	TXN17924432768153	2026-10-17 20:54:36.661	2026-10-19 20:54:36.818	2026-10-19 20:54:36.818	\N	\N
64a5f667-7a72-4aa9-9f74-8fc1059715db	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	6000	CARD	PAID	TXN17924432768504	2026-07-03 20:54:36.661	2026-10-19 20:54:36.853	2026-10-19 20:54:36.853	\N	\N
42caa679-e21a-4674-996c-5f568d651978	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	3200	CARD	PAID	TXN17924432768855	2026-09-23 20:54:36.661	2026-10-19 20:54:36.888	2026-10-19 20:54:36.888	\N	\N
48423ccb-c596-4e57-9f46-8766c5069bc3	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	1700	BANK	PAID	TXN17924432769186	2026-08-22 20:54:36.661	2026-10-19 20:54:36.922	2026-10-19 20:54:36.922	\N	\N
b63e14f5-98a1-42db-889e-36cb647ab220	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	6000	BANK	PAID	TXN17924432769537	2026-07-12 20:54:36.661	2026-10-19 20:54:36.956	2026-10-19 20:54:36.956	\N	\N
12dc81cd-eba2-48dd-816a-262d23bcaea3	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	1700	UPI	PAID	TXN17924432769918	2026-09-03 20:54:36.661	2026-10-19 20:54:36.994	2026-10-19 20:54:36.994	\N	\N
5b445b5f-0808-466c-aaf9-c17a59de5fca	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	3200	BANK	PAID	TXN17924432770319	2026-09-18 20:54:36.661	2026-10-19 20:54:37.034	2026-10-19 20:54:37.034	\N	\N
2798278d-4f54-4ab5-8de3-bf2cfbe45923	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	3200	UPI	PAID	TXN179244327706610	2026-08-15 20:54:36.661	2026-10-19 20:54:37.069	2026-10-19 20:54:37.069	\N	\N
bfab0e9c-7dc9-4e9c-9c99-4350d6af85aa	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	600	BANK	PAID	TXN179244327710311	2026-10-02 20:54:36.661	2026-10-19 20:54:37.106	2026-10-19 20:54:37.106	\N	\N
10105f23-8994-4b8a-947d-186d2b576bae	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	1700	BANK	PAID	TXN179244327714112	2026-09-02 20:54:36.661	2026-10-19 20:54:37.144	2026-10-19 20:54:37.144	\N	\N
56d13275-7b15-4ce7-9db1-b03fa58d8175	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	600	BANK	PAID	TXN179244327718013	2026-10-08 20:54:36.661	2026-10-19 20:54:37.184	2026-10-19 20:54:37.184	\N	\N
7e4514ca-2fb9-407d-96fb-b1767e2f4327	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	6000	UPI	PAID	TXN179244327721714	2026-02-22 20:54:36.661	2026-10-19 20:54:37.22	2026-10-19 20:54:37.22	\N	\N
224a4d1e-7870-42f4-88f4-44cd0cedee8f	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	1700	CARD	PAID	TXN179244327724315	2026-09-27 20:54:36.661	2026-10-19 20:54:37.246	2026-10-19 20:54:37.246	\N	\N
5512e338-b6ee-4ae5-87a5-ab96ade7d450	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	1700	CARD	PAID	TXN179244327727616	2026-09-27 20:54:36.661	2026-10-19 20:54:37.28	2026-10-19 20:54:37.28	\N	\N
08e4f0c4-bd8f-4823-9df5-7c61c283f53d	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	1700	CASH	PAID	TXN179244327731317	2026-09-14 20:54:36.661	2026-10-19 20:54:37.316	2026-10-19 20:54:37.316	\N	\N
02353873-b7ef-4b43-bf1c-045689c3e8ab	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	600	CASH	PAID	TXN179244327734318	2026-09-29 20:54:36.661	2026-10-19 20:54:37.346	2026-10-19 20:54:37.346	\N	\N
0a304d22-1ca4-4a71-bae1-fc134108982a	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	600	BANK	PAID	TXN179244327737819	2026-10-18 20:54:36.661	2026-10-19 20:54:37.381	2026-10-19 20:54:37.381	\N	\N
45bf3cca-f9df-423f-9260-848d799cf8b6	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	6000	CARD	PAID	TXN179244327741420	2025-10-24 20:54:36.661	2026-10-19 20:54:37.417	2026-10-19 20:54:37.417	\N	\N
9ab88510-de95-46e2-9c0b-4863aee9e201	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	600	CARD	PAID	TXN179244327744121	2026-09-28 20:54:36.661	2026-10-19 20:54:37.444	2026-10-19 20:54:37.444	\N	\N
24087b48-88a2-4a4c-9648-4b94529b779b	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	3200	CARD	PAID	TXN179244327746922	2026-04-25 20:54:36.661	2026-10-19 20:54:37.472	2026-10-19 20:54:37.472	\N	\N
e1979dca-6c24-4fc1-8500-e78d94d116c4	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	600	UPI	PAID	TXN179244327749723	2026-09-21 20:54:36.661	2026-10-19 20:54:37.5	2026-10-19 20:54:37.5	\N	\N
ded590ba-ce1c-47fb-9077-0aae70a024cc	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	1700	CARD	PAID	TXN179244327753524	2026-07-29 20:54:36.661	2026-10-19 20:54:37.538	2026-10-19 20:54:37.538	\N	\N
618d3348-525c-4cd3-96d3-2b4b17abc324	bc1c3e43-9c01-4f17-9b81-39430c671e34	f4791d23-2b5f-4550-a005-e849ed11cd18	600	CARD	PAID	TXN179244327756425	2026-08-23 20:54:36.661	2026-10-19 20:54:37.567	2026-10-19 20:54:37.567	\N	\N
d704a1ba-3f1b-44e1-8aa1-4f48d7c4648e	bc1c3e43-9c01-4f17-9b81-39430c671e34	70db2f3e-4dce-4e72-a8bd-6cd89c91e42f	600	CARD	PAID	TXN179244327757126	2026-09-11 20:54:36.661	2026-10-19 20:54:37.574	2026-10-19 20:54:37.574	\N	\N
508bc4c7-824f-4d31-b788-aca4b797115c	bc1c3e43-9c01-4f17-9b81-39430c671e34	a5ca208c-0154-4468-a5f9-83355a15fa01	1700	CASH	PENDING	\N	\N	2026-10-19 20:54:37.581	2026-10-19 20:54:37.581	\N	\N
07e4a690-184e-40e0-9e73-771aa9b2cf76	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e0754b6-fb11-48d6-8fe8-3fd40c263652	600	CASH	PENDING	\N	\N	2026-10-19 20:54:37.59	2026-10-19 20:54:37.59	\N	\N
bb1430ec-b76d-4ae5-b182-00978939f971	bc1c3e43-9c01-4f17-9b81-39430c671e34	d0f0687d-842b-4156-87d8-31743f193f8c	6000	CARD	PENDING	\N	\N	2026-10-19 20:54:37.597	2026-10-19 20:54:37.597	\N	\N
69703010-c813-4cc9-b37e-ce0f1ef4be7c	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	600	CARD	PAID	TXN17924432776090	2026-10-01 20:54:36.661	2026-10-19 20:54:37.612	2026-10-19 20:54:37.612	\N	\N
6a1984dc-faf0-40c7-a605-34bb1c177d2a	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	1700	CARD	PAID	TXN17924432776551	2026-09-08 20:54:36.661	2026-10-19 20:54:37.658	2026-10-19 20:54:37.658	\N	\N
016d0d34-17c6-4129-8995-1c8836654f17	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	6000	BANK	PAID	TXN17924432776902	2026-09-19 20:54:36.661	2026-10-19 20:54:37.693	2026-10-19 20:54:37.693	\N	\N
77fc9ad6-537d-492d-8357-d8077f06af1c	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	6000	CASH	PAID	TXN17924432777303	2026-03-01 20:54:36.661	2026-10-19 20:54:37.733	2026-10-19 20:54:37.733	\N	\N
778d0f07-97ff-43d1-9159-6db4ab7b1f0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	3200	CARD	PAID	TXN17924432777644	2026-08-20 20:54:36.661	2026-10-19 20:54:37.767	2026-10-19 20:54:37.767	\N	\N
e9befdc5-266d-462b-b57c-c95ceebcfe47	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	1700	CASH	PAID	TXN17924432778005	2026-09-28 20:54:36.661	2026-10-19 20:54:37.803	2026-10-19 20:54:37.803	\N	\N
c6516b21-2a9f-47f7-abaf-3c0a2dafb39f	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	600	CARD	PAID	TXN17924432778386	2026-10-13 20:54:36.661	2026-10-19 20:54:37.841	2026-10-19 20:54:37.841	\N	\N
8b470bfa-33c4-463f-8166-fe05c679880e	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	1700	CASH	PAID	TXN17924432778857	2026-10-03 20:54:36.661	2026-10-19 20:54:37.888	2026-10-19 20:54:37.888	\N	\N
ca991b82-2f0e-4b7c-bec2-9563544d9ccc	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	600	UPI	PAID	TXN17924432779098	2026-10-08 20:54:36.661	2026-10-19 20:54:37.912	2026-10-19 20:54:37.912	\N	\N
4bdfa624-164f-42a0-8f70-b083e3f5dcd9	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	6000	CASH	PAID	TXN17924432779499	2026-04-17 20:54:36.661	2026-10-19 20:54:37.952	2026-10-19 20:54:37.952	\N	\N
eb23a5a5-bc5f-4a1b-a2ce-bbe013fd79a0	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	1700	CARD	PAID	TXN179244327798710	2026-10-11 20:54:36.661	2026-10-19 20:54:37.99	2026-10-19 20:54:37.99	\N	\N
621b6dfd-cd93-4aba-89c7-e4121f3f1ab0	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	1700	CARD	PAID	TXN179244327802511	2026-09-24 20:54:36.661	2026-10-19 20:54:38.028	2026-10-19 20:54:38.028	\N	\N
fd803031-6047-4b32-9ac8-94c5bce9ae2e	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	1700	BANK	PAID	TXN179244327806012	2026-09-06 20:54:36.661	2026-10-19 20:54:38.063	2026-10-19 20:54:38.063	\N	\N
77ae76f8-3be0-4f89-b69a-8d9a0f201857	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	3200	CARD	PAID	TXN179244327809613	2026-08-06 20:54:36.661	2026-10-19 20:54:38.099	2026-10-19 20:54:38.099	\N	\N
ed3c7016-2d78-44cf-b68a-2f60c018bf27	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	600	UPI	PAID	TXN179244327812514	2026-10-02 20:54:36.661	2026-10-19 20:54:38.129	2026-10-19 20:54:38.129	\N	\N
0611ca08-8b01-4f37-92f0-4c14e065bb65	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	1700	BANK	PAID	TXN179244327816015	2026-08-25 20:54:36.661	2026-10-19 20:54:38.164	2026-10-19 20:54:38.164	\N	\N
bd74dc57-9c5e-4878-b7b4-a954e9a39140	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	3200	UPI	PAID	TXN179244327819816	2026-08-10 20:54:36.661	2026-10-19 20:54:38.201	2026-10-19 20:54:38.201	\N	\N
6ed5dc34-6bcc-4f85-8c6c-c2a7dff0cea3	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	1700	CASH	PAID	TXN179244327822817	2026-10-10 20:54:36.661	2026-10-19 20:54:38.231	2026-10-19 20:54:38.231	\N	\N
781beaab-be64-4d84-aa18-4fdd7b84065c	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	3200	CASH	PAID	TXN179244327826618	2026-09-19 20:54:36.661	2026-10-19 20:54:38.269	2026-10-19 20:54:38.269	\N	\N
3fe27916-7f7b-4b67-af76-8822389db294	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	3200	CASH	PAID	TXN179244327830719	2026-08-26 20:54:36.661	2026-10-19 20:54:38.31	2026-10-19 20:54:38.31	\N	\N
0932591c-9305-4085-a826-9163d2e3c55d	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	1700	CASH	PAID	TXN179244327834320	2026-07-25 20:54:36.661	2026-10-19 20:54:38.346	2026-10-19 20:54:38.346	\N	\N
a3e2921c-f3eb-4267-a564-effc89d1eaba	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	1700	CASH	PAID	TXN179244327838421	2026-07-24 20:54:36.661	2026-10-19 20:54:38.387	2026-10-19 20:54:38.387	\N	\N
8d84bcb6-cb46-4ec0-a4b9-330934ef5f09	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	600	UPI	PAID	TXN179244327842122	2026-09-21 20:54:36.661	2026-10-19 20:54:38.425	2026-10-19 20:54:38.425	\N	\N
c5693678-e4f7-425d-a168-db1b38761fc7	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	600	CARD	PAID	TXN179244327846323	2026-09-20 20:54:36.661	2026-10-19 20:54:38.466	2026-10-19 20:54:38.466	\N	\N
b2d24754-bfce-4be8-aa72-cffe90029de2	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	6000	CARD	PAID	TXN179244327851024	2025-10-22 20:54:36.661	2026-10-19 20:54:38.513	2026-10-19 20:54:38.513	\N	\N
42debec7-acf8-4383-acd1-cad7ea67168e	bc1c3e43-9c01-4f17-9b81-39430c671e34	270e9f94-4554-4388-a5b2-020ab9e38ee0	3200	CARD	PAID	TXN179244327855325	2026-03-08 20:54:36.661	2026-10-19 20:54:38.556	2026-10-19 20:54:38.556	\N	\N
53ae0b89-5f55-413f-9e47-5ec90979a9a0	bc1c3e43-9c01-4f17-9b81-39430c671e34	6cabf6b9-ee6b-4e3c-9186-0a82b4903fef	3200	UPI	PAID	TXN179244327856026	2026-04-17 20:54:36.661	2026-10-19 20:54:38.563	2026-10-19 20:54:38.563	\N	\N
a324f651-deba-4f83-9c7f-a2ddd04565cb	bc1c3e43-9c01-4f17-9b81-39430c671e34	30948194-891b-4fe6-89a1-a7345e60a0e8	3200	CARD	PENDING	\N	\N	2026-10-19 20:54:38.57	2026-10-19 20:54:38.57	\N	\N
a949397d-dbcc-4634-a431-fe8d851a9807	bc1c3e43-9c01-4f17-9b81-39430c671e34	63e0dff3-aff1-43e6-8e97-f61745f66591	600	CASH	PENDING	\N	\N	2026-10-19 20:54:38.58	2026-10-19 20:54:38.58	\N	\N
b8f95c8d-bb32-4df7-821a-40622e5a7dcd	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a279cb6-0b30-40d6-8d98-66ff27ea1e44	1700	BANK	PENDING	\N	\N	2026-10-19 20:54:38.589	2026-10-19 20:54:38.589	\N	\N
\.


--
-- Data for Name: PaymentTransaction; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."PaymentTransaction" (id, "paymentId", amount, status, "providerRef", "createdAt") FROM stdin;
\.


--
-- Data for Name: PaymentVerification; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."PaymentVerification" (id, "tenantId", "paymentId", "memberId", amount, "paymentType", "screenshotUrl", "txnRef", "upiId", status, "rejectionReason", "verifiedBy", "verifiedAt", "submittedAt", "updatedAt") FROM stdin;
e8c17460-bd5a-44a4-b8ee-24ecd1f32905	bc1c3e43-9c01-4f17-9b81-39430c671e34	9145d849-781e-4ee6-a750-5ad59de1e10a	80a9b93b-35af-4261-bd10-b6f34294d64c	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432766870	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-09 20:54:36.661	2026-10-19 20:54:36.695	2026-10-19 20:54:36.695
84a0d6c2-78e0-4697-a80d-3f95df90cb11	bc1c3e43-9c01-4f17-9b81-39430c671e34	9fb3d6e0-ff28-4994-a3c1-adcee67eaf8a	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	3200	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432768153	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-10-17 20:54:36.661	2026-10-19 20:54:36.821	2026-10-19 20:54:36.821
1b7284ac-f9d3-43e8-a3e9-82432efe7cf5	bc1c3e43-9c01-4f17-9b81-39430c671e34	48423ccb-c596-4e57-9f46-8766c5069bc3	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432769186	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-08-22 20:54:36.661	2026-10-19 20:54:36.923	2026-10-19 20:54:36.923
fa3d9e2a-99af-4297-aed9-eb5faf76ccad	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b445b5f-0808-466c-aaf9-c17a59de5fca	4373d996-1b6d-4df3-b930-e8837fb6f339	3200	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432770319	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-18 20:54:36.661	2026-10-19 20:54:37.036	2026-10-19 20:54:37.036
1ae44ebd-d147-4690-b89c-ad50602a6d06	bc1c3e43-9c01-4f17-9b81-39430c671e34	10105f23-8994-4b8a-947d-186d2b576bae	6e891504-a247-41c5-8aed-86c703b11e46	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327714112	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-02 20:54:36.661	2026-10-19 20:54:37.146	2026-10-19 20:54:37.146
72963c66-861c-4ff3-88c1-7efddfdf12cf	bc1c3e43-9c01-4f17-9b81-39430c671e34	224a4d1e-7870-42f4-88f4-44cd0cedee8f	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327724315	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-27 20:54:36.661	2026-10-19 20:54:37.249	2026-10-19 20:54:37.249
f4d46fe0-8b10-4b4c-9e84-1e9fe2960c42	bc1c3e43-9c01-4f17-9b81-39430c671e34	02353873-b7ef-4b43-bf1c-045689c3e8ab	1a69dcaf-1408-4691-87e4-85faf49a9045	600	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327734318	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-29 20:54:36.661	2026-10-19 20:54:37.348	2026-10-19 20:54:37.348
5f748617-b54d-46c9-ab59-0f8cf8e1547c	bc1c3e43-9c01-4f17-9b81-39430c671e34	9ab88510-de95-46e2-9c0b-4863aee9e201	1abaec6f-b752-42ff-8c14-3a99882ca61b	600	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327744121	prashantmanitripathi2003-2@oksbi	PENDING	\N	\N	\N	2026-10-19 20:54:37.446	2026-10-19 20:54:37.446
e5097918-d704-4196-b5b0-1823a22e19e2	bc1c3e43-9c01-4f17-9b81-39430c671e34	ded590ba-ce1c-47fb-9077-0aae70a024cc	41b999cb-9fa5-4868-996e-5c907ef1c967	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327753524	prashantmanitripathi2003-2@oksbi	PENDING	\N	\N	\N	2026-10-19 20:54:37.54	2026-10-19 20:54:37.54
984ce70e-f43e-45a5-b044-873fb1c53ce0	bc1c3e43-9c01-4f17-9b81-39430c671e34	508bc4c7-824f-4d31-b788-aca4b797115c	a5ca208c-0154-4468-a5f9-83355a15fa01	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	\N	prashantmanitripathi2003-2@oksbi	REJECTED	Transaction screenshot unreadable or incomplete	\N	\N	2026-10-19 20:54:37.583	2026-10-19 20:54:37.583
01e01f79-2398-45ee-9bcf-716ab9ed5b81	bc1c3e43-9c01-4f17-9b81-39430c671e34	69703010-c813-4cc9-b37e-ce0f1ef4be7c	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	600	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432776090	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-10-01 20:54:36.661	2026-10-19 20:54:37.614	2026-10-19 20:54:37.614
885efad5-36b1-4a0d-aa7b-a718bbd38836	bc1c3e43-9c01-4f17-9b81-39430c671e34	77fc9ad6-537d-492d-8357-d8077f06af1c	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	6000	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432777303	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-03-01 20:54:36.661	2026-10-19 20:54:37.735	2026-10-19 20:54:37.735
a6b8286c-05cd-4ff8-811e-fbc2adc0cf2a	bc1c3e43-9c01-4f17-9b81-39430c671e34	c6516b21-2a9f-47f7-abaf-3c0a2dafb39f	c4134a9e-bf2c-4603-9064-5643d58bfc24	600	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432778386	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-10-13 20:54:36.661	2026-10-19 20:54:37.843	2026-10-19 20:54:37.843
28276977-1356-49ae-906c-b8f07c4eaf0a	bc1c3e43-9c01-4f17-9b81-39430c671e34	4bdfa624-164f-42a0-8f70-b083e3f5dcd9	3c67bf22-fbb9-4994-a0f3-2381b675474c	6000	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN17924432779499	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-04-17 20:54:36.661	2026-10-19 20:54:37.954	2026-10-19 20:54:37.954
41949e2a-1dc4-4680-b807-015b576989bf	bc1c3e43-9c01-4f17-9b81-39430c671e34	fd803031-6047-4b32-9ac8-94c5bce9ae2e	564dcba4-60c6-49df-a454-e2aa4cc804d9	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327806012	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-06 20:54:36.661	2026-10-19 20:54:38.065	2026-10-19 20:54:38.065
fc4f8afb-9107-44de-b0c0-8bd920ee2813	bc1c3e43-9c01-4f17-9b81-39430c671e34	0611ca08-8b01-4f37-92f0-4c14e065bb65	0d71421b-bce8-4b83-a054-8e49ad0cdefa	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327816015	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-08-25 20:54:36.661	2026-10-19 20:54:38.165	2026-10-19 20:54:38.165
1463ed1f-0ec1-4d09-89b6-a8f2449ae1d4	bc1c3e43-9c01-4f17-9b81-39430c671e34	781beaab-be64-4d84-aa18-4fdd7b84065c	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	3200	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327826618	prashantmanitripathi2003-2@oksbi	APPROVED	\N	Admin	2026-09-19 20:54:36.661	2026-10-19 20:54:38.27	2026-10-19 20:54:38.27
5609d36e-d6e6-4979-9468-7193d5039bc6	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3e2921c-f3eb-4267-a564-effc89d1eaba	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	1700	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327838421	prashantmanitripathi2003-2@oksbi	PENDING	\N	\N	\N	2026-10-19 20:54:38.389	2026-10-19 20:54:38.389
17c8dfc0-c3fe-4dbb-982a-70c84a7d2283	bc1c3e43-9c01-4f17-9b81-39430c671e34	b2d24754-bfce-4be8-aa72-cffe90029de2	17ad17c5-e3f0-46fd-934f-ac607c3a9810	6000	MEMBERSHIP	/uploads/payments/sample_receipt.png	TXN179244327851024	prashantmanitripathi2003-2@oksbi	PENDING	\N	\N	\N	2026-10-19 20:54:38.516	2026-10-19 20:54:38.516
89235837-36ea-426e-b577-5bf6fb16edd2	bc1c3e43-9c01-4f17-9b81-39430c671e34	a324f651-deba-4f83-9c7f-a2ddd04565cb	30948194-891b-4fe6-89a1-a7345e60a0e8	3200	MEMBERSHIP	/uploads/payments/sample_receipt.png	\N	prashantmanitripathi2003-2@oksbi	REJECTED	Transaction screenshot unreadable or incomplete	\N	\N	2026-10-19 20:54:38.573	2026-10-19 20:54:38.573
\.


--
-- Data for Name: Permission; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Permission" (id, "userId", action) FROM stdin;
\.


--
-- Data for Name: QrCode; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."QrCode" (id, "tenantId", "entityType", "entityId", token, "expiresAt", "createdAt", url) FROM stdin;
\.


--
-- Data for Name: Seat; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Seat" (id, "tenantId", "branchId", "seatNumber", floor, status, "createdAt", "updatedAt", notes) FROM stdin;
1c730d21-ae13-404b-bc93-71d16725123c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K26	Single Hall	AVAILABLE	2026-10-19 20:54:36.416	2026-10-19 20:55:12.313	\N
cd93f0f2-4685-440c-abfb-bd52e66697a8	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K27	Single Hall	AVAILABLE	2026-10-19 20:54:36.418	2026-10-19 20:55:12.313	\N
224d466a-738f-49bd-8052-532903282d79	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K28	Single Hall	AVAILABLE	2026-10-19 20:54:36.419	2026-10-19 20:55:12.313	\N
a54ab550-6150-4684-b498-8f36392f1554	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K29	Single Hall	AVAILABLE	2026-10-19 20:54:36.421	2026-10-19 20:55:12.313	\N
3cb7d48c-f71e-4238-8e00-03a01ed1f726	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K30	Single Hall	AVAILABLE	2026-10-19 20:54:36.422	2026-10-19 20:55:12.313	\N
930dfa64-40e3-4b2b-97ea-edf59781d5f5	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K31	Single Hall	AVAILABLE	2026-10-19 20:54:36.424	2026-10-19 20:55:12.313	\N
62151a74-de22-4e12-b065-986e3d5d39f6	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K32	Single Hall	AVAILABLE	2026-10-19 20:54:36.426	2026-10-19 20:55:12.313	\N
98480fed-4b7c-44ed-8ef9-dd3a26d3a5c1	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M58	Single Hall	AVAILABLE	2026-10-19 20:54:36.613	2026-10-19 20:55:12.313	\N
0bde285e-c70b-4be4-9468-3b2640b259ed	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M59	Single Hall	AVAILABLE	2026-10-19 20:54:36.614	2026-10-19 20:55:12.313	\N
562e3096-f91e-43a9-87ca-93dad5bedaf9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M60	Single Hall	AVAILABLE	2026-10-19 20:54:36.616	2026-10-19 20:55:12.313	\N
9000d3e5-14cd-44fe-8d00-bf7598a0c8e1	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M61	Single Hall	AVAILABLE	2026-10-19 20:54:36.618	2026-10-19 20:55:12.313	\N
325ec652-9875-4e01-bf08-a4da08d71e5b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M62	Single Hall	AVAILABLE	2026-10-19 20:54:36.62	2026-10-19 20:55:12.313	\N
080176c7-ce58-4a7f-ba60-653a69205d08	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K01	Single Hall	AVAILABLE	2026-10-19 20:54:36.369	2026-10-19 20:57:32.123	\N
4f18879e-11d8-46f4-bec7-4cf7849f9b7a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M01	Single Hall	AVAILABLE	2026-10-19 20:54:36.497	2026-10-19 20:59:39.337	\N
fd5fc061-c13d-4780-bc08-24c324506c32	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M63	Single Hall	AVAILABLE	2026-10-19 20:54:36.621	2026-10-19 20:55:12.313	\N
524a91e2-3646-4224-9031-41de0222fcf2	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M64	Single Hall	AVAILABLE	2026-10-19 20:54:36.623	2026-10-19 20:55:12.313	\N
c69ed955-755d-46c3-bdc2-7bf1de098fc4	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M65	Single Hall	AVAILABLE	2026-10-19 20:54:36.625	2026-10-19 20:55:12.313	\N
781501d2-c089-4e29-854c-ee6da4360d59	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K23	Single Hall	OCCUPIED	2026-10-19 20:54:36.411	2026-10-19 20:55:12.313	\N
92ac9e23-1006-4b22-bd6a-e60c4ae2e68f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M15	Single Hall	OCCUPIED	2026-10-19 20:54:36.522	2026-10-19 20:55:12.313	\N
0c145e76-60d7-490c-89b0-cbd44e318159	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K33	Single Hall	AVAILABLE	2026-10-19 20:54:36.428	2026-10-19 20:55:12.313	\N
db0424c0-44e5-4473-8da9-213e9ad3bbd6	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K34	Single Hall	AVAILABLE	2026-10-19 20:54:36.43	2026-10-19 20:55:12.313	\N
7e6a3ce4-c24e-49de-84e3-8a14f256ee21	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K35	Single Hall	AVAILABLE	2026-10-19 20:54:36.432	2026-10-19 20:55:12.313	\N
e6c39550-a06c-4e40-8b40-f19181170855	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K36	Single Hall	AVAILABLE	2026-10-19 20:54:36.433	2026-10-19 20:55:12.313	\N
7017a794-faa9-466b-82b4-9a5934738398	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K37	Single Hall	AVAILABLE	2026-10-19 20:54:36.435	2026-10-19 20:55:12.313	\N
68b49e78-ecef-4b10-98fe-9624a1b3bddd	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K38	Single Hall	AVAILABLE	2026-10-19 20:54:36.436	2026-10-19 20:55:12.313	\N
da961111-2a52-45a4-a698-7e8c7ba0373a	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K39	Single Hall	AVAILABLE	2026-10-19 20:54:36.439	2026-10-19 20:55:12.313	\N
be835bd9-2536-4a9d-93a0-13d190a73a91	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K40	Single Hall	AVAILABLE	2026-10-19 20:54:36.441	2026-10-19 20:55:12.313	\N
865fd1be-54d2-4f5a-abf3-b1ddc04c73c1	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K41	Single Hall	AVAILABLE	2026-10-19 20:54:36.443	2026-10-19 20:55:12.313	\N
53422b74-b6f8-4498-8f3a-54697725e630	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K42	Single Hall	AVAILABLE	2026-10-19 20:54:36.444	2026-10-19 20:55:12.313	\N
f0e853f8-f309-4690-9492-ad1d9b3a5401	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K43	Single Hall	AVAILABLE	2026-10-19 20:54:36.446	2026-10-19 20:55:12.313	\N
312e722a-11ef-4f5c-b12b-ddc326907f81	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K02	Single Hall	OCCUPIED	2026-10-19 20:54:36.372	2026-10-19 20:55:12.313	\N
48ae47ed-4123-4a71-88b4-22c8ba5b0373	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K03	Single Hall	OCCUPIED	2026-10-19 20:54:36.374	2026-10-19 20:55:12.313	\N
fe3c2b01-e554-46ed-a0f5-e8de921f7aeb	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K04	Single Hall	OCCUPIED	2026-10-19 20:54:36.376	2026-10-19 20:55:12.313	\N
a96fb5bf-4bae-449a-8bc6-d236c956de0b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K05	Single Hall	OCCUPIED	2026-10-19 20:54:36.378	2026-10-19 20:55:12.313	\N
37af6ffb-a7d7-4f78-8d60-e0e6fe7fb622	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K06	Single Hall	OCCUPIED	2026-10-19 20:54:36.38	2026-10-19 20:55:12.313	\N
d744b408-dce0-4a00-941c-156992c72c77	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K07	Single Hall	OCCUPIED	2026-10-19 20:54:36.381	2026-10-19 20:55:12.313	\N
862be2f3-ffd9-468e-865e-1e8d58def5ab	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K08	Single Hall	OCCUPIED	2026-10-19 20:54:36.384	2026-10-19 20:55:12.313	\N
675da6be-a3b5-488c-9fca-76e68114cc3e	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K09	Single Hall	OCCUPIED	2026-10-19 20:54:36.386	2026-10-19 20:55:12.313	\N
c2c3b101-787e-446b-9d0b-6c063020b118	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K10	Single Hall	OCCUPIED	2026-10-19 20:54:36.387	2026-10-19 20:55:12.313	\N
3a9bc683-e281-49bb-8e3d-386c4ac729db	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K11	Single Hall	OCCUPIED	2026-10-19 20:54:36.389	2026-10-19 20:55:12.313	\N
f017f591-841d-4fbe-9ab4-ba36f639f133	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K12	Single Hall	OCCUPIED	2026-10-19 20:54:36.39	2026-10-19 20:55:12.313	\N
85962495-c2aa-46f7-b72b-876f5d0d3238	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K13	Single Hall	OCCUPIED	2026-10-19 20:54:36.393	2026-10-19 20:55:12.313	\N
1685ff9d-2d40-4ccd-b3f2-63e86b0a3aca	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K14	Single Hall	OCCUPIED	2026-10-19 20:54:36.395	2026-10-19 20:55:12.313	\N
72f65226-990a-4da9-b511-d1e81cd0f6cc	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K15	Single Hall	OCCUPIED	2026-10-19 20:54:36.397	2026-10-19 20:55:12.313	\N
1443ac46-17c8-4e53-9c77-5af8e6293c20	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K16	Single Hall	OCCUPIED	2026-10-19 20:54:36.399	2026-10-19 20:55:12.313	\N
592cabc7-5cf3-45d6-9a48-5b678f88b4a6	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K17	Single Hall	OCCUPIED	2026-10-19 20:54:36.401	2026-10-19 20:55:12.313	\N
b3a4386f-bf5b-47b2-8f9c-1faa32373423	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K18	Single Hall	OCCUPIED	2026-10-19 20:54:36.402	2026-10-19 20:55:12.313	\N
056c5f61-ee57-418a-b950-9c1e7986ed74	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K19	Single Hall	OCCUPIED	2026-10-19 20:54:36.404	2026-10-19 20:55:12.313	\N
8c94351d-e7f5-4867-a5a4-d6ab3fa554e3	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K20	Single Hall	OCCUPIED	2026-10-19 20:54:36.406	2026-10-19 20:55:12.313	\N
71771036-dbd6-422e-88e4-a25374838694	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K21	Single Hall	OCCUPIED	2026-10-19 20:54:36.408	2026-10-19 20:55:12.313	\N
8f0cc42c-2615-41d6-83fb-219777f3da13	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K22	Single Hall	OCCUPIED	2026-10-19 20:54:36.409	2026-10-19 20:55:12.313	\N
176866ec-1e73-4f99-b55e-93141f5c1579	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K24	Single Hall	OCCUPIED	2026-10-19 20:54:36.412	2026-10-19 20:55:12.313	\N
c8f209ad-3b13-4966-a753-81f4b041483f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K25	Single Hall	OCCUPIED	2026-10-19 20:54:36.414	2026-10-19 20:55:12.313	\N
5d8066fa-bf44-4a16-9a57-89a9cb5ab23f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K44	Single Hall	AVAILABLE	2026-10-19 20:54:36.447	2026-10-19 20:55:12.313	\N
605991b8-b90f-4e9d-805e-7f418d87ac17	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K45	Single Hall	AVAILABLE	2026-10-19 20:54:36.45	2026-10-19 20:55:12.313	\N
1dd98e61-ec03-4a0f-86e6-83b03d66f2fc	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K46	Single Hall	AVAILABLE	2026-10-19 20:54:36.452	2026-10-19 20:55:12.313	\N
084ebb34-ba60-40a3-8815-4c0ff406a4d8	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K47	Single Hall	AVAILABLE	2026-10-19 20:54:36.453	2026-10-19 20:55:12.313	\N
ac9935c5-0b95-4a92-b03f-70d73c996f16	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K48	Single Hall	AVAILABLE	2026-10-19 20:54:36.455	2026-10-19 20:55:12.313	\N
2a4597e1-971b-43ef-9391-a30cc73a96d3	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K49	Single Hall	AVAILABLE	2026-10-19 20:54:36.456	2026-10-19 20:55:12.313	\N
5bdcd02c-16d8-4281-aa05-b4e02483be25	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K50	Single Hall	AVAILABLE	2026-10-19 20:54:36.458	2026-10-19 20:55:12.313	\N
d663bb17-111c-4677-b4a7-348609d4d808	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K51	Single Hall	AVAILABLE	2026-10-19 20:54:36.46	2026-10-19 20:55:12.313	\N
8ec06828-6dd3-469c-a663-faa30e8d910c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K52	Single Hall	AVAILABLE	2026-10-19 20:54:36.462	2026-10-19 20:55:12.313	\N
ce4e8ece-9e83-4293-ad96-5d5279ac2788	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K53	Single Hall	AVAILABLE	2026-10-19 20:54:36.464	2026-10-19 20:55:12.313	\N
46125c70-7195-47e9-97e2-e6add214ff3d	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K54	Single Hall	AVAILABLE	2026-10-19 20:54:36.466	2026-10-19 20:55:12.313	\N
3fdb7085-7b05-44e5-ad7b-8a042188e06b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K55	Single Hall	AVAILABLE	2026-10-19 20:54:36.467	2026-10-19 20:55:12.313	\N
23650f3d-3341-4845-a30e-add5fc297f29	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K56	Single Hall	AVAILABLE	2026-10-19 20:54:36.469	2026-10-19 20:55:12.313	\N
e7a21399-3152-4dc4-b5d9-768583f5187f	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K57	Single Hall	AVAILABLE	2026-10-19 20:54:36.47	2026-10-19 20:55:12.313	\N
09ad125c-c2c0-4b62-b442-7f0ad42ce11a	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K58	Single Hall	AVAILABLE	2026-10-19 20:54:36.472	2026-10-19 20:55:12.313	\N
cd6e735e-732c-421b-b1b2-13209f77ad20	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K59	Single Hall	AVAILABLE	2026-10-19 20:54:36.474	2026-10-19 20:55:12.313	\N
dae75a97-3772-42f2-ac05-01f1af4797a9	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K60	Single Hall	AVAILABLE	2026-10-19 20:54:36.475	2026-10-19 20:55:12.313	\N
fa0a41fc-e2a7-4e10-b209-dd7bd4ffd586	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K61	Single Hall	AVAILABLE	2026-10-19 20:54:36.477	2026-10-19 20:55:12.313	\N
d7012930-b6ef-4f06-ae9b-d8b9bf176679	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K62	Single Hall	AVAILABLE	2026-10-19 20:54:36.478	2026-10-19 20:55:12.313	\N
b5d74ee0-aa35-400b-a6ed-c9f6598b6a0c	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K63	Single Hall	AVAILABLE	2026-10-19 20:54:36.48	2026-10-19 20:55:12.313	\N
dc3a7e63-5b46-4db1-bc1d-28bc796bff5d	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K64	Single Hall	AVAILABLE	2026-10-19 20:54:36.481	2026-10-19 20:55:12.313	\N
43bfdd68-299c-49bc-90e6-fcaafd77ef25	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K65	Single Hall	AVAILABLE	2026-10-19 20:54:36.484	2026-10-19 20:55:12.313	\N
f5cf42bb-4f78-4552-ae7a-831f8254b9c6	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K66	Single Hall	AVAILABLE	2026-10-19 20:54:36.485	2026-10-19 20:55:12.313	\N
9ec78d7a-a2f9-4132-8110-741b5eba8d56	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K67	Single Hall	AVAILABLE	2026-10-19 20:54:36.487	2026-10-19 20:55:12.313	\N
a87b011c-15eb-4fe4-8ca6-5dde3f4d0051	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K68	Single Hall	AVAILABLE	2026-10-19 20:54:36.488	2026-10-19 20:55:12.313	\N
092392dd-698c-4059-b855-fcfdc038e0a7	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K69	Single Hall	AVAILABLE	2026-10-19 20:54:36.49	2026-10-19 20:55:12.313	\N
bc9e4c4f-b5be-4c94-a1d0-698a19f60713	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K70	Single Hall	AVAILABLE	2026-10-19 20:54:36.491	2026-10-19 20:55:12.313	\N
b4925528-383f-48ce-b0f7-fffc8301ed20	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K71	Single Hall	AVAILABLE	2026-10-19 20:54:36.493	2026-10-19 20:55:12.313	\N
4e2a8ed9-2ef8-4330-933a-44db62f29925	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	K72	Single Hall	AVAILABLE	2026-10-19 20:54:36.495	2026-10-19 20:55:12.313	\N
22936b37-da00-4fd0-bab5-c9ce67c93266	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M02	Single Hall	OCCUPIED	2026-10-19 20:54:36.499	2026-10-19 20:55:12.313	\N
e5dd7b1c-0e3f-46ca-98e8-defa4d0cfac0	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M03	Single Hall	OCCUPIED	2026-10-19 20:54:36.5	2026-10-19 20:55:12.313	\N
ca177a31-51bd-45f0-b702-cc288bcba8ca	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M04	Single Hall	OCCUPIED	2026-10-19 20:54:36.502	2026-10-19 20:55:12.313	\N
c039424e-1cb8-406b-a748-dd82087fab5e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M05	Single Hall	OCCUPIED	2026-10-19 20:54:36.505	2026-10-19 20:55:12.313	\N
a7e39886-89cf-438b-ab64-22b83c291816	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M06	Single Hall	OCCUPIED	2026-10-19 20:54:36.507	2026-10-19 20:55:12.313	\N
a2bbcc16-b078-47b0-87d0-4140a388d0fc	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M07	Single Hall	OCCUPIED	2026-10-19 20:54:36.509	2026-10-19 20:55:12.313	\N
6bb0a247-9807-4531-8a28-a11e614904dc	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M08	Single Hall	OCCUPIED	2026-10-19 20:54:36.511	2026-10-19 20:55:12.313	\N
fb484531-ed55-436d-8bf1-3126b12e5d99	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M09	Single Hall	OCCUPIED	2026-10-19 20:54:36.512	2026-10-19 20:55:12.313	\N
c11f6d74-a3e7-454e-b66b-7d4a0e63ddc0	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M10	Single Hall	OCCUPIED	2026-10-19 20:54:36.514	2026-10-19 20:55:12.313	\N
8b97eb84-d0cc-4b1d-97bd-9dcfc1ad64f3	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M11	Single Hall	OCCUPIED	2026-10-19 20:54:36.516	2026-10-19 20:55:12.313	\N
2a3e7493-cfce-47a3-87f7-c840e5bb53fb	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M12	Single Hall	OCCUPIED	2026-10-19 20:54:36.518	2026-10-19 20:55:12.313	\N
c5ac16ca-9a4c-4b80-95bd-3c539c8ffdfc	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M13	Single Hall	OCCUPIED	2026-10-19 20:54:36.519	2026-10-19 20:55:12.313	\N
64704e36-8f13-4ace-af1d-55493a56fec7	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M14	Single Hall	OCCUPIED	2026-10-19 20:54:36.521	2026-10-19 20:55:12.313	\N
43b9945d-d72f-4102-917c-ff3797a5e0a9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M26	Single Hall	AVAILABLE	2026-10-19 20:54:36.544	2026-10-19 20:55:12.313	\N
14d0cfee-1251-454e-8705-c4efb90ef560	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M27	Single Hall	AVAILABLE	2026-10-19 20:54:36.546	2026-10-19 20:55:12.313	\N
33fc8ea5-7066-40f7-9f09-c63ca855d6d4	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M28	Single Hall	AVAILABLE	2026-10-19 20:54:36.548	2026-10-19 20:55:12.313	\N
4b780ba8-974e-4664-a30e-9fdae4ba5b77	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M29	Single Hall	AVAILABLE	2026-10-19 20:54:36.55	2026-10-19 20:55:12.313	\N
ae8e0f11-cb9f-4d48-adcb-372f1cbb75fc	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M30	Single Hall	AVAILABLE	2026-10-19 20:54:36.552	2026-10-19 20:55:12.313	\N
e5982018-05d5-451a-9b50-775ee4f836dc	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M31	Single Hall	AVAILABLE	2026-10-19 20:54:36.554	2026-10-19 20:55:12.313	\N
486d15b9-8c33-4fca-9f15-17002f57257b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M32	Single Hall	AVAILABLE	2026-10-19 20:54:36.556	2026-10-19 20:55:12.313	\N
deb3df80-a965-42c6-b0a6-7241df764f64	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M33	Single Hall	AVAILABLE	2026-10-19 20:54:36.558	2026-10-19 20:55:12.313	\N
973103ca-2dba-4b7a-958b-fe53d0e6e61e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M34	Single Hall	AVAILABLE	2026-10-19 20:54:36.56	2026-10-19 20:55:12.313	\N
990be2b4-a68f-42f6-b22c-7ea48ce3dd8e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M35	Single Hall	AVAILABLE	2026-10-19 20:54:36.563	2026-10-19 20:55:12.313	\N
6aa01ff3-c3d3-4a4c-a76a-fa5648101260	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M36	Single Hall	AVAILABLE	2026-10-19 20:54:36.565	2026-10-19 20:55:12.313	\N
01d5342b-c8bf-4acb-bc86-1a4520ed772f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M37	Single Hall	AVAILABLE	2026-10-19 20:54:36.567	2026-10-19 20:55:12.313	\N
34aaf528-364f-4805-9259-9a6ad3210073	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M38	Single Hall	AVAILABLE	2026-10-19 20:54:36.569	2026-10-19 20:55:12.313	\N
88213589-7fe3-4e7c-ae5c-780200a13ba8	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M39	Single Hall	AVAILABLE	2026-10-19 20:54:36.573	2026-10-19 20:55:12.313	\N
5484115f-6866-4acb-a6b3-8245cd39b379	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M40	Single Hall	AVAILABLE	2026-10-19 20:54:36.576	2026-10-19 20:55:12.313	\N
e6620913-18a5-457e-b5b9-ba5199e011ea	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M41	Single Hall	AVAILABLE	2026-10-19 20:54:36.578	2026-10-19 20:55:12.313	\N
7f3991a3-d783-4b20-a5be-5a351130c77f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M42	Single Hall	AVAILABLE	2026-10-19 20:54:36.58	2026-10-19 20:55:12.313	\N
fe9b90b8-4b0e-461e-b235-60eba3ec0c72	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M43	Single Hall	AVAILABLE	2026-10-19 20:54:36.584	2026-10-19 20:55:12.313	\N
ab8761e3-0da5-4126-bd8e-abdca4d27ff4	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M44	Single Hall	AVAILABLE	2026-10-19 20:54:36.587	2026-10-19 20:55:12.313	\N
920e8cfb-d40a-4223-b0bb-87b843b25a0b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M45	Single Hall	AVAILABLE	2026-10-19 20:54:36.589	2026-10-19 20:55:12.313	\N
4a88ea48-3db5-4c82-8887-4e3d65e1761b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M46	Single Hall	AVAILABLE	2026-10-19 20:54:36.59	2026-10-19 20:55:12.313	\N
5ae5d950-3b17-436a-8257-c47cf0df1ca7	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M47	Single Hall	AVAILABLE	2026-10-19 20:54:36.592	2026-10-19 20:55:12.313	\N
a8fec3af-acba-4365-92d4-17df18777e1a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M48	Single Hall	AVAILABLE	2026-10-19 20:54:36.595	2026-10-19 20:55:12.313	\N
be2b0b9e-51da-4095-8751-3f963139fb1a	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M49	Single Hall	AVAILABLE	2026-10-19 20:54:36.597	2026-10-19 20:55:12.313	\N
a46356ef-2946-467e-9160-00e776ba679f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M50	Single Hall	AVAILABLE	2026-10-19 20:54:36.598	2026-10-19 20:55:12.313	\N
c592ed2d-2514-4b47-92b2-efbdc4046589	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M51	Single Hall	AVAILABLE	2026-10-19 20:54:36.6	2026-10-19 20:55:12.313	\N
3b629c84-8f65-454f-afbe-b3b8c75e6892	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M52	Single Hall	AVAILABLE	2026-10-19 20:54:36.601	2026-10-19 20:55:12.313	\N
f98d45a2-f6c6-487c-8ddf-50fd1be5696f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M53	Single Hall	AVAILABLE	2026-10-19 20:54:36.603	2026-10-19 20:55:12.313	\N
37f39083-805d-484a-9e70-f4cde1ad7f6f	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M54	Single Hall	AVAILABLE	2026-10-19 20:54:36.605	2026-10-19 20:55:12.313	\N
f176ff73-c3b8-4c27-8a4a-b66490293ac8	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M55	Single Hall	AVAILABLE	2026-10-19 20:54:36.608	2026-10-19 20:55:12.313	\N
827af215-de27-4497-a808-86dbd950e467	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M56	Single Hall	AVAILABLE	2026-10-19 20:54:36.609	2026-10-19 20:55:12.313	\N
4ac31356-a09f-418c-8bc3-c77a646d0a88	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M57	Single Hall	AVAILABLE	2026-10-19 20:54:36.611	2026-10-19 20:55:12.313	\N
0692ba06-9286-4195-a5ef-56cbec4e1bd5	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M16	Single Hall	OCCUPIED	2026-10-19 20:54:36.524	2026-10-19 20:55:12.313	\N
19d2a06d-a5a3-4016-b81e-a57c4af01fb5	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M17	Single Hall	OCCUPIED	2026-10-19 20:54:36.526	2026-10-19 20:55:12.313	\N
29611eea-b36c-4e90-9201-48e4b5ac34e5	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M18	Single Hall	OCCUPIED	2026-10-19 20:54:36.529	2026-10-19 20:55:12.313	\N
3a2fc0f0-0d21-4e6a-ba50-cc123293580b	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M19	Single Hall	OCCUPIED	2026-10-19 20:54:36.53	2026-10-19 20:55:12.313	\N
b52778e3-9d95-49e1-8ab0-e4941aeaa4a2	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M20	Single Hall	OCCUPIED	2026-10-19 20:54:36.532	2026-10-19 20:55:12.313	\N
99b6b87d-ef05-4180-9aff-7c52591cb56d	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M21	Single Hall	OCCUPIED	2026-10-19 20:54:36.534	2026-10-19 20:55:12.313	\N
d2ce9765-33d9-43b0-a4ea-49e7a3235ecd	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M22	Single Hall	OCCUPIED	2026-10-19 20:54:36.535	2026-10-19 20:55:12.313	\N
ebd74ab5-9f11-464a-a723-573976650ecf	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M23	Single Hall	OCCUPIED	2026-10-19 20:54:36.537	2026-10-19 20:55:12.313	\N
b9d5801e-a876-4bb4-8f96-38100efb9486	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M24	Single Hall	OCCUPIED	2026-10-19 20:54:36.539	2026-10-19 20:55:12.313	\N
0e193cd9-cfdc-49f6-8f4d-e3066ece6efd	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	M25	Single Hall	OCCUPIED	2026-10-19 20:54:36.541	2026-10-19 20:55:12.313	\N
\.


--
-- Data for Name: SeatAssignment; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."SeatAssignment" (id, "seatId", "subscriptionId", "assignedAt", "releasedAt") FROM stdin;
b7b01f58-6ca0-459c-a57c-49b75821bd40	312e722a-11ef-4f5c-b12b-ddc326907f81	049b892a-8f1e-49ec-8ae4-3e140f7bc373	2026-10-19 20:54:36.732	\N
a64e519d-7144-4fc8-8207-49b7a0810087	48ae47ed-4123-4a71-88b4-22c8ba5b0373	52051875-e9d7-46b6-b8c0-ffb6e5a7aa64	2026-10-19 20:54:36.773	\N
6a10a988-c318-4e20-894f-45c30351b33c	fe3c2b01-e554-46ed-a0f5-e8de921f7aeb	604edc38-be54-4e58-8b94-f30e7830456f	2026-10-19 20:54:36.812	\N
41fd0bad-935b-400d-bf6c-5cef34ce7db5	a96fb5bf-4bae-449a-8bc6-d236c956de0b	915c2cf9-033f-4283-be49-29af3a5d1527	2026-10-19 20:54:36.851	\N
3a3e4479-2e4a-4c5a-89bd-e2df7e983bb7	37af6ffb-a7d7-4f78-8d60-e0e6fe7fb622	23d19f46-274c-4a5e-a099-b4681fa2e169	2026-10-19 20:54:36.887	\N
fe7da00c-b4d3-4bf1-8892-95b2b526e7de	d744b408-dce0-4a00-941c-156992c72c77	d45ec3e7-abd8-423e-93c0-34f834b05d7e	2026-10-19 20:54:36.92	\N
5e01d349-8787-42c6-a21f-8ef307c0de2e	862be2f3-ffd9-468e-865e-1e8d58def5ab	65139a80-99e0-4ee2-a676-e937ac2a4f74	2026-10-19 20:54:36.955	\N
7fac9393-33ea-40c5-a65a-8b3f56316fb3	675da6be-a3b5-488c-9fca-76e68114cc3e	8d2b40b2-90b4-41ba-b183-0e880136373c	2026-10-19 20:54:36.992	\N
ac874e13-1d1b-45e5-9657-faabd035942a	c2c3b101-787e-446b-9d0b-6c063020b118	72d601b6-b978-4cc1-bf77-39150d12e563	2026-10-19 20:54:37.032	\N
232ff890-1b16-433a-a44e-b97f2c79282f	3a9bc683-e281-49bb-8e3d-386c4ac729db	214ff5be-1c2d-4d87-9599-06acbfe9a9a6	2026-10-19 20:54:37.068	\N
0833e8f4-cb7b-4257-8eb5-28ea1b513a0b	f017f591-841d-4fbe-9ab4-ba36f639f133	e48d5264-7c1d-4784-8826-5a1c0a5dd577	2026-10-19 20:54:37.104	\N
43f2e5c5-2ece-421e-927f-9d9f37232eb9	85962495-c2aa-46f7-b72b-876f5d0d3238	5c6d6d8d-dfd0-4e35-b6ac-0363d347d9c5	2026-10-19 20:54:37.143	\N
947374f5-6449-436d-9373-11b6b9b3712c	1685ff9d-2d40-4ccd-b3f2-63e86b0a3aca	b9aa83ec-1fdb-4e6e-b059-b03a1081fc33	2026-10-19 20:54:37.181	\N
952b9436-8b15-4500-8674-00980e634521	72f65226-990a-4da9-b511-d1e81cd0f6cc	16f91a2d-5366-4e9a-84ca-08fce52880f8	2026-10-19 20:54:37.218	\N
8816de2b-0146-4744-919f-8cf99081dba3	1443ac46-17c8-4e53-9c77-5af8e6293c20	55e46937-c8f3-4a38-85a0-435ead098c70	2026-10-19 20:54:37.245	\N
f5fd84b7-4816-4d50-8e14-994e92403bce	592cabc7-5cf3-45d6-9a48-5b678f88b4a6	66d55e94-ab45-4112-be89-69ea36a41091	2026-10-19 20:54:37.278	\N
5db0e759-ac8b-4720-b8d5-2571c6ef17c7	b3a4386f-bf5b-47b2-8f9c-1faa32373423	b3a4a877-6030-4bd2-89e9-6f7052ba6f1e	2026-10-19 20:54:37.314	\N
f66cce49-2aef-4392-8f54-acbb8cb90a34	056c5f61-ee57-418a-b950-9c1e7986ed74	f0dff270-dec5-443f-bc86-c59c2bf3a37b	2026-10-19 20:54:37.345	\N
25982b9b-770d-4ff0-be77-87bc6b7be8a9	8c94351d-e7f5-4867-a5a4-d6ab3fa554e3	0d6d0f13-e288-4120-9198-616f9a029e82	2026-10-19 20:54:37.38	\N
b268287b-3239-496d-946f-08873ba84852	71771036-dbd6-422e-88e4-a25374838694	cb8b0192-20fa-4bdb-8c2d-c40e6eddb609	2026-10-19 20:54:37.415	\N
e82ee56d-a468-474f-9e46-199169961664	8f0cc42c-2615-41d6-83fb-219777f3da13	4d018109-12a7-4440-a4f0-41cec7f9500e	2026-10-19 20:54:37.443	\N
151e93dc-27d4-4ad8-92c8-f7b04801a607	781501d2-c089-4e29-854c-ee6da4360d59	3789ca66-8e59-422c-b639-4243aeb852d2	2026-10-19 20:54:37.47	\N
232e58f4-2e8a-4e1b-8d2f-b5fb9aeec7cc	176866ec-1e73-4f99-b55e-93141f5c1579	67ca78a8-4692-4502-8cb5-4b255419e0b7	2026-10-19 20:54:37.499	\N
2191e170-b0cc-4aaa-8798-504b38a726a2	c8f209ad-3b13-4966-a753-81f4b041483f	12c9b3ed-b8fe-40f1-8e58-4c2a523f7d41	2026-10-19 20:54:37.536	\N
88d64cf8-84d7-4fa9-b61a-c25db4adbd4d	22936b37-da00-4fd0-bab5-c9ce67c93266	4df57773-1e13-4f64-a544-31ffbfd5431c	2026-10-19 20:54:37.653	\N
bcafa704-bea0-4342-b40d-53b03ddd64f6	e5dd7b1c-0e3f-46ca-98e8-defa4d0cfac0	281f9dad-7a18-4a74-906b-410e973d4b80	2026-10-19 20:54:37.687	\N
1bcbced0-f4d2-44f6-87d3-1a262d59ff09	ca177a31-51bd-45f0-b702-cc288bcba8ca	4df6caee-ce62-45f3-8eca-6358b6fe80d3	2026-10-19 20:54:37.728	\N
c0752470-8886-4384-bd1e-8d9d3ec05f15	c039424e-1cb8-406b-a748-dd82087fab5e	bcf63d3c-de17-49cf-8d26-2e845755aa6a	2026-10-19 20:54:37.765	\N
a5eab494-3c3f-4b46-badb-face40d4660d	a7e39886-89cf-438b-ab64-22b83c291816	5f23aaff-5cc6-48f8-a346-5ea02a89d878	2026-10-19 20:54:37.801	\N
7780d6f7-06c9-4f4e-a12f-dbef9f2b3fb4	a2bbcc16-b078-47b0-87d0-4140a388d0fc	c1ad3d19-a3cf-4e7f-a96d-669bb17b6b6e	2026-10-19 20:54:37.839	\N
a4834b48-eac3-49ac-a845-4f4ed3d78e45	6bb0a247-9807-4531-8a28-a11e614904dc	89019d60-1222-452c-8e1d-b9b26b0869ca	2026-10-19 20:54:37.886	\N
8fee05af-a002-46db-ac6b-b0e59c445787	fb484531-ed55-436d-8bf1-3126b12e5d99	ccc21915-2db3-4db2-a315-feb8fe4ba0e9	2026-10-19 20:54:37.91	\N
5a225ab5-2893-4e45-bebb-5f85f12f8785	c11f6d74-a3e7-454e-b66b-7d4a0e63ddc0	fc98b0fe-63fb-4184-836c-23acd70fee88	2026-10-19 20:54:37.95	\N
bc126281-65ed-4062-b6c0-3ef15b35eccf	8b97eb84-d0cc-4b1d-97bd-9dcfc1ad64f3	547a597c-e2ff-4e0d-8a2f-b2c4b9a4e933	2026-10-19 20:54:37.989	\N
e10e5533-e1e6-406d-8796-cc2694c31ba9	2a3e7493-cfce-47a3-87f7-c840e5bb53fb	2d9b8325-e179-4189-9672-50b5104fbb93	2026-10-19 20:54:38.026	\N
a81678d6-5c4d-4168-b2b2-407a4501e4fc	c5ac16ca-9a4c-4b80-95bd-3c539c8ffdfc	135fc5b1-970e-4186-a64c-00ee16288a71	2026-10-19 20:54:38.061	\N
dead7f26-3f16-49ee-951d-d54f06b345a0	64704e36-8f13-4ace-af1d-55493a56fec7	422fb949-9c3e-4bca-9928-514cf5bbbf29	2026-10-19 20:54:38.097	\N
bf10106c-e1ad-4129-8973-463b3eb0d418	92ac9e23-1006-4b22-bd6a-e60c4ae2e68f	0913034c-ad75-4435-882e-57219cbc2a74	2026-10-19 20:54:38.127	\N
9656b7cc-7348-41d1-aaa8-634f95e17190	0692ba06-9286-4195-a5ef-56cbec4e1bd5	f205fc2b-e7cb-42e7-ad8f-60b30ae70f11	2026-10-19 20:54:38.162	\N
e3d12df8-65db-487f-81f5-6966adcd36a4	19d2a06d-a5a3-4016-b81e-a57c4af01fb5	3e389760-85cc-4635-9d41-781df1a32db5	2026-10-19 20:54:38.199	\N
0570eb4f-8fe3-405d-9c0a-6d8a1c3eda71	29611eea-b36c-4e90-9201-48e4b5ac34e5	eb8989a5-afb4-4199-bc56-73eb76aee93f	2026-10-19 20:54:38.229	\N
9839814b-8712-426c-a40a-f48c5db6b634	3a2fc0f0-0d21-4e6a-ba50-cc123293580b	2e195dc7-b56d-4b50-9504-598001fe79dc	2026-10-19 20:54:38.267	\N
f96ac22d-a242-44a5-a888-bef558e42592	b52778e3-9d95-49e1-8ab0-e4941aeaa4a2	68a7193c-e80e-4d17-be1e-6b1cc5689fa2	2026-10-19 20:54:38.308	\N
b74baa52-859e-42aa-bf12-69a13dfca29c	99b6b87d-ef05-4180-9aff-7c52591cb56d	f850e488-4084-40e9-bc41-3ab348b3228f	2026-10-19 20:54:38.344	\N
754ab8c3-e2d3-4ff8-a623-d8714bc4c7e7	d2ce9765-33d9-43b0-a4ea-49e7a3235ecd	33c89d75-7ff3-4e56-b9bd-6db4e5248ce7	2026-10-19 20:54:38.385	\N
1c2baec6-0f56-4bc9-9f90-646672950353	ebd74ab5-9f11-464a-a723-573976650ecf	4f020315-6fef-42b4-b351-07c20e89c155	2026-10-19 20:54:38.422	\N
ef38f968-3096-4c87-abbe-58bc0bf2f23e	b9d5801e-a876-4bb4-8f96-38100efb9486	9d3cc220-0482-4d7d-a06a-4a9b560a773a	2026-10-19 20:54:38.464	\N
96f427ff-e8df-40e1-b459-03b2a89773b8	0e193cd9-cfdc-49f6-8f4d-e3066ece6efd	ad32a00c-4856-4797-9e92-d0adc47dd03d	2026-10-19 20:54:38.511	\N
bc8c1abb-ff17-43e6-b016-bbee6d9728a8	080176c7-ce58-4a7f-ba60-653a69205d08	bd8140bd-cf12-4c58-9bac-0030e6342c87	2026-10-19 20:54:36.68	2026-10-19 20:57:32.127
cbd5619c-8ad4-4e0c-ae65-c8c8f882f4f5	4f18879e-11d8-46f4-bec7-4cf7849f9b7a	b0b4c032-2268-4a9e-ac39-16124429e2c9	2026-10-19 20:54:37.606	2026-10-19 20:59:39.339
\.


--
-- Data for Name: Settings; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Settings" (id, "tenantId", "branchId", key, value, "updatedAt") FROM stdin;
e8994997-ae7b-43d3-86aa-73990913635b	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	library_timing	{"open":"06:00","close":"23:00"}	2026-10-19 20:54:38.71
486782ff-5ad1-44af-b355-4ee652920198	bc1c3e43-9c01-4f17-9b81-39430c671e34	b38737cd-11f6-461a-9a07-8f91a478f6a2	currency	{"symbol":"₹","code":"INR"}	2026-10-19 20:54:38.713
da03daa1-4ee7-404b-ae32-fde6c8bcf865	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	library_timing	{"open":"06:00","close":"23:00"}	2026-10-19 20:54:38.715
4664056d-b851-48e0-b20c-9ce3a111b0a9	bc1c3e43-9c01-4f17-9b81-39430c671e34	f859edc4-7244-4ac9-9b76-33a1fc6589d8	currency	{"symbol":"₹","code":"INR"}	2026-10-19 20:54:38.717
bc244071-0f6e-4ca4-9e7c-54f3cd8ceaed	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	dd04734e-f0cf-49a7-b956-3c655518a8a9	library_timing	{"open":"07:00","close":"22:00"}	2026-10-19 20:54:39.184
\.


--
-- Data for Name: Subscription; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Subscription" (id, "tenantId", "memberId", "planId", "startDate", "endDate", status, "assignedSeatId", "assignedLockerId", "createdAt", "updatedAt") FROM stdin;
049b892a-8f1e-49ec-8ae4-3e140f7bc373	bc1c3e43-9c01-4f17-9b81-39430c671e34	966f4c83-927a-4cff-b31f-feda587ca954	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-10-05 20:54:36.661	2027-04-03 20:54:36.661	ACTIVE	312e722a-11ef-4f5c-b12b-ddc326907f81	84719b8c-cf00-40ba-993f-8d2c96571a82	2026-10-19 20:54:36.729	2026-10-19 20:54:36.729
52051875-e9d7-46b6-b8c0-ffb6e5a7aa64	bc1c3e43-9c01-4f17-9b81-39430c671e34	983e45a0-32d7-446b-9b42-8d194418e356	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-07-07 20:54:36.661	2027-01-03 20:54:36.661	ACTIVE	48ae47ed-4123-4a71-88b4-22c8ba5b0373	6144a910-5201-41fb-bbb7-85176a51fbc5	2026-10-19 20:54:36.769	2026-10-19 20:54:36.769
604edc38-be54-4e58-8b94-f30e7830456f	bc1c3e43-9c01-4f17-9b81-39430c671e34	66480f91-7930-4ae8-a7a9-ac4ea2c8aa0f	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-10-17 20:54:36.661	2027-04-15 20:54:36.661	ACTIVE	fe3c2b01-e554-46ed-a0f5-e8de921f7aeb	5585b9a3-dffb-4a1b-8acb-00848d286af2	2026-10-19 20:54:36.809	2026-10-19 20:54:36.809
915c2cf9-033f-4283-be49-29af3a5d1527	bc1c3e43-9c01-4f17-9b81-39430c671e34	a16f37e6-15a1-44bf-90eb-a3d70e27992c	4ec4a8b2-69e5-45c3-b242-6947e4116735	2026-07-03 20:54:36.661	2027-07-03 20:54:36.661	ACTIVE	a96fb5bf-4bae-449a-8bc6-d236c956de0b	\N	2026-10-19 20:54:36.847	2026-10-19 20:54:36.847
23d19f46-274c-4a5e-a099-b4681fa2e169	bc1c3e43-9c01-4f17-9b81-39430c671e34	71e1c621-92af-40af-ba88-699ad0e37f07	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-09-23 20:54:36.661	2027-03-22 20:54:36.661	ACTIVE	37af6ffb-a7d7-4f78-8d60-e0e6fe7fb622	\N	2026-10-19 20:54:36.882	2026-10-19 20:54:36.882
d45ec3e7-abd8-423e-93c0-34f834b05d7e	bc1c3e43-9c01-4f17-9b81-39430c671e34	cd164b6e-4f99-4237-8acb-5ca7e9e860d7	4a6eccdb-6045-4806-9845-705ef7f69175	2026-08-22 20:54:36.661	2026-11-20 20:54:36.661	ACTIVE	d744b408-dce0-4a00-941c-156992c72c77	\N	2026-10-19 20:54:36.916	2026-10-19 20:54:36.916
65139a80-99e0-4ee2-a676-e937ac2a4f74	bc1c3e43-9c01-4f17-9b81-39430c671e34	10028bb5-3bd9-42a3-b5d8-d635b67456b3	4ec4a8b2-69e5-45c3-b242-6947e4116735	2026-07-12 20:54:36.661	2027-07-12 20:54:36.661	ACTIVE	862be2f3-ffd9-468e-865e-1e8d58def5ab	\N	2026-10-19 20:54:36.951	2026-10-19 20:54:36.951
8d2b40b2-90b4-41ba-b183-0e880136373c	bc1c3e43-9c01-4f17-9b81-39430c671e34	ccb1528b-de83-4b6b-a79b-77971e869a78	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-03 20:54:36.661	2026-12-02 20:54:36.661	ACTIVE	675da6be-a3b5-488c-9fca-76e68114cc3e	\N	2026-10-19 20:54:36.988	2026-10-19 20:54:36.988
72d601b6-b978-4cc1-bf77-39150d12e563	bc1c3e43-9c01-4f17-9b81-39430c671e34	4373d996-1b6d-4df3-b930-e8837fb6f339	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-09-18 20:54:36.661	2027-03-17 20:54:36.661	ACTIVE	c2c3b101-787e-446b-9d0b-6c063020b118	\N	2026-10-19 20:54:37.028	2026-10-19 20:54:37.028
214ff5be-1c2d-4d87-9599-06acbfe9a9a6	bc1c3e43-9c01-4f17-9b81-39430c671e34	9716ff52-823b-4830-9bbf-b831f03769a1	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-08-15 20:54:36.661	2027-02-11 20:54:36.661	ACTIVE	3a9bc683-e281-49bb-8e3d-386c4ac729db	\N	2026-10-19 20:54:37.064	2026-10-19 20:54:37.064
e48d5264-7c1d-4784-8826-5a1c0a5dd577	bc1c3e43-9c01-4f17-9b81-39430c671e34	a3219ad2-c46a-4722-ab47-8a173dc78be7	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-10-02 20:54:36.661	2026-11-01 20:54:36.661	ACTIVE	f017f591-841d-4fbe-9ab4-ba36f639f133	\N	2026-10-19 20:54:37.1	2026-10-19 20:54:37.1
5c6d6d8d-dfd0-4e35-b6ac-0363d347d9c5	bc1c3e43-9c01-4f17-9b81-39430c671e34	6e891504-a247-41c5-8aed-86c703b11e46	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-02 20:54:36.661	2026-12-01 20:54:36.661	ACTIVE	85962495-c2aa-46f7-b72b-876f5d0d3238	\N	2026-10-19 20:54:37.14	2026-10-19 20:54:37.14
b9aa83ec-1fdb-4e6e-b059-b03a1081fc33	bc1c3e43-9c01-4f17-9b81-39430c671e34	1d674052-35ab-4200-835b-ca52f506f055	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-10-08 20:54:36.661	2026-11-07 20:54:36.661	ACTIVE	1685ff9d-2d40-4ccd-b3f2-63e86b0a3aca	\N	2026-10-19 20:54:37.178	2026-10-19 20:54:37.178
16f91a2d-5366-4e9a-84ca-08fce52880f8	bc1c3e43-9c01-4f17-9b81-39430c671e34	a63552a9-04e9-4b0d-aa4c-9bee52ba93fa	4ec4a8b2-69e5-45c3-b242-6947e4116735	2026-02-22 20:54:36.661	2027-02-22 20:54:36.661	ACTIVE	72f65226-990a-4da9-b511-d1e81cd0f6cc	\N	2026-10-19 20:54:37.214	2026-10-19 20:54:37.214
55e46937-c8f3-4a38-85a0-435ead098c70	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e5f1f1e-885c-4e96-a455-2acfb95d6f2f	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-27 20:54:36.661	2026-12-26 20:54:36.661	ACTIVE	1443ac46-17c8-4e53-9c77-5af8e6293c20	\N	2026-10-19 20:54:37.241	2026-10-19 20:54:37.241
66d55e94-ab45-4112-be89-69ea36a41091	bc1c3e43-9c01-4f17-9b81-39430c671e34	d380cc18-2a3c-4a92-b54e-0eefba57c039	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-27 20:54:36.661	2026-12-26 20:54:36.661	ACTIVE	592cabc7-5cf3-45d6-9a48-5b678f88b4a6	\N	2026-10-19 20:54:37.275	2026-10-19 20:54:37.275
b3a4a877-6030-4bd2-89e9-6f7052ba6f1e	bc1c3e43-9c01-4f17-9b81-39430c671e34	f2e21e7a-13f0-44ca-ad2e-231716100a72	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-14 20:54:36.661	2026-12-13 20:54:36.661	ACTIVE	b3a4386f-bf5b-47b2-8f9c-1faa32373423	\N	2026-10-19 20:54:37.311	2026-10-19 20:54:37.311
f0dff270-dec5-443f-bc86-c59c2bf3a37b	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a69dcaf-1408-4691-87e4-85faf49a9045	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-09-29 20:54:36.661	2026-10-29 20:54:36.661	ACTIVE	056c5f61-ee57-418a-b950-9c1e7986ed74	\N	2026-10-19 20:54:37.341	2026-10-19 20:54:37.341
0d6d0f13-e288-4120-9198-616f9a029e82	bc1c3e43-9c01-4f17-9b81-39430c671e34	2a129842-c0ae-49e4-9811-b0dedf0bc1e7	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-10-18 20:54:36.661	2026-11-17 20:54:36.661	ACTIVE	8c94351d-e7f5-4867-a5a4-d6ab3fa554e3	\N	2026-10-19 20:54:37.376	2026-10-19 20:54:37.376
cb8b0192-20fa-4bdb-8c2d-c40e6eddb609	bc1c3e43-9c01-4f17-9b81-39430c671e34	3aaa92d4-de08-4fce-b7bb-f600e3a664d2	4ec4a8b2-69e5-45c3-b242-6947e4116735	2025-10-24 20:54:36.661	2026-10-24 20:54:36.661	ACTIVE	71771036-dbd6-422e-88e4-a25374838694	\N	2026-10-19 20:54:37.411	2026-10-19 20:54:37.411
4d018109-12a7-4440-a4f0-41cec7f9500e	bc1c3e43-9c01-4f17-9b81-39430c671e34	1abaec6f-b752-42ff-8c14-3a99882ca61b	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-09-28 20:54:36.661	2026-10-28 20:54:36.661	ACTIVE	8f0cc42c-2615-41d6-83fb-219777f3da13	\N	2026-10-19 20:54:37.439	2026-10-19 20:54:37.439
3789ca66-8e59-422c-b639-4243aeb852d2	bc1c3e43-9c01-4f17-9b81-39430c671e34	35e08d05-3694-4a5a-b044-6131fc6043f9	3feadfca-4914-44ed-b1d6-c3c836fea678	2026-04-25 20:54:36.661	2026-10-22 20:54:36.661	ACTIVE	781501d2-c089-4e29-854c-ee6da4360d59	\N	2026-10-19 20:54:37.467	2026-10-19 20:54:37.467
67ca78a8-4692-4502-8cb5-4b255419e0b7	bc1c3e43-9c01-4f17-9b81-39430c671e34	5d729459-dddd-4551-a0b1-9d4ed51073c5	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-09-21 20:54:36.661	2026-10-21 20:54:36.661	ACTIVE	176866ec-1e73-4f99-b55e-93141f5c1579	\N	2026-10-19 20:54:37.495	2026-10-19 20:54:37.495
12c9b3ed-b8fe-40f1-8e58-4c2a523f7d41	bc1c3e43-9c01-4f17-9b81-39430c671e34	41b999cb-9fa5-4868-996e-5c907ef1c967	4a6eccdb-6045-4806-9845-705ef7f69175	2026-07-29 20:54:36.661	2026-10-27 20:54:36.661	ACTIVE	c8f209ad-3b13-4966-a753-81f4b041483f	\N	2026-10-19 20:54:37.533	2026-10-19 20:54:37.533
c43ee837-2af1-4ddf-8e25-d224e8069330	bc1c3e43-9c01-4f17-9b81-39430c671e34	f4791d23-2b5f-4550-a005-e849ed11cd18	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-08-23 20:54:36.661	2026-09-22 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:37.566	2026-10-19 20:54:37.566
622a463c-4c88-4f78-a9a5-56d0a9e9a5be	bc1c3e43-9c01-4f17-9b81-39430c671e34	70db2f3e-4dce-4e72-a8bd-6cd89c91e42f	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-09-11 20:54:36.661	2026-10-11 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:37.571	2026-10-19 20:54:37.571
c535bd02-eacd-472e-b965-6925c3fc9d4c	bc1c3e43-9c01-4f17-9b81-39430c671e34	a5ca208c-0154-4468-a5f9-83355a15fa01	4a6eccdb-6045-4806-9845-705ef7f69175	2026-05-27 20:54:36.661	2026-08-25 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:37.578	2026-10-19 20:54:37.578
4c2df4ac-c07f-450f-8366-56e27deab752	bc1c3e43-9c01-4f17-9b81-39430c671e34	4e0754b6-fb11-48d6-8fe8-3fd40c263652	8032650d-d9f8-47ae-9be9-80f95ccca567	2026-08-15 20:54:36.661	2026-09-14 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:37.588	2026-10-19 20:54:37.588
0f998643-8968-4843-bf40-65297ddc6daf	bc1c3e43-9c01-4f17-9b81-39430c671e34	d0f0687d-842b-4156-87d8-31743f193f8c	4ec4a8b2-69e5-45c3-b242-6947e4116735	2025-10-11 20:54:36.661	2026-10-11 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:37.595	2026-10-19 20:54:37.595
4df57773-1e13-4f64-a544-31ffbfd5431c	bc1c3e43-9c01-4f17-9b81-39430c671e34	46cbbfad-082b-4048-8d2c-89de79c4c40a	6ae05492-26cf-4726-ad17-31dac2782000	2026-09-08 20:54:36.661	2026-12-07 20:54:36.661	ACTIVE	22936b37-da00-4fd0-bab5-c9ce67c93266	18f9a7b8-6414-46a1-8fd7-f8b57b759a6d	2026-10-19 20:54:37.648	2026-10-19 20:54:37.648
281f9dad-7a18-4a74-906b-410e973d4b80	bc1c3e43-9c01-4f17-9b81-39430c671e34	0949b3c4-5702-4ff7-a410-b02c68d1df88	c4d09045-f531-4f62-af46-78f5a3be90a3	2026-09-19 20:54:36.661	2027-09-19 20:54:36.661	ACTIVE	e5dd7b1c-0e3f-46ca-98e8-defa4d0cfac0	af79803f-aa93-4eac-8b91-e335f1299051	2026-10-19 20:54:37.683	2026-10-19 20:54:37.683
4df6caee-ce62-45f3-8eca-6358b6fe80d3	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f9aaef2-4bdf-4bbc-b664-d5ec50af035d	c4d09045-f531-4f62-af46-78f5a3be90a3	2026-03-01 20:54:36.661	2027-03-01 20:54:36.661	ACTIVE	ca177a31-51bd-45f0-b702-cc288bcba8ca	5d307680-490e-464f-b1ba-b52b68322333	2026-10-19 20:54:37.724	2026-10-19 20:54:37.724
bcf63d3c-de17-49cf-8d26-2e845755aa6a	bc1c3e43-9c01-4f17-9b81-39430c671e34	d323833f-c228-4fba-9788-d86b4480f971	450884d1-421a-4d9e-b722-94df6aa525db	2026-08-20 20:54:36.661	2027-02-16 20:54:36.661	ACTIVE	c039424e-1cb8-406b-a748-dd82087fab5e	\N	2026-10-19 20:54:37.762	2026-10-19 20:54:37.762
5f23aaff-5cc6-48f8-a346-5ea02a89d878	bc1c3e43-9c01-4f17-9b81-39430c671e34	8f25e9a8-859f-4f74-83fe-7d0565020dc4	6ae05492-26cf-4726-ad17-31dac2782000	2026-09-28 20:54:36.661	2026-12-27 20:54:36.661	ACTIVE	a7e39886-89cf-438b-ab64-22b83c291816	\N	2026-10-19 20:54:37.797	2026-10-19 20:54:37.797
c1ad3d19-a3cf-4e7f-a96d-669bb17b6b6e	bc1c3e43-9c01-4f17-9b81-39430c671e34	c4134a9e-bf2c-4603-9064-5643d58bfc24	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-10-13 20:54:36.661	2026-11-12 20:54:36.661	ACTIVE	a2bbcc16-b078-47b0-87d0-4140a388d0fc	\N	2026-10-19 20:54:37.834	2026-10-19 20:54:37.834
89019d60-1222-452c-8e1d-b9b26b0869ca	bc1c3e43-9c01-4f17-9b81-39430c671e34	1bf73e54-0190-4e7b-a6da-f3fb538b21d9	6ae05492-26cf-4726-ad17-31dac2782000	2026-10-03 20:54:36.661	2027-01-01 20:54:36.661	ACTIVE	6bb0a247-9807-4531-8a28-a11e614904dc	\N	2026-10-19 20:54:37.881	2026-10-19 20:54:37.881
ccc21915-2db3-4db2-a315-feb8fe4ba0e9	bc1c3e43-9c01-4f17-9b81-39430c671e34	4fb84b51-7cb5-4488-a20b-046b87c7d314	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-10-08 20:54:36.661	2026-11-07 20:54:36.661	ACTIVE	fb484531-ed55-436d-8bf1-3126b12e5d99	\N	2026-10-19 20:54:37.906	2026-10-19 20:54:37.906
fc98b0fe-63fb-4184-836c-23acd70fee88	bc1c3e43-9c01-4f17-9b81-39430c671e34	3c67bf22-fbb9-4994-a0f3-2381b675474c	c4d09045-f531-4f62-af46-78f5a3be90a3	2026-04-17 20:54:36.661	2027-04-17 20:54:36.661	ACTIVE	c11f6d74-a3e7-454e-b66b-7d4a0e63ddc0	\N	2026-10-19 20:54:37.946	2026-10-19 20:54:37.946
547a597c-e2ff-4e0d-8a2f-b2c4b9a4e933	bc1c3e43-9c01-4f17-9b81-39430c671e34	729bbb15-024f-43c2-ab1f-59786d10b20c	6ae05492-26cf-4726-ad17-31dac2782000	2026-10-11 20:54:36.661	2027-01-09 20:54:36.661	ACTIVE	8b97eb84-d0cc-4b1d-97bd-9dcfc1ad64f3	\N	2026-10-19 20:54:37.985	2026-10-19 20:54:37.985
2d9b8325-e179-4189-9672-50b5104fbb93	bc1c3e43-9c01-4f17-9b81-39430c671e34	1de3ace6-403d-4828-815b-7e490ed5f696	6ae05492-26cf-4726-ad17-31dac2782000	2026-09-24 20:54:36.661	2026-12-23 20:54:36.661	ACTIVE	2a3e7493-cfce-47a3-87f7-c840e5bb53fb	\N	2026-10-19 20:54:38.023	2026-10-19 20:54:38.023
135fc5b1-970e-4186-a64c-00ee16288a71	bc1c3e43-9c01-4f17-9b81-39430c671e34	564dcba4-60c6-49df-a454-e2aa4cc804d9	6ae05492-26cf-4726-ad17-31dac2782000	2026-09-06 20:54:36.661	2026-12-05 20:54:36.661	ACTIVE	c5ac16ca-9a4c-4b80-95bd-3c539c8ffdfc	\N	2026-10-19 20:54:38.057	2026-10-19 20:54:38.057
422fb949-9c3e-4bca-9928-514cf5bbbf29	bc1c3e43-9c01-4f17-9b81-39430c671e34	b82ead3c-eef7-46ff-ade9-93a8462a77bb	450884d1-421a-4d9e-b722-94df6aa525db	2026-08-06 20:54:36.661	2027-02-02 20:54:36.661	ACTIVE	64704e36-8f13-4ace-af1d-55493a56fec7	\N	2026-10-19 20:54:38.093	2026-10-19 20:54:38.093
0913034c-ad75-4435-882e-57219cbc2a74	bc1c3e43-9c01-4f17-9b81-39430c671e34	12110c00-9f5f-4ae1-a193-9edaa64ddf24	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-10-02 20:54:36.661	2026-11-01 20:54:36.661	ACTIVE	92ac9e23-1006-4b22-bd6a-e60c4ae2e68f	\N	2026-10-19 20:54:38.123	2026-10-19 20:54:38.123
f205fc2b-e7cb-42e7-ad8f-60b30ae70f11	bc1c3e43-9c01-4f17-9b81-39430c671e34	0d71421b-bce8-4b83-a054-8e49ad0cdefa	6ae05492-26cf-4726-ad17-31dac2782000	2026-08-25 20:54:36.661	2026-11-23 20:54:36.661	ACTIVE	0692ba06-9286-4195-a5ef-56cbec4e1bd5	\N	2026-10-19 20:54:38.158	2026-10-19 20:54:38.158
3e389760-85cc-4635-9d41-781df1a32db5	bc1c3e43-9c01-4f17-9b81-39430c671e34	26f5b911-ace3-4197-aba0-c907779e8643	450884d1-421a-4d9e-b722-94df6aa525db	2026-08-10 20:54:36.661	2027-02-06 20:54:36.661	ACTIVE	19d2a06d-a5a3-4016-b81e-a57c4af01fb5	\N	2026-10-19 20:54:38.196	2026-10-19 20:54:38.196
eb8989a5-afb4-4199-bc56-73eb76aee93f	bc1c3e43-9c01-4f17-9b81-39430c671e34	cf8b8d2c-2439-44a7-8caf-bfb1777aebb7	6ae05492-26cf-4726-ad17-31dac2782000	2026-10-10 20:54:36.661	2027-01-08 20:54:36.661	ACTIVE	29611eea-b36c-4e90-9201-48e4b5ac34e5	\N	2026-10-19 20:54:38.225	2026-10-19 20:54:38.225
2e195dc7-b56d-4b50-9504-598001fe79dc	bc1c3e43-9c01-4f17-9b81-39430c671e34	95c97cbb-324d-4f5f-aca4-789b3f9c79cf	450884d1-421a-4d9e-b722-94df6aa525db	2026-09-19 20:54:36.661	2027-03-18 20:54:36.661	ACTIVE	3a2fc0f0-0d21-4e6a-ba50-cc123293580b	\N	2026-10-19 20:54:38.262	2026-10-19 20:54:38.262
68a7193c-e80e-4d17-be1e-6b1cc5689fa2	bc1c3e43-9c01-4f17-9b81-39430c671e34	0633ccef-66f0-45d2-a2e1-69211cded599	450884d1-421a-4d9e-b722-94df6aa525db	2026-08-26 20:54:36.661	2027-02-22 20:54:36.661	ACTIVE	b52778e3-9d95-49e1-8ab0-e4941aeaa4a2	\N	2026-10-19 20:54:38.304	2026-10-19 20:54:38.304
f850e488-4084-40e9-bc41-3ab348b3228f	bc1c3e43-9c01-4f17-9b81-39430c671e34	d51ec7cb-e65b-4460-8591-4652e2e3fbfb	6ae05492-26cf-4726-ad17-31dac2782000	2026-07-25 20:54:36.661	2026-10-23 20:54:36.661	ACTIVE	99b6b87d-ef05-4180-9aff-7c52591cb56d	\N	2026-10-19 20:54:38.341	2026-10-19 20:54:38.341
33c89d75-7ff3-4e56-b9bd-6db4e5248ce7	bc1c3e43-9c01-4f17-9b81-39430c671e34	eb7efead-1b61-440e-b02d-2f6c1d57dcbe	6ae05492-26cf-4726-ad17-31dac2782000	2026-07-24 20:54:36.661	2026-10-22 20:54:36.661	ACTIVE	d2ce9765-33d9-43b0-a4ea-49e7a3235ecd	\N	2026-10-19 20:54:38.379	2026-10-19 20:54:38.379
4f020315-6fef-42b4-b351-07c20e89c155	bc1c3e43-9c01-4f17-9b81-39430c671e34	5b52d225-9d50-42a9-8136-b898a64dce95	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-09-21 20:54:36.661	2026-10-21 20:54:36.661	ACTIVE	ebd74ab5-9f11-464a-a723-573976650ecf	\N	2026-10-19 20:54:38.418	2026-10-19 20:54:38.418
9d3cc220-0482-4d7d-a06a-4a9b560a773a	bc1c3e43-9c01-4f17-9b81-39430c671e34	121e8292-5549-4cc3-b708-82bbd0e95352	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-09-20 20:54:36.661	2026-10-20 20:54:36.661	ACTIVE	b9d5801e-a876-4bb4-8f96-38100efb9486	\N	2026-10-19 20:54:38.46	2026-10-19 20:54:38.46
ad32a00c-4856-4797-9e92-d0adc47dd03d	bc1c3e43-9c01-4f17-9b81-39430c671e34	17ad17c5-e3f0-46fd-934f-ac607c3a9810	c4d09045-f531-4f62-af46-78f5a3be90a3	2025-10-22 20:54:36.661	2026-10-22 20:54:36.661	ACTIVE	0e193cd9-cfdc-49f6-8f4d-e3066ece6efd	\N	2026-10-19 20:54:38.505	2026-10-19 20:54:38.505
6200e8e6-8d7f-4747-8fa7-90bbb48ed6bd	bc1c3e43-9c01-4f17-9b81-39430c671e34	270e9f94-4554-4388-a5b2-020ab9e38ee0	450884d1-421a-4d9e-b722-94df6aa525db	2026-03-08 20:54:36.661	2026-09-04 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:38.554	2026-10-19 20:54:38.554
d26d718f-96e4-485b-9c4c-e2b5ba36241e	bc1c3e43-9c01-4f17-9b81-39430c671e34	6cabf6b9-ee6b-4e3c-9186-0a82b4903fef	450884d1-421a-4d9e-b722-94df6aa525db	2026-04-17 20:54:36.661	2026-10-14 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:38.561	2026-10-19 20:54:38.561
c85636d6-ea3a-47b4-93dd-1acac3620600	bc1c3e43-9c01-4f17-9b81-39430c671e34	30948194-891b-4fe6-89a1-a7345e60a0e8	450884d1-421a-4d9e-b722-94df6aa525db	2026-03-31 20:54:36.661	2026-09-27 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:38.568	2026-10-19 20:54:38.568
36c24e42-384b-45e4-a4ec-b26bb41c4209	bc1c3e43-9c01-4f17-9b81-39430c671e34	63e0dff3-aff1-43e6-8e97-f61745f66591	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-08-29 20:54:36.661	2026-09-28 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:38.578	2026-10-19 20:54:38.578
9d334b23-925f-4847-9e1b-d3a43224cdcc	bc1c3e43-9c01-4f17-9b81-39430c671e34	1a279cb6-0b30-40d6-8d98-66ff27ea1e44	6ae05492-26cf-4726-ad17-31dac2782000	2026-06-04 20:54:36.661	2026-09-02 20:54:36.661	EXPIRED	\N	\N	2026-10-19 20:54:38.586	2026-10-19 20:54:38.586
b0b4c032-2268-4a9e-ac39-16124429e2c9	bc1c3e43-9c01-4f17-9b81-39430c671e34	da4fa777-4c2e-49c3-85ff-ca1cdfc4fb11	76551e16-a8a2-4f93-80fa-ee70993c2eed	2026-10-01 20:54:36.661	2026-10-31 20:54:36.661	ACTIVE	\N	\N	2026-10-19 20:54:37.601	2026-10-19 20:59:39.343
bd8140bd-cf12-4c58-9bac-0030e6342c87	bc1c3e43-9c01-4f17-9b81-39430c671e34	80a9b93b-35af-4261-bd10-b6f34294d64c	4a6eccdb-6045-4806-9845-705ef7f69175	2026-09-09 20:54:36.661	2026-12-08 20:54:36.661	ACTIVE	\N	\N	2026-10-19 20:54:36.668	2026-10-19 20:59:39.367
\.


--
-- Data for Name: Tenant; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."Tenant" (id, name, code, slug, logo, phone, email, address, city, state, country, plan, status, settings, "createdAt", "updatedAt") FROM stdin;
bc1c3e43-9c01-4f17-9b81-39430c671e34	Chintamani Library	CML	chintamani-library	\N	9876543210	contact@chintamanilibrary.com	Main Road, Khalilabad	Sant Kabir Nagar	Uttar Pradesh	India	ENTERPRISE	ACTIVE	\N	2026-10-19 20:54:36.32	2026-10-19 20:54:36.32
aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	City Reading Hub	CRH	city-reading-hub	\N	9811223344	info@cityreadinghub.com	Hazratganj Main Market	Lucknow	Uttar Pradesh	India	STANDARD	ACTIVE	\N	2026-10-19 20:54:38.719	2026-10-19 20:54:38.719
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."User" (id, "tenantId", name, email, password, role, phone, "isActive", "createdAt", "updatedAt") FROM stdin;
7040f8ae-462a-4466-a754-806532149a43	\N	Super Admin	superadmin@libraryos.com	$2b$12$CneDMbxuy2bkUsjtdttmQe.wj.y5vCSbOViMOGwVhnpXKPxVEYZ5u	SUPER_ADMIN	9999999999	t	2026-10-19 20:54:36.307	2026-10-19 20:54:36.307
9a3c190a-8440-4ec6-b973-71e69e58251f	bc1c3e43-9c01-4f17-9b81-39430c671e34	Manglesh Mani Tripathi	owner@chintamani.com	$2b$12$USoGvh7kaQlrAb26EFpgQuXnIMN11tc/zTLvn2y/1z9rwcOm4CM0e	OWNER	9999000001	t	2026-10-19 20:54:36.33	2026-10-19 20:54:36.33
1cd7c4a4-5675-40af-95cd-160f441e2028	bc1c3e43-9c01-4f17-9b81-39430c671e34	Rajesh Kumar	admin.khl@chintamani.com	$2b$12$USoGvh7kaQlrAb26EFpgQuXnIMN11tc/zTLvn2y/1z9rwcOm4CM0e	ADMIN	9999000002	t	2026-10-19 20:54:36.333	2026-10-19 20:54:36.333
4a62f404-3c80-4854-b499-1d15688f2ffd	bc1c3e43-9c01-4f17-9b81-39430c671e34	Suresh Verma	admin.mhd@chintamani.com	$2b$12$USoGvh7kaQlrAb26EFpgQuXnIMN11tc/zTLvn2y/1z9rwcOm4CM0e	ADMIN	9999000003	t	2026-10-19 20:54:36.335	2026-10-19 20:54:36.335
5a15ddd9-8c33-48ff-bef5-ab7d26dcd062	bc1c3e43-9c01-4f17-9b81-39430c671e34	Amit Sharma	staff.khl@chintamani.com	$2b$12$YQGVp7Z13GRwW9GAcpajLO/vYhT7sjYtzEkiWisC4Nu8.Nm15cRwW	STAFF	9999000004	t	2026-10-19 20:54:36.337	2026-10-19 20:54:36.337
55ea9478-6a6d-4a4b-b94c-47f3887f6f39	bc1c3e43-9c01-4f17-9b81-39430c671e34	Deepak Yadav	staff.mhd@chintamani.com	$2b$12$YQGVp7Z13GRwW9GAcpajLO/vYhT7sjYtzEkiWisC4Nu8.Nm15cRwW	STAFF	9999000005	t	2026-10-19 20:54:36.34	2026-10-19 20:54:36.34
0b4a578f-eea9-4635-9528-bb193423d3bf	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	Vikas Malhotra	owner@cityreadinghub.com	$2b$12$USoGvh7kaQlrAb26EFpgQuXnIMN11tc/zTLvn2y/1z9rwcOm4CM0e	OWNER	9811000001	t	2026-10-19 20:54:38.724	2026-10-19 20:54:38.724
b2707bd6-a758-4e9c-bd4b-7f83c9a80711	aba7c6dd-fb7f-473d-8ac2-70ee82b3c1ba	Karan Saxena	staff@cityreadinghub.com	$2b$12$YQGVp7Z13GRwW9GAcpajLO/vYhT7sjYtzEkiWisC4Nu8.Nm15cRwW	STAFF	9811000002	t	2026-10-19 20:54:38.726	2026-10-19 20:54:38.726
\.


--
-- Data for Name: UserBranchAccess; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public."UserBranchAccess" (id, "userId", "branchId") FROM stdin;
320e83a1-a8fe-47c7-8f13-02352974e7f8	9a3c190a-8440-4ec6-b973-71e69e58251f	b38737cd-11f6-461a-9a07-8f91a478f6a2
d296e467-be9c-4e15-bd10-34e4491ed28f	9a3c190a-8440-4ec6-b973-71e69e58251f	f859edc4-7244-4ac9-9b76-33a1fc6589d8
d2112b6f-9fa6-4921-9e3c-d6e3ee2b8141	1cd7c4a4-5675-40af-95cd-160f441e2028	b38737cd-11f6-461a-9a07-8f91a478f6a2
a3547544-8312-459f-bc5b-682b54d03902	4a62f404-3c80-4854-b499-1d15688f2ffd	f859edc4-7244-4ac9-9b76-33a1fc6589d8
48d28734-acc3-4700-b6ad-5905f5cb8ecf	5a15ddd9-8c33-48ff-bef5-ab7d26dcd062	b38737cd-11f6-461a-9a07-8f91a478f6a2
9c3679f9-c8ea-463e-977d-4ab6d782f638	55ea9478-6a6d-4a4b-b94c-47f3887f6f39	f859edc4-7244-4ac9-9b76-33a1fc6589d8
f0d9ef15-8a3c-4a32-9735-665ed5971053	0b4a578f-eea9-4635-9528-bb193423d3bf	dd04734e-f0cf-49a7-b956-3c655518a8a9
4c70ddfc-5f20-413d-931d-410261b238f4	b2707bd6-a758-4e9c-bd4b-7f83c9a80711	dd04734e-f0cf-49a7-b956-3c655518a8a9
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: chintamani
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
94096ffe-4ef1-467d-a460-0498038071d1	707b22deeb9fc54dc5ad133d932d414c38beb9e86a7aa66d8fcab1c3de63f74a	2026-09-23 11:57:58.160725+05:30	20260923115717_add_portal_registration_complaints_v2		\N	2026-09-23 11:57:58.160725+05:30	0
\.


--
-- Name: Attendance Attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Attendance"
    ADD CONSTRAINT "Attendance_pkey" PRIMARY KEY (id);


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: BackupLog BackupLog_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."BackupLog"
    ADD CONSTRAINT "BackupLog_pkey" PRIMARY KEY (id);


--
-- Name: Branch Branch_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);


--
-- Name: CommunicationLog CommunicationLog_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_pkey" PRIMARY KEY (id);


--
-- Name: Complaint Complaint_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_pkey" PRIMARY KEY (id);


--
-- Name: Enquiry Enquiry_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Enquiry"
    ADD CONSTRAINT "Enquiry_pkey" PRIMARY KEY (id);


--
-- Name: Expense Expense_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_pkey" PRIMARY KEY (id);


--
-- Name: Feedback Feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_pkey" PRIMARY KEY (id);


--
-- Name: LockerAssignment LockerAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."LockerAssignment"
    ADD CONSTRAINT "LockerAssignment_pkey" PRIMARY KEY (id);


--
-- Name: Locker Locker_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Locker"
    ADD CONSTRAINT "Locker_pkey" PRIMARY KEY (id);


--
-- Name: MemberPortalSession MemberPortalSession_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberPortalSession"
    ADD CONSTRAINT "MemberPortalSession_pkey" PRIMARY KEY (id);


--
-- Name: MemberRegistration MemberRegistration_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberRegistration"
    ADD CONSTRAINT "MemberRegistration_pkey" PRIMARY KEY (id);


--
-- Name: Member Member_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Member"
    ADD CONSTRAINT "Member_pkey" PRIMARY KEY (id);


--
-- Name: MembershipPlan MembershipPlan_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MembershipPlan"
    ADD CONSTRAINT "MembershipPlan_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: PaymentTransaction PaymentTransaction_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentTransaction"
    ADD CONSTRAINT "PaymentTransaction_pkey" PRIMARY KEY (id);


--
-- Name: PaymentVerification PaymentVerification_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentVerification"
    ADD CONSTRAINT "PaymentVerification_pkey" PRIMARY KEY (id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (id);


--
-- Name: Permission Permission_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Permission"
    ADD CONSTRAINT "Permission_pkey" PRIMARY KEY (id);


--
-- Name: QrCode QrCode_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."QrCode"
    ADD CONSTRAINT "QrCode_pkey" PRIMARY KEY (id);


--
-- Name: SeatAssignment SeatAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."SeatAssignment"
    ADD CONSTRAINT "SeatAssignment_pkey" PRIMARY KEY (id);


--
-- Name: Seat Seat_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Seat"
    ADD CONSTRAINT "Seat_pkey" PRIMARY KEY (id);


--
-- Name: Settings Settings_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Settings"
    ADD CONSTRAINT "Settings_pkey" PRIMARY KEY (id);


--
-- Name: Subscription Subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_pkey" PRIMARY KEY (id);


--
-- Name: Tenant Tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Tenant"
    ADD CONSTRAINT "Tenant_pkey" PRIMARY KEY (id);


--
-- Name: UserBranchAccess UserBranchAccess_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."UserBranchAccess"
    ADD CONSTRAINT "UserBranchAccess_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Attendance_checkIn_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Attendance_checkIn_idx" ON public."Attendance" USING btree ("checkIn");


--
-- Name: Attendance_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Attendance_tenantId_idx" ON public."Attendance" USING btree ("tenantId");


--
-- Name: AuditLog_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "AuditLog_tenantId_idx" ON public."AuditLog" USING btree ("tenantId");


--
-- Name: BackupLog_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "BackupLog_createdAt_idx" ON public."BackupLog" USING btree ("createdAt");


--
-- Name: BackupLog_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "BackupLog_status_idx" ON public."BackupLog" USING btree (status);


--
-- Name: Branch_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Branch_tenantId_idx" ON public."Branch" USING btree ("tenantId");


--
-- Name: CommunicationLog_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "CommunicationLog_tenantId_idx" ON public."CommunicationLog" USING btree ("tenantId");


--
-- Name: Complaint_branchId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_branchId_idx" ON public."Complaint" USING btree ("branchId");


--
-- Name: Complaint_branchId_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_branchId_status_idx" ON public."Complaint" USING btree ("branchId", status);


--
-- Name: Complaint_complaintId_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Complaint_complaintId_key" ON public."Complaint" USING btree ("complaintId");


--
-- Name: Complaint_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_createdAt_idx" ON public."Complaint" USING btree ("createdAt");


--
-- Name: Complaint_memberId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_memberId_idx" ON public."Complaint" USING btree ("memberId");


--
-- Name: Complaint_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_status_idx" ON public."Complaint" USING btree (status);


--
-- Name: Complaint_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Complaint_tenantId_idx" ON public."Complaint" USING btree ("tenantId");


--
-- Name: Enquiry_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Enquiry_tenantId_idx" ON public."Enquiry" USING btree ("tenantId");


--
-- Name: Expense_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Expense_tenantId_idx" ON public."Expense" USING btree ("tenantId");


--
-- Name: Feedback_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Feedback_status_idx" ON public."Feedback" USING btree (status);


--
-- Name: Feedback_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Feedback_tenantId_idx" ON public."Feedback" USING btree ("tenantId");


--
-- Name: Locker_branchId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Locker_branchId_idx" ON public."Locker" USING btree ("branchId");


--
-- Name: Locker_branchId_lockerNumber_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Locker_branchId_lockerNumber_key" ON public."Locker" USING btree ("branchId", "lockerNumber");


--
-- Name: Locker_branchId_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Locker_branchId_status_idx" ON public."Locker" USING btree ("branchId", status);


--
-- Name: Locker_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Locker_tenantId_idx" ON public."Locker" USING btree ("tenantId");


--
-- Name: MemberPortalSession_phone_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MemberPortalSession_phone_idx" ON public."MemberPortalSession" USING btree (phone);


--
-- Name: MemberPortalSession_token_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MemberPortalSession_token_idx" ON public."MemberPortalSession" USING btree (token);


--
-- Name: MemberPortalSession_token_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "MemberPortalSession_token_key" ON public."MemberPortalSession" USING btree (token);


--
-- Name: MemberRegistration_applicationId_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "MemberRegistration_applicationId_key" ON public."MemberRegistration" USING btree ("applicationId");


--
-- Name: MemberRegistration_phone_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MemberRegistration_phone_idx" ON public."MemberRegistration" USING btree (phone);


--
-- Name: MemberRegistration_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MemberRegistration_status_idx" ON public."MemberRegistration" USING btree (status);


--
-- Name: MemberRegistration_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MemberRegistration_tenantId_idx" ON public."MemberRegistration" USING btree ("tenantId");


--
-- Name: Member_branchId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_branchId_idx" ON public."Member" USING btree ("branchId");


--
-- Name: Member_branchId_isActive_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_branchId_isActive_idx" ON public."Member" USING btree ("branchId", "isActive");


--
-- Name: Member_branchId_isArchived_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_branchId_isArchived_idx" ON public."Member" USING btree ("branchId", "isArchived");


--
-- Name: Member_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_createdAt_idx" ON public."Member" USING btree ("createdAt");


--
-- Name: Member_isArchived_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_isArchived_idx" ON public."Member" USING btree ("isArchived");


--
-- Name: Member_memberCode_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_memberCode_idx" ON public."Member" USING btree ("memberCode");


--
-- Name: Member_phone_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_phone_idx" ON public."Member" USING btree (phone);


--
-- Name: Member_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Member_tenantId_idx" ON public."Member" USING btree ("tenantId");


--
-- Name: Member_tenantId_memberCode_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Member_tenantId_memberCode_key" ON public."Member" USING btree ("tenantId", "memberCode");


--
-- Name: MembershipPlan_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "MembershipPlan_tenantId_idx" ON public."MembershipPlan" USING btree ("tenantId");


--
-- Name: Notification_isRead_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Notification_isRead_idx" ON public."Notification" USING btree ("isRead");


--
-- Name: Notification_memberId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Notification_memberId_idx" ON public."Notification" USING btree ("memberId");


--
-- Name: Notification_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Notification_tenantId_idx" ON public."Notification" USING btree ("tenantId");


--
-- Name: Notification_tenantId_isRead_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Notification_tenantId_isRead_createdAt_idx" ON public."Notification" USING btree ("tenantId", "isRead", "createdAt");


--
-- Name: PaymentVerification_memberId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "PaymentVerification_memberId_idx" ON public."PaymentVerification" USING btree ("memberId");


--
-- Name: PaymentVerification_paymentId_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "PaymentVerification_paymentId_key" ON public."PaymentVerification" USING btree ("paymentId");


--
-- Name: PaymentVerification_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "PaymentVerification_status_idx" ON public."PaymentVerification" USING btree (status);


--
-- Name: PaymentVerification_status_submittedAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "PaymentVerification_status_submittedAt_idx" ON public."PaymentVerification" USING btree (status, "submittedAt");


--
-- Name: PaymentVerification_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "PaymentVerification_tenantId_idx" ON public."PaymentVerification" USING btree ("tenantId");


--
-- Name: Payment_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_memberId_createdAt_idx" ON public."Payment" USING btree ("memberId", "createdAt");


--
-- Name: Payment_memberId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_memberId_idx" ON public."Payment" USING btree ("memberId");


--
-- Name: Payment_paidAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_paidAt_idx" ON public."Payment" USING btree ("paidAt");


--
-- Name: Payment_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_status_idx" ON public."Payment" USING btree (status);


--
-- Name: Payment_tenantId_createdAt_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_tenantId_createdAt_idx" ON public."Payment" USING btree ("tenantId", "createdAt");


--
-- Name: Payment_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Payment_tenantId_idx" ON public."Payment" USING btree ("tenantId");


--
-- Name: Permission_userId_action_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Permission_userId_action_key" ON public."Permission" USING btree ("userId", action);


--
-- Name: QrCode_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "QrCode_entityType_entityId_idx" ON public."QrCode" USING btree ("entityType", "entityId");


--
-- Name: QrCode_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "QrCode_tenantId_idx" ON public."QrCode" USING btree ("tenantId");


--
-- Name: QrCode_token_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "QrCode_token_key" ON public."QrCode" USING btree (token);


--
-- Name: Seat_branchId_seatNumber_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Seat_branchId_seatNumber_key" ON public."Seat" USING btree ("branchId", "seatNumber");


--
-- Name: Seat_branchId_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Seat_branchId_status_idx" ON public."Seat" USING btree ("branchId", status);


--
-- Name: Seat_seatNumber_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Seat_seatNumber_idx" ON public."Seat" USING btree ("seatNumber");


--
-- Name: Seat_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Seat_status_idx" ON public."Seat" USING btree (status);


--
-- Name: Seat_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Seat_tenantId_idx" ON public."Seat" USING btree ("tenantId");


--
-- Name: Settings_branchId_key_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Settings_branchId_key_key" ON public."Settings" USING btree ("branchId", key);


--
-- Name: Settings_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Settings_tenantId_idx" ON public."Settings" USING btree ("tenantId");


--
-- Name: Subscription_endDate_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_endDate_idx" ON public."Subscription" USING btree ("endDate");


--
-- Name: Subscription_memberId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_memberId_idx" ON public."Subscription" USING btree ("memberId");


--
-- Name: Subscription_memberId_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_memberId_status_idx" ON public."Subscription" USING btree ("memberId", status);


--
-- Name: Subscription_status_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_status_idx" ON public."Subscription" USING btree (status);


--
-- Name: Subscription_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_tenantId_idx" ON public."Subscription" USING btree ("tenantId");


--
-- Name: Subscription_tenantId_status_endDate_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "Subscription_tenantId_status_endDate_idx" ON public."Subscription" USING btree ("tenantId", status, "endDate");


--
-- Name: Tenant_code_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Tenant_code_key" ON public."Tenant" USING btree (code);


--
-- Name: Tenant_slug_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "Tenant_slug_key" ON public."Tenant" USING btree (slug);


--
-- Name: UserBranchAccess_userId_branchId_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "UserBranchAccess_userId_branchId_key" ON public."UserBranchAccess" USING btree ("userId", "branchId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_tenantId_idx; Type: INDEX; Schema: public; Owner: chintamani
--

CREATE INDEX "User_tenantId_idx" ON public."User" USING btree ("tenantId");


--
-- Name: Attendance Attendance_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Attendance"
    ADD CONSTRAINT "Attendance_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Attendance Attendance_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Attendance"
    ADD CONSTRAINT "Attendance_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Attendance Attendance_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Attendance"
    ADD CONSTRAINT "Attendance_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AuditLog AuditLog_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AuditLog AuditLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AuditLog AuditLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Branch Branch_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CommunicationLog CommunicationLog_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."CommunicationLog"
    ADD CONSTRAINT "CommunicationLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Complaint Complaint_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Complaint Complaint_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Complaint Complaint_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Complaint"
    ADD CONSTRAINT "Complaint_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Enquiry Enquiry_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Enquiry"
    ADD CONSTRAINT "Enquiry_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Enquiry Enquiry_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Enquiry"
    ADD CONSTRAINT "Enquiry_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Expense Expense_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Expense Expense_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Feedback Feedback_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Feedback Feedback_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Feedback Feedback_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Feedback"
    ADD CONSTRAINT "Feedback_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: LockerAssignment LockerAssignment_lockerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."LockerAssignment"
    ADD CONSTRAINT "LockerAssignment_lockerId_fkey" FOREIGN KEY ("lockerId") REFERENCES public."Locker"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LockerAssignment LockerAssignment_subscriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."LockerAssignment"
    ADD CONSTRAINT "LockerAssignment_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES public."Subscription"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Locker Locker_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Locker"
    ADD CONSTRAINT "Locker_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Locker Locker_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Locker"
    ADD CONSTRAINT "Locker_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MemberRegistration MemberRegistration_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberRegistration"
    ADD CONSTRAINT "MemberRegistration_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MemberRegistration MemberRegistration_planId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberRegistration"
    ADD CONSTRAINT "MemberRegistration_planId_fkey" FOREIGN KEY ("planId") REFERENCES public."MembershipPlan"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MemberRegistration MemberRegistration_reservedSeatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberRegistration"
    ADD CONSTRAINT "MemberRegistration_reservedSeatId_fkey" FOREIGN KEY ("reservedSeatId") REFERENCES public."Seat"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MemberRegistration MemberRegistration_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MemberRegistration"
    ADD CONSTRAINT "MemberRegistration_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Member Member_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Member"
    ADD CONSTRAINT "Member_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Member Member_registrationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Member"
    ADD CONSTRAINT "Member_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES public."MemberRegistration"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Member Member_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Member"
    ADD CONSTRAINT "Member_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MembershipPlan MembershipPlan_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MembershipPlan"
    ADD CONSTRAINT "MembershipPlan_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MembershipPlan MembershipPlan_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."MembershipPlan"
    ADD CONSTRAINT "MembershipPlan_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Notification Notification_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PaymentTransaction PaymentTransaction_paymentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentTransaction"
    ADD CONSTRAINT "PaymentTransaction_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES public."Payment"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PaymentVerification PaymentVerification_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentVerification"
    ADD CONSTRAINT "PaymentVerification_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PaymentVerification PaymentVerification_paymentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentVerification"
    ADD CONSTRAINT "PaymentVerification_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES public."Payment"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PaymentVerification PaymentVerification_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."PaymentVerification"
    ADD CONSTRAINT "PaymentVerification_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment Payment_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Payment Payment_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Permission Permission_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Permission"
    ADD CONSTRAINT "Permission_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QrCode QrCode_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."QrCode"
    ADD CONSTRAINT "QrCode_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SeatAssignment SeatAssignment_seatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."SeatAssignment"
    ADD CONSTRAINT "SeatAssignment_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES public."Seat"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SeatAssignment SeatAssignment_subscriptionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."SeatAssignment"
    ADD CONSTRAINT "SeatAssignment_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES public."Subscription"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Seat Seat_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Seat"
    ADD CONSTRAINT "Seat_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Seat Seat_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Seat"
    ADD CONSTRAINT "Seat_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Settings Settings_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Settings"
    ADD CONSTRAINT "Settings_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Settings Settings_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Settings"
    ADD CONSTRAINT "Settings_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Subscription Subscription_assignedLockerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_assignedLockerId_fkey" FOREIGN KEY ("assignedLockerId") REFERENCES public."Locker"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Subscription Subscription_assignedSeatId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_assignedSeatId_fkey" FOREIGN KEY ("assignedSeatId") REFERENCES public."Seat"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Subscription Subscription_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public."Member"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Subscription Subscription_planId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_planId_fkey" FOREIGN KEY ("planId") REFERENCES public."MembershipPlan"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Subscription Subscription_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."Subscription"
    ADD CONSTRAINT "Subscription_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserBranchAccess UserBranchAccess_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."UserBranchAccess"
    ADD CONSTRAINT "UserBranchAccess_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserBranchAccess UserBranchAccess_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."UserBranchAccess"
    ADD CONSTRAINT "UserBranchAccess_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_tenantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chintamani
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES public."Tenant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict jRdUYkBrDMQLo7tAcNJu0HloG6lTFABqhrOt7lBV7PvXxvOidiB1inNwbJcRSb6

