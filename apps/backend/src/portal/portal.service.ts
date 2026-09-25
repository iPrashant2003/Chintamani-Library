import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  SendOtpDto,
  VerifyOtpDto,
  PortalRegisterDto,
  PortalPaymentDto,
  PortalComplaintDto,
  PortalFeedbackDto,
  PortalAttendanceDto,
} from './dto/portal.dto';
import * as crypto from 'crypto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';

@Injectable()
export class PortalService {
  constructor(private readonly prisma: PrismaService) {}

  private cleanPhone(phone: string): string {
    return phone.replace(/[^\d]/g, '');
  }

  // ── OTP & AUTH ─────────────────────────────────────────────────────────────

  async sendOtp(dto: SendOtpDto) {
    const phone = this.cleanPhone(dto.phone);
    if (!phone || phone.length < 10) {
      throw new BadRequestException('Please provide a valid 10-digit mobile number');
    }

    // Generate 6 digit OTP (for production/mock: 123456 or random)
    const otp = process.env.APP_ENV === 'production' 
      ? Math.floor(100000 + Math.random() * 900000).toString() 
      : '123456';

    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Check if phone belongs to existing member
    const member = await this.prisma.member.findFirst({
      where: { phone: { contains: phone.slice(-10) } },
      select: { id: true, name: true, memberCode: true, isActive: true },
    });

    // Check if phone has pending registration
    const pendingReg = await this.prisma.memberRegistration.findFirst({
      where: { phone: { contains: phone.slice(-10) } },
      orderBy: { submittedAt: 'desc' },
      select: { applicationId: true, status: true, name: true },
    });

    await this.prisma.memberPortalSession.create({
      data: {
        phone,
        otp,
        memberId: member?.id || null,
        expiresAt,
      },
    });

    console.log(`[PORTAL OTP] Generated OTP ${otp} for phone ${phone}`);

    return {
      success: true,
      message: 'OTP sent successfully to your mobile number',
      isRegisteredMember: !!member?.isActive,
      hasPendingRegistration: pendingReg?.status === 'PENDING',
      applicationId: pendingReg?.applicationId,
      devOtp: process.env.APP_ENV !== 'production' ? otp : undefined,
    };
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const phone = this.cleanPhone(dto.phone);
    const session = await this.prisma.memberPortalSession.findFirst({
      where: {
        phone: { contains: phone.slice(-10) },
        otp: dto.otp,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!session) {
      throw new BadRequestException('Invalid or expired OTP. Please try again.');
    }

    const token = crypto.randomUUID();

    await this.prisma.memberPortalSession.update({
      where: { id: session.id },
      data: { verified: true, token },
    });

    // Fetch member if exists
    const member = await this.prisma.member.findFirst({
      where: { phone: { contains: phone.slice(-10) } },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { plan: true, seat: true, locker: true },
          take: 1,
        },
      },
    });

    // Check registration status if no active member
    const registration = await this.prisma.memberRegistration.findFirst({
      where: { phone: { contains: phone.slice(-10) } },
      orderBy: { submittedAt: 'desc' },
    });

    return {
      verified: true,
      token,
      member: member ? {
        id: member.id,
        name: member.name,
        memberCode: member.memberCode,
        phone: member.phone,
        isActive: member.isActive,
        activeSubscription: member.subscriptions[0] || null,
      } : null,
      registration: registration ? {
        applicationId: registration.applicationId,
        status: registration.status,
        name: registration.name,
        submittedAt: registration.submittedAt,
        rejectionReason: registration.rejectionReason,
      } : null,
    };
  }

  // ── LIBRARY & PLAN INFO ───────────────────────────────────────────────────

  private async ensureRealBranchSeats(branch: any) {
    if (!branch) return;
    const isMehdawal = branch.name?.toLowerCase().includes('mehda') ?? true;
    const totalRequired = isMehdawal ? 65 : 72;
    const prefix = isMehdawal ? 'M' : 'K';

    const existingSeats = await this.prisma.seat.findMany({
      where: {
        branchId: branch.id,
        seatNumber: { startsWith: prefix },
      },
      select: { seatNumber: true },
    });

    const existingNumbers = new Set(existingSeats.map((s) => s.seatNumber));

    const newSeats: any[] = [];
    for (let i = 1; i <= totalRequired; i++) {
      const numStr = i < 10 ? '0' + i : '' + i;
      const seatNumber = `${prefix}${numStr}`;
      if (!existingNumbers.has(seatNumber)) {
        newSeats.push({
          tenantId: branch.tenantId,
          branchId: branch.id,
          seatNumber,
          floor: 'Single Hall',
          status: 'AVAILABLE',
        });
      }
    }

    if (newSeats.length > 0) {
      await this.prisma.seat.createMany({
        data: newSeats,
        skipDuplicates: true,
      });
    }
  }

  async getLibraryInfo(branchId?: string) {
    let branch: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, branchId);
    if (branchInfo) {
      branch = await this.prisma.branch.findUnique({
        where: { id: branchInfo.id },
        include: { tenant: true },
      });
    }

    if (!branch) {
      branch = await this.prisma.branch.findFirst({
        where: { name: { contains: 'Mehdawal', mode: 'insensitive' } },
        include: { tenant: true },
      }) || await this.prisma.branch.findFirst({ include: { tenant: true } });
    }

    if (!branch) {
      const tenant = await this.prisma.tenant.findFirst({ include: { branches: true } });
      branch = tenant?.branches[0] ? { ...tenant.branches[0], tenant } : null;
    }

    if (branch) {
      await this.ensureRealBranchSeats(branch);
    }

    const isMehdawal = branch?.name?.toLowerCase().includes('mehda') ?? true;
    const totalSeats = isMehdawal ? 65 : 72;
    const seatStats = await this.getSeatStats(branch?.id);

    return {
      libraryName: branch?.tenant?.name || 'Chintamani Library',
      branchName: branch?.name || (isMehdawal ? 'Chintamani Library – Mehdawal' : 'Chintamani Library – Khalilabad'),
      branchId: branch?.id,
      address: branch?.address || (isMehdawal ? 'Station Road, Mehdawal, Sant Kabir Nagar (272202)' : 'Main Road, Near Moti Chauraha, Khalilabad (272175)'),
      phone: branch?.phone || branch?.tenant?.phone || '9415919277',
      email: branch?.tenant?.email || 'contact@chintamanilibrary.com',
      upiId: 'prashantmanitripathi2003-2@oksbi', // Official UPI VPA
      upiName: 'Prashant Mani Tripathi',
      totalSeats,
      hallName: 'Single Hall',
      seatStats,
    };
  }

  async getPlans(branchId?: string) {
    let targetBranchId = branchId;
    if (branchId) {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) targetBranchId = branchInfo.id;
    }

    const where: any = { isActive: true };
    if (targetBranchId) where.branchId = targetBranchId;

    const plans = await this.prisma.membershipPlan.findMany({
      where,
      orderBy: { price: 'asc' },
    });

    // Ensure 24hr, 12hr, 6hr are clearly flagged
    return plans.map((p) => {
      const is24h = p.name.toLowerCase().includes('24') || p.seatAllocation === 'AUTO';
      const is12h = p.name.toLowerCase().includes('12');
      const is6h = p.name.toLowerCase().includes('6');

      return {
        id: p.id,
        name: p.name,
        durationDays: p.durationDays,
        price: p.price,
        includesSeat: p.includesSeat,
        includesLocker: p.includesLocker,
        seatAllocation: is24h ? 'AUTO' : 'ADMIN',
        allocationLabel: is24h ? 'Automatically allocated from available seats' : 'Admin assigned upon approval',
        badge: is24h ? '24 Hours Auto Seat' : is12h ? '12 Hours Dedicated' : is6h ? '6 Hours Flexible' : undefined,
      };
    });
  }

  async getSeatStats(branchId?: string) {
    let branch: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, branchId);
    if (branchInfo) {
      branch = await this.prisma.branch.findUnique({
        where: { id: branchInfo.id },
        include: { tenant: true },
      });
    }

    if (!branch) {
      branch = await this.prisma.branch.findFirst({
        where: { name: { contains: 'Mehdawal', mode: 'insensitive' } },
        include: { tenant: true },
      }) || await this.prisma.branch.findFirst({ include: { tenant: true } });
    }

    if (branch) {
      await this.ensureRealBranchSeats(branch);
    }

    const isMehdawal = branch?.name?.toLowerCase().includes('mehda') ?? true;
    const prefix = isMehdawal ? 'M' : 'K';
    const totalRequired = isMehdawal ? 65 : 72;

    const where: any = branch
      ? { branchId: branch.id, seatNumber: { startsWith: prefix } }
      : { seatNumber: { startsWith: prefix } };

    const [dbTotal, available, reserved, occupied, blocked] = await Promise.all([
      this.prisma.seat.count({ where }),
      this.prisma.seat.count({ where: { ...where, status: 'AVAILABLE' } }),
      this.prisma.seat.count({ where: { ...where, status: 'RESERVED' } }),
      this.prisma.seat.count({ where: { ...where, status: 'OCCUPIED' } }),
      this.prisma.seat.count({ where: { ...where, status: 'BLOCKED' } }),
    ]);

    const total = dbTotal > 0 ? dbTotal : totalRequired;

    return {
      branchId: branch?.id,
      branchName: branch?.name,
      total,
      available: available > 0 ? available : (total - reserved - occupied - blocked),
      reserved,
      occupied,
      blocked,
    };
  }

  // ── NEW MEMBER REGISTRATION ───────────────────────────────────────────────

  async register(dto: PortalRegisterDto) {
    const phone = this.cleanPhone(dto.phone);
    if (!phone || phone.length < 10) {
      throw new BadRequestException('Please provide a valid 10-digit mobile number');
    }

    // 1. Duplicate Member Protection
    const existingMember = await this.prisma.member.findFirst({
      where: { phone: { contains: phone.slice(-10) }, isActive: true },
    });
    if (existingMember) {
      throw new BadRequestException(
        'An active account already exists for this mobile number. Please log in or contact the library administrator.'
      );
    }

    const pendingReg = await this.prisma.memberRegistration.findFirst({
      where: { phone: { contains: phone.slice(-10) }, status: 'PENDING' },
    });
    if (pendingReg) {
      throw new BadRequestException(
        `An application (${pendingReg.applicationId}) is already pending review for this mobile number. Please check status.`
      );
    }

    // Resolve Branch & Tenant strictly (Mehdawal vs Khalilabad)
    const branchInfo = await resolveBranchInfo(this.prisma, dto.branch || dto.branchId);
    let branch: any = null;
    if (branchInfo) {
      branch = await this.prisma.branch.findUnique({
        where: { id: branchInfo.id },
        include: { tenant: true },
      });
    }

    if (!branch) {
      branch = await this.prisma.branch.findFirst({
        where: { name: { contains: 'Mehdawal', mode: 'insensitive' } },
        include: { tenant: true },
      }) || await this.prisma.branch.findFirst({ include: { tenant: true } });
    }

    if (!branch) {
      throw new NotFoundException('Selected library branch not found. Please choose Mehdawal or Khalilabad.');
    }

    // Ensure Single Hall real seats exist for this branch (65 for Mehdawal, 72 for Khalilabad)
    await this.ensureRealBranchSeats(branch);
    const isMehdawal = branch.name?.toLowerCase().includes('mehda') ?? true;
    const expectedPrefix = isMehdawal ? 'M' : 'K';

    // Resolve Plan
    const plan = await this.prisma.membershipPlan.findUnique({
      where: { id: dto.planId },
    });
    if (!plan) {
      throw new NotFoundException('Selected membership plan not found');
    }

    // 2. Strict Branch-Based Seat Allocation & Anti-Cross-Branch Validation
    let reservedSeat: any = null;
    const requestedSeat = (dto.seatNumber || dto.seatId || '').trim();

    if (requestedSeat) {
      // Cross-branch prefix verification
      const upperReq = requestedSeat.toUpperCase();
      if (isMehdawal && upperReq.startsWith('K')) {
        throw new BadRequestException(
          `Cross-Branch Seat Violation: Seat "${requestedSeat}" belongs to Khalilabad Branch, but registration is for Mehdawal Branch. Cross-branch seat allocation is strictly forbidden.`
        );
      }
      if (!isMehdawal && upperReq.startsWith('M')) {
        throw new BadRequestException(
          `Cross-Branch Seat Violation: Seat "${requestedSeat}" belongs to Mehdawal Branch, but registration is for Khalilabad Branch. Cross-branch seat allocation is strictly forbidden.`
        );
      }

      const cleanNum = requestedSeat.replace(/^(M|K|Seat)[\s-_]*/i, '');
      const paddedNum = cleanNum.padStart(2, '0');
      const normalizedSeatNumber = `${expectedPrefix}${paddedNum}`;

      reservedSeat = await this.prisma.seat.findFirst({
        where: {
          branchId: branch.id,
          OR: [
            ...(dto.seatId ? [{ id: dto.seatId }] : []),
            { seatNumber: requestedSeat },
            { seatNumber: normalizedSeatNumber },
            { seatNumber: cleanNum },
            { seatNumber: paddedNum },
          ],
        },
      });

      if (reservedSeat && reservedSeat.status !== 'AVAILABLE') {
        throw new BadRequestException(
          `Seat "${reservedSeat.seatNumber}" in ${branch.name} is currently ${reservedSeat.status.toLowerCase()}. Please select an available seat.`
        );
      }
    }

    // If no seat requested or requested seat wasn't found, perform deterministic allocation strictly within THIS branch
    if (!reservedSeat) {
      reservedSeat = await this.prisma.seat.findFirst({
        where: {
          branchId: branch.id,
          seatNumber: { startsWith: expectedPrefix },
          status: 'AVAILABLE',
        },
        orderBy: { seatNumber: 'asc' },
      });
    }

    if (!reservedSeat) {
      throw new BadRequestException(
        `No seats are currently available in the single hall at ${branch.name}. Please contact library administration.`
      );
    }

    // Mark seat as RESERVED immediately in DB
    await this.prisma.seat.update({
      where: { id: reservedSeat.id },
      data: { status: 'RESERVED' },
    });

    // 3. Generate Application ID (e.g. REG-000123)
    const randomNum = Math.floor(100000 + Math.random() * 900000);
    const applicationId = `REG-${randomNum}`;

    const academicInfoObj = {
      batch: dto.batch || '',
      course: dto.course || '',
      institute: dto.institute || '',
      occupation: dto.occupation || '',
    };

    const registration = await this.prisma.memberRegistration.create({
      data: {
        tenantId: branch.tenantId,
        branchId: branch.id,
        applicationId,
        name: dto.name.trim(),
        phone,
        email: dto.email?.trim() || null,
        dob: dto.dob ? new Date(dto.dob) : null,
        gender: dto.gender || null,
        address: dto.address?.trim() || null,
        aadhaarNumber: dto.aadhaarNumber?.replace(/\s/g, '') || null,
        emergencyContact: dto.emergencyContact || null,
        academicInfo: JSON.stringify(academicInfoObj),
        planId: plan.id,
        photoUrl: dto.photoUrl || null,
        aadhaarFrontUrl: dto.aadhaarFrontUrl || null,
        aadhaarBackUrl: dto.aadhaarBackUrl || null,
        otherDocUrls: dto.otherDocUrls || null,
        status: 'PENDING',
        reservedSeatId: reservedSeat?.id || null,
      },
    });

    // Auto-create Member record with selfie and subscription so member immediately appears in Directory
    const tenantCode = branch.tenant?.code || 'CML';
    const memberCode = `${tenantCode}-${Math.floor(1000 + Math.random() * 9000)}`;
    const fullAcademicData = {
      ...academicInfoObj,
      gender: dto.gender || '',
      aadhaar: dto.aadhaarNumber || '',
      emergencyContact: dto.emergencyContact || '',
      photoUrl: dto.photoUrl || '',
    };

    let createdMember: any = null;
    try {
      createdMember = await this.prisma.member.create({
        data: {
          tenantId: branch.tenantId,
          branchId: branch.id,
          memberCode,
          name: dto.name.trim(),
          phone,
          email: dto.email?.trim() || null,
          dob: dto.dob ? new Date(dto.dob) : null,
          address: dto.address?.trim() || null,
          academicInfo: JSON.stringify(fullAcademicData),
          isActive: true,
          registrationId: registration.id,
          portalAccess: true,
        },
      });

      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + (plan.durationDays || 30));

      await this.prisma.subscription.create({
        data: {
          tenantId: branch.tenantId,
          memberId: createdMember.id,
          planId: plan.id,
          startDate,
          endDate,
          status: 'ACTIVE',
          assignedSeatId: reservedSeat?.id || null,
        },
      });

      if (reservedSeat) {
        await this.prisma.seat.update({
          where: { id: reservedSeat.id },
          data: { status: 'OCCUPIED' },
        });
      }

      await this.prisma.memberRegistration.update({
        where: { id: registration.id },
        data: { status: 'APPROVED' },
      });
    } catch (e) {
      console.error('Member auto-creation during registration:', e);
    }

    // Create Admin Notification
    try {
      await this.prisma.notification.create({
        data: {
          tenantId: branch.tenantId,
          type: 'NEW_REGISTRATION',
          title: `New Registration: ${dto.name}`,
          body: `${dto.name} registered for ${plan.name}. Application ID: ${applicationId}${
            reservedSeat ? ` (Seat ${reservedSeat.seatNumber} allocated)` : ''
          }`,
        },
      });
    } catch (_) {}

    return {
      success: true,
      applicationId,
      status: 'APPROVED',
      memberCode: createdMember?.memberCode || memberCode,
      planName: plan.name,
      planPrice: plan.price,
      reservedSeat: reservedSeat ? { id: reservedSeat.id, seatNumber: reservedSeat.seatNumber } : null,
      message: 'Registration submitted successfully. Member created and active in directory.',
    };
  }

  async getRegistrationStatus(applicationId: string) {
    const reg = await this.prisma.memberRegistration.findUnique({
      where: { applicationId },
      include: {
        plan: true,
        reservedSeat: true,
        branch: { select: { name: true, phone: true } },
      },
    });

    if (!reg) {
      throw new NotFoundException('Registration application not found');
    }

    return {
      applicationId: reg.applicationId,
      name: reg.name,
      phone: reg.phone,
      planName: reg.plan?.name || 'Standard Plan',
      planPrice: reg.plan?.price,
      status: reg.status, // PENDING, APPROVED, REJECTED
      seatNumber: reg.reservedSeat?.seatNumber || null,
      submittedAt: reg.submittedAt,
      reviewedAt: reg.reviewedAt,
      rejectionReason: reg.rejectionReason,
      branchName: reg.branch.name,
    };
  }

  // ── PAYMENT SUBMISSION & VERIFICATION ─────────────────────────────────────

  async submitPayment(dto: PortalPaymentDto) {
    const phone = this.cleanPhone(dto.memberPhone);
    let member = dto.memberId
      ? await this.prisma.member.findUnique({ where: { id: dto.memberId }, include: { branch: true } })
      : await this.prisma.member.findFirst({
          where: { phone: { contains: phone.slice(-10) } },
          include: { branch: true },
        });

    let targetBranch: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, dto.branchId || member?.branchId);
    if (branchInfo) {
      targetBranch = await this.prisma.branch.findUnique({ where: { id: branchInfo.id } });
    }

    let branchId = targetBranch?.id || member?.branchId;
    let tenantId = targetBranch?.tenantId || member?.tenantId;

    if (!branchId || !tenantId) {
      const defaultBranch = await this.prisma.branch.findFirst();
      if (!defaultBranch) throw new NotFoundException('Branch not found');
      branchId = defaultBranch.id;
      tenantId = defaultBranch.tenantId;
    }

    // Create member if member doesn't exist yet (guest/applicant payment)
    if (!member) {
      const code = `LIB-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
      member = await this.prisma.member.create({
        data: {
          tenantId,
          branchId,
          memberCode: code,
          name: dto.memberName || 'Portal Applicant',
          phone,
          isActive: false, // inactive until approved
        },
        include: { branch: true },
      });
    }

    // Create Payment record (PENDING)
    const payment = await this.prisma.payment.create({
      data: {
        tenantId,
        memberId: member.id,
        amount: dto.amount,
        method: 'UPI',
        status: 'PENDING',
        paymentType: dto.paymentType,
        txnRef: dto.txnRef || null,
        notes: dto.notes || null,
      },
    });

    // Create PaymentVerification record
    const verification = await this.prisma.paymentVerification.create({
      data: {
        tenantId,
        paymentId: payment.id,
        memberId: member.id,
        amount: dto.amount,
        paymentType: dto.paymentType,
        screenshotUrl: dto.screenshotUrl || null,
        txnRef: dto.txnRef || null,
        upiId: dto.upiId || null,
        status: 'PENDING',
      },
    });

    // Admin Notification
    try {
      await this.prisma.notification.create({
        data: {
          tenantId,
          type: 'PAYMENT_VERIFICATION',
          title: `New Payment Verification: ₹${dto.amount}`,
          body: `${member.name} submitted a ₹${dto.amount} ${dto.paymentType} payment via UPI. Ref: ${dto.txnRef || 'N/A'}`,
        },
      });
    } catch (_) {}

    return {
      success: true,
      paymentId: payment.id,
      verificationId: verification.id,
      status: 'WAITING FOR ADMIN VERIFICATION',
      message: 'Payment details submitted successfully. Verification usually takes a few minutes.',
    };
  }

  // ── COMPLAINT SUBMISSION ──────────────────────────────────────────────────

  async submitComplaint(dto: PortalComplaintDto) {
    const phone = this.cleanPhone(dto.memberPhone);
    const member = dto.memberId
      ? await this.prisma.member.findUnique({ where: { id: dto.memberId } })
      : await this.prisma.member.findFirst({ where: { phone: { contains: phone.slice(-10) } } });

    // Resolve branch properly (handles stable IDs like 'mehdawal'/'khalilabad' AND db UUIDs)
    let branchRecord: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, dto.branchId || member?.branchId);
    if (branchInfo) {
      branchRecord = await this.prisma.branch.findUnique({
        where: { id: branchInfo.id },
        include: { tenant: true },
      });
    }
    if (!branchRecord) {
      branchRecord = await this.prisma.branch.findFirst({ include: { tenant: true } });
    }
    if (!branchRecord) throw new NotFoundException('Branch not found');

    const branchId = branchRecord.id;
    const tenantId = member?.tenantId || branchRecord.tenantId;

    const complaintId = `CMP-${Math.floor(1000 + Math.random() * 9000)}`;

    const complaint = await this.prisma.complaint.create({
      data: {
        tenantId,
        branchId,
        complaintId,
        memberId: member?.id || null,
        memberName: dto.memberName.trim(),
        memberPhone: phone,
        category: dto.category.toUpperCase(),
        description: dto.description.trim(),
        attachmentUrls: dto.attachmentUrls || null,
        status: 'OPEN',
      },
    });

    // Admin Notification
    try {
      await this.prisma.notification.create({
        data: {
          tenantId,
          type: 'NEW_COMPLAINT',
          title: `New Complaint: ${complaintId} (${dto.category})`,
          body: `From ${dto.memberName}: ${dto.description.substring(0, 80)}...`,
        },
      });
    } catch (_) {}

    return {
      success: true,
      complaintId,
      status: 'OPEN',
      message: 'Your complaint has been submitted. Our team will review it shortly.',
    };
  }

  async getComplaintStatus(complaintId: string) {
    const complaint = await this.prisma.complaint.findUnique({
      where: { complaintId },
      include: { branch: { select: { name: true } } },
    });
    if (!complaint) throw new NotFoundException('Complaint not found');

    return {
      complaintId: complaint.complaintId,
      memberName: complaint.memberName,
      category: complaint.category,
      description: complaint.description,
      status: complaint.status,
      resolution: complaint.resolution,
      createdAt: complaint.createdAt,
      resolvedAt: complaint.resolvedAt,
    };
  }

  // ── MEMBER DASHBOARD & HISTORY ────────────────────────────────────────────

  async getMemberDashboard(identifier: string) {
    const raw = identifier ? identifier.trim() : '';
    if (!raw) {
      throw new BadRequestException('Please enter a valid Mobile Number, Member ID, or Name');
    }

    let phone = this.cleanPhone(raw);

    if (raw.includes('-') && raw.length > 20) {
      // It's a portal session token
      const session = await this.prisma.memberPortalSession.findFirst({
        where: { token: raw, verified: true },
      });
      if (session) phone = session.phone;
    }

    const digits = raw.replace(/[^\d]/g, '');

    const orConditions: any[] = [
      { memberCode: { equals: raw, mode: 'insensitive' } },
      { memberCode: { contains: raw, mode: 'insensitive' } },
      { name: { contains: raw, mode: 'insensitive' } },
    ];

    if (digits.length >= 6) {
      orConditions.push({ phone: { contains: digits.length >= 10 ? digits.slice(-10) : digits } });
    }

    const member = await this.prisma.member.findFirst({
      where: {
        OR: orConditions,
      },
      include: {
        subscriptions: {
          orderBy: { endDate: 'desc' },
          include: { plan: true, seat: true, locker: true },
          take: 1,
        },
        payments: {
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
        complaints: {
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
        branch: { select: { name: true, phone: true } },
      },
    });

    if (!member) {
      // Check for pending application
      const regOr: any[] = [
        { applicationId: { equals: raw, mode: 'insensitive' } },
        { name: { contains: raw, mode: 'insensitive' } },
      ];
      if (digits.length >= 6) {
        regOr.push({ phone: { contains: digits.length >= 10 ? digits.slice(-10) : digits } });
      }

      const reg = await this.prisma.memberRegistration.findFirst({
        where: { OR: regOr },
        orderBy: { submittedAt: 'desc' },
        include: { plan: true, reservedSeat: true, branch: true },
      });

      if (reg) {
        return {
          type: 'REGISTRATION_PENDING',
          applicationId: reg.applicationId,
          name: reg.name,
          status: reg.status,
          planName: reg.plan?.name,
          branchName: reg.branch?.name || 'Chintamani Library',
          seatNumber: reg.reservedSeat?.seatNumber,
          submittedAt: reg.submittedAt,
        };
      }

      throw new NotFoundException(`Member profile not found for "${raw}"`);
    }

    const sub = member.subscriptions[0];
    const daysRemaining = sub
      ? Math.max(0, Math.ceil((new Date(sub.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
      : 0;

    // Mask Aadhaar: XXXX-XXXX-1234
    let maskedAadhaar = '';
    try {
      const academicData = member.academicInfo ? JSON.parse(member.academicInfo) : {};
      if (academicData.aadhaar) {
        const a = academicData.aadhaar.toString();
        maskedAadhaar = `XXXX-XXXX-${a.slice(-4)}`;
      }
    } catch (_) {}

    return {
      type: 'MEMBER_PROFILE',
      id: member.id,
      name: member.name,
      memberCode: member.memberCode,
      phone: member.phone,
      email: member.email,
      address: member.address,
      maskedAadhaar,
      isActive: member.isActive,
      branchName: member.branch.name,
      plan: sub?.plan?.name || 'No Active Plan',
      seatNumber: sub?.seat?.seatNumber || 'Not Assigned',
      lockerNumber: sub?.locker?.lockerNumber || null,
      expiryDate: sub?.endDate || null,
      daysRemaining,
      recentPayments: member.payments.map((p) => ({
        id: p.id,
        amount: p.amount,
        status: p.status,
        paymentType: p.paymentType || 'MEMBERSHIP',
        paidAt: p.paidAt || p.createdAt,
      })),
      recentComplaints: member.complaints.map((c) => ({
        complaintId: c.complaintId,
        category: c.category,
        status: c.status,
        createdAt: c.createdAt,
      })),
    };
  }

  async getMemberHistory(identifier: string) {
    let phone = this.cleanPhone(identifier);
    if (identifier.includes('-')) {
      const session = await this.prisma.memberPortalSession.findFirst({
        where: { token: identifier, verified: true },
      });
      if (session) phone = session.phone;
    }

    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const member = await this.prisma.member.findFirst({
      where: { phone: { contains: phone.slice(-10) } },
      include: {
        payments: {
          where: { createdAt: { gte: sixMonthsAgo } },
          include: { verification: true },
          orderBy: { createdAt: 'desc' },
        },
        subscriptions: {
          where: { createdAt: { gte: sixMonthsAgo } },
          include: { plan: true, seat: true, SeatAssignment: { include: { seat: true } } },
          orderBy: { createdAt: 'desc' },
        },
        complaints: {
          where: { createdAt: { gte: sixMonthsAgo } },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    const registrations = await this.prisma.memberRegistration.findMany({
      where: { phone: { contains: phone.slice(-10) } },
      include: { plan: true, reservedSeat: true },
      orderBy: { submittedAt: 'desc' },
    });

    const timeline: any[] = [];

    // 1. Registrations
    registrations.forEach((r) => {
      timeline.push({
        type: 'REGISTRATION',
        title: `Registration ${r.status}`,
        subtitle: `Application ${r.applicationId} for ${r.plan?.name || 'Membership'}`,
        status: r.status,
        date: r.submittedAt,
        details: r.rejectionReason ? `Reason: ${r.rejectionReason}` : undefined,
      });
    });

    // 2. Payments
    if (member?.payments) {
      member.payments.forEach((p) => {
        timeline.push({
          type: 'PAYMENT',
          title: `Payment ${p.status === 'PAID' ? 'Approved' : p.status}`,
          subtitle: `₹${p.amount} • ${p.paymentType || 'Membership Fee'}`,
          amount: p.amount,
          status: p.status,
          txnRef: p.txnRef,
          screenshotUrl: p.verification?.screenshotUrl,
          date: p.paidAt || p.createdAt,
        });
      });
    }

    // 3. Subscriptions & Seats
    if (member?.subscriptions) {
      member.subscriptions.forEach((s) => {
        timeline.push({
          type: 'MEMBERSHIP',
          title: `Plan ${s.status === 'ACTIVE' ? 'Active' : s.status}`,
          subtitle: `${s.plan.name} (${s.seat ? `Seat ${s.seat.seatNumber}` : 'No seat'})`,
          status: s.status,
          date: s.startDate,
        });
      });
    }

    // 4. Complaints
    if (member?.complaints) {
      member.complaints.forEach((c) => {
        timeline.push({
          type: 'COMPLAINT',
          title: `Complaint: ${c.category}`,
          subtitle: `${c.complaintId} • ${c.status}`,
          status: c.status,
          details: c.resolution || c.description,
          date: c.createdAt,
        });
      });
    }

    // Sort timeline descending by date
    timeline.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    return { timeline };
  }

  async submitFeedback(dto: PortalFeedbackDto) {
    let branch: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, dto.branchId);
    if (branchInfo) {
      branch = await this.prisma.branch.findUnique({ where: { id: branchInfo.id } });
    }
    if (!branch) branch = await this.prisma.branch.findFirst();

    if (!branch) {
      throw new NotFoundException('Library branch not found');
    }

    const feedback = await this.prisma.feedback.create({
      data: {
        tenantId: branch.tenantId,
        branchId: branch.id,
        memberId: dto.memberId || null,
        memberName: dto.memberName.trim(),
        memberPhone: dto.memberPhone ? this.cleanPhone(dto.memberPhone) : null,
        rating: Math.max(1, Math.min(5, dto.rating || 5)),
        category: (dto.category || 'OVERALL').toUpperCase(),
        review: dto.review.trim(),
        status: 'NEW',
      },
    });

    return {
      success: true,
      message: 'Thank you for your valuable feedback!',
      feedbackId: feedback.id,
    };
  }

  async getFeedback(branchId?: string) {
    const where: any = {};
    if (branchId) where.branchId = branchId;

    const [feedbacks, total, avgAgg] = await Promise.all([
      this.prisma.feedback.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: 20,
        select: {
          id: true,
          memberName: true,
          rating: true,
          category: true,
          review: true,
          response: true,
          createdAt: true,
        },
      }),
      this.prisma.feedback.count({ where }),
      this.prisma.feedback.aggregate({
        where,
        _avg: { rating: true },
      }),
    ]);

    return {
      total,
      averageRating: avgAgg._avg.rating ? Number(avgAgg._avg.rating.toFixed(1)) : 5.0,
      feedbacks,
    };
  }

  async getSeatsByBatch(batch?: string, timing?: string, branchId?: string) {
    let branch: any = null;
    const branchInfo = await resolveBranchInfo(this.prisma, branchId);
    if (branchInfo) {
      branch = await this.prisma.branch.findUnique({
        where: { id: branchInfo.id },
        include: { tenant: true },
      });
    }

    if (!branch) {
      branch = await this.prisma.branch.findFirst({
        where: { name: { contains: 'Mehdawal', mode: 'insensitive' } },
        include: { tenant: true },
      }) || await this.prisma.branch.findFirst({ include: { tenant: true } });
    }

    if (branch) {
      await this.ensureRealBranchSeats(branch);
    }

    const isMehdawal = branch?.name?.toLowerCase().includes('mehda') ?? true;
    const prefix = isMehdawal ? 'M' : 'K';

    const seats = await this.prisma.seat.findMany({
      where: {
        branchId: branch?.id,
        seatNumber: { startsWith: prefix },
      },
      orderBy: { seatNumber: 'asc' },
      select: {
        id: true,
        seatNumber: true,
        floor: true,
        status: true,
        branchId: true,
      },
    });

    return seats.map((s) => ({
      id: s.id,
      seatNumber: s.seatNumber,
      floor: 'Single Hall',
      status: s.status,
      isAvailable: s.status === 'AVAILABLE',
      branchId: s.branchId,
      branchName: branch?.name || (isMehdawal ? 'Chintamani Library – Mehdawal' : 'Chintamani Library – Khalilabad'),
    }));
  }

  // ── SELF ATTENDANCE (PORTAL / QR PASS) ───────────────────────────────────────

  async submitAttendance(dto: PortalAttendanceDto) {
    const raw = dto.identifier ? dto.identifier.trim() : '';
    if (!raw) {
      throw new BadRequestException('Please enter your Mobile Number, Name, or Member ID');
    }

    // Resolve branch context strictly
    let targetBranch: any = null;
    if (dto.branchId) {
      const branchInfo = await resolveBranchInfo(this.prisma, dto.branchId);
      if (branchInfo) {
        targetBranch = await this.prisma.branch.findUnique({
          where: { id: branchInfo.id },
        });
      }
    }

    const digits = raw.replace(/[^\d]/g, '');

    // Search conditions: Member Code, Name, or Phone
    const orConditions: any[] = [
      { memberCode: { equals: raw, mode: 'insensitive' } },
      { memberCode: { contains: raw, mode: 'insensitive' } },
      { name: { contains: raw, mode: 'insensitive' } },
    ];

    if (digits.length >= 6) {
      const searchPhone = digits.length >= 10 ? digits.slice(-10) : digits;
      orConditions.push({ phone: { contains: searchPhone } });
    }

    // First search for an active member strictly within target branch
    let member = await this.prisma.member.findFirst({
      where: {
        OR: orConditions,
        isActive: true,
        ...(targetBranch ? { branchId: targetBranch.id } : {}),
      },
      include: {
        branch: true,
        subscriptions: {
          where: { status: 'ACTIVE' },
          include: { seat: true, plan: true },
          orderBy: { endDate: 'desc' },
          take: 1,
        },
      },
    });

    // If not found in targetBranch, check if member exists in the other branch
    if (!member && targetBranch) {
      const foreignMember = await this.prisma.member.findFirst({
        where: {
          OR: orConditions,
          isActive: true,
        },
        include: { branch: true },
      });

      if (foreignMember && foreignMember.branchId !== targetBranch.id) {
        throw new BadRequestException(
          `Branch Mismatch: "${foreignMember.name}" is registered at ${foreignMember.branch.name}. You cannot record attendance at ${targetBranch.name}. Please switch the branch at the top to ${foreignMember.branch.name}.`
        );
      }
    }

    if (!member) {
      member = await this.prisma.member.findFirst({
        where: {
          OR: orConditions,
          ...(targetBranch ? { branchId: targetBranch.id } : {}),
        },
        include: {
          branch: true,
          subscriptions: {
            include: { seat: true, plan: true },
            orderBy: { endDate: 'desc' },
            take: 1,
          },
        },
      });
    }

    if (!member) {
      const branchNotice = targetBranch ? ` in ${targetBranch.name}` : '';
      throw new NotFoundException(
        `Member not found${branchNotice} with "${raw}". Please enter your registered 10-digit mobile number, full name, or Member ID (e.g. CML-942810).`,
      );
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const openRecord = await this.prisma.attendance.findFirst({
      where: {
        memberId: member.id,
        checkIn: { gte: today },
        checkOut: null,
      },
      orderBy: { checkIn: 'desc' },
    });

    if (openRecord) {
      // Toggle to Check-Out
      const updated = await this.prisma.attendance.update({
        where: { id: openRecord.id },
        data: { checkOut: new Date() },
      });

      return {
        success: true,
        action: 'CHECK_OUT',
        message: `Checked out successfully! Have a great day, ${member.name}.`,
        member: {
          id: member.id,
          name: member.name,
          memberCode: member.memberCode,
          branchName: member.branch.name,
          seatNumber: member.subscriptions[0]?.seat?.seatNumber ?? 'Unassigned',
        },
        checkIn: openRecord.checkIn,
        checkOut: updated.checkOut,
      };
    }

    // Create Check-In
    const newRecord = await this.prisma.attendance.create({
      data: {
        tenantId: member.tenantId,
        memberId: member.id,
        branchId: member.branchId,
        method: 'QR',
      },
    });

    return {
      success: true,
      action: 'CHECK_IN',
      message: `Checked in successfully! Welcome to Chintamani Library, ${member.name}.`,
      member: {
        id: member.id,
        name: member.name,
        memberCode: member.memberCode,
        branchName: member.branch.name,
        seatNumber: member.subscriptions[0]?.seat?.seatNumber ?? 'Unassigned',
        planName: member.subscriptions[0]?.plan?.name ?? 'Standard Plan',
      },
      checkIn: newRecord.checkIn,
    };
  }
}

