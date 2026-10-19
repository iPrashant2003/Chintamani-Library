import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { QueryPaymentsDto } from './dto/query-payments.dto';

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: QueryPaymentsDto) {
    const { branchId, memberId, method, status, dateFrom, dateTo, page = '1', limit = '20' } = query;
    const skip = (Number(page) - 1) * Number(limit);
    const where: any = {};
    if (memberId) where.memberId = memberId;
    if (method) where.method = method;
    if (status) where.status = status;
    if (dateFrom || dateTo) {
      where.paidAt = {
        ...(dateFrom && { gte: new Date(dateFrom) }),
        ...(dateTo && { lte: new Date(dateTo) })
      };
    }
    if (branchId) where.member = { branchId };

    const [data, total] = await Promise.all([
      this.prisma.payment.findMany({ 
        where, skip, take: Number(limit), 
        include: { member: { select: { name: true, memberCode: true, branchId: true } } }, 
        orderBy: { createdAt: 'desc' } 
      }),
      this.prisma.payment.count({ where })
    ]);
    return { data, total, page: Number(page), limit: Number(limit) };
  }

  async create(dto: CreatePaymentDto) { 
    const member = await this.prisma.member.findUniqueOrThrow({ where: { id: dto.memberId } });
    const finalAmount = dto.discount ? dto.amount - dto.discount : dto.amount;
    return this.prisma.payment.create({ 
      data: { 
        tenantId: member.tenantId,
        memberId: dto.memberId,
        amount: finalAmount,
        method: (dto.method === 'BANK_TRANSFER' ? 'BANK' : dto.method) as any,
        status: 'PAID', 
        txnRef: dto.txnRef || null,
        paidAt: dto.paidAt ? new Date(dto.paidAt) : new Date(),
      } 
    }); 
  }

  async getDues(branchId: string) {
    return this.prisma.payment.findMany({
      where: { status: 'PENDING', member: { branchId } },
      include: { member: { select: { name: true, memberCode: true, phone: true } } },
      orderBy: { createdAt: 'asc' }
    });
  }

  async getSummary(branchId: string, dateFrom?: string, dateTo?: string) {
    const where: any = { status: 'PAID', member: { branchId } };
    if (dateFrom || dateTo) {
      where.paidAt = {
        ...(dateFrom && { gte: new Date(dateFrom) }),
        ...(dateTo && { lte: new Date(dateTo) })
      };
    }
    const result = await this.prisma.payment.aggregate({ where, _sum: { amount: true }, _count: true });
    return { total: result._sum.amount || 0, count: result._count };
  }

  async findOne(id: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id }, include: { member: true } });
    if (!payment) throw new NotFoundException('Payment not found');
    return payment;
  }

  async updateStatus(id: string, status: string) {
    return this.prisma.payment.update({ where: { id }, data: { status: status as any } });
  }

  async findByMember(memberId: string) {
    return this.prisma.payment.findMany({ where: { memberId }, orderBy: { createdAt: 'desc' } });
  }

  // ── PAYMENT VERIFICATION (ADMIN) ──────────────────────────────────────────

  async getVerifications(query: { status?: string; search?: string; page?: string; limit?: string }) {
    const { status = 'PENDING', search, page = '1', limit = '20' } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (status && status !== 'ALL') {
      where.status = status;
    }
    if (search) {
      where.OR = [
        { member: { name: { contains: search, mode: 'insensitive' } } },
        { member: { phone: { contains: search } } },
        { txnRef: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.paymentVerification.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          member: {
            select: {
              id: true,
              name: true,
              memberCode: true,
              phone: true,
              subscriptions: {
                where: { status: 'ACTIVE' },
                include: { plan: true, seat: true },
                take: 1,
              },
            },
          },
          payment: true,
        },
        orderBy: { submittedAt: 'desc' },
      }),
      this.prisma.paymentVerification.count({ where }),
    ]);

    return { data, total, page: pageNum, limit: limitNum };
  }

  async getPendingVerificationCount() {
    return this.prisma.paymentVerification.count({ where: { status: 'PENDING' } });
  }

  async getVerification(id: string) {
    const verification = await this.prisma.paymentVerification.findUnique({
      where: { id },
      include: {
        member: {
          select: {
            id: true,
            name: true,
            memberCode: true,
            phone: true,
            subscriptions: {
              where: { status: 'ACTIVE' },
              include: { plan: true, seat: true },
              take: 1,
            },
          },
        },
        payment: true,
      },
    });
    if (!verification) throw new NotFoundException('Payment verification request not found');
    return verification;
  }

  async approveVerification(id: string, adminUser?: any) {
    const verification = await this.prisma.paymentVerification.findUnique({
      where: { id },
      include: { payment: true, member: true },
    });
    if (!verification) throw new NotFoundException('Payment verification request not found');

    if (verification.status !== 'PENDING') {
      throw new BadRequestException(
        `This payment verification has already been ${verification.status.toLowerCase()}. Duplicate actions are prevented.`
      );
    }

    await this.prisma.$transaction(async (tx) => {
      // 1. Update verification status
      await tx.paymentVerification.update({
        where: { id },
        data: {
          status: 'APPROVED',
          verifiedBy: adminUser?.name || 'Admin',
          verifiedAt: new Date(),
        },
      });

      // 2. Update payment status to PAID
      await tx.payment.update({
        where: { id: verification.paymentId },
        data: {
          status: 'PAID',
          paidAt: new Date(),
        },
      });

      // 3. Activate member & activate subscription / seat
      await tx.member.update({
        where: { id: verification.memberId },
        data: { isActive: true },
      });

      const activeSub = await tx.subscription.findFirst({
        where: { memberId: verification.memberId },
        orderBy: { createdAt: 'desc' },
      });
      if (activeSub) {
        await tx.subscription.update({
          where: { id: activeSub.id },
          data: { status: 'ACTIVE' },
        });
        if (activeSub.assignedSeatId) {
          await tx.seat.update({
            where: { id: activeSub.assignedSeatId },
            data: { status: 'OCCUPIED' },
          });
        }
      }

      // 4. Audit Log
      await tx.auditLog.create({
        data: {
          tenantId: verification.tenantId,
          userId: adminUser?.id || null,
          action: 'APPROVE_PAYMENT_VERIFICATION',
          entity: 'PaymentVerification',
          entityId: verification.id,
          metadata: JSON.stringify({
            paymentId: verification.paymentId,
            memberId: verification.memberId,
            amount: verification.amount,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    });

    return {
      success: true,
      message: `Payment of ₹${verification.amount} for ${verification.member.name} approved.`,
    };
  }

  async rejectVerification(id: string, reason?: string, adminUser?: any) {
    const verification = await this.prisma.paymentVerification.findUnique({
      where: { id },
      include: { payment: true, member: true },
    });
    if (!verification) throw new NotFoundException('Payment verification request not found');

    if (verification.status !== 'PENDING') {
      throw new BadRequestException(
        `This payment verification has already been ${verification.status.toLowerCase()}. Duplicate actions are prevented.`
      );
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.paymentVerification.update({
        where: { id },
        data: {
          status: 'REJECTED',
          rejectionReason: reason || 'Transaction could not be verified',
          verifiedBy: adminUser?.name || 'Admin',
          verifiedAt: new Date(),
        },
      });

      await tx.payment.update({
        where: { id: verification.paymentId },
        data: {
          status: 'REJECTED',
        },
      });

      // Audit Log
      await tx.auditLog.create({
        data: {
          tenantId: verification.tenantId,
          userId: adminUser?.id || null,
          action: 'REJECT_PAYMENT_VERIFICATION',
          entity: 'PaymentVerification',
          entityId: verification.id,
          metadata: JSON.stringify({
            paymentId: verification.paymentId,
            memberId: verification.memberId,
            amount: verification.amount,
            reason,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    });

    return {
      success: true,
      message: `Payment verification for ${verification.member.name} rejected.`,
    };
  }

  async getMemberPaymentHistory(memberId: string, months = 6) {
    const member = await this.prisma.member.findUnique({
      where: { id: memberId },
      select: { id: true, name: true, memberCode: true, phone: true },
    });
    if (!member) throw new NotFoundException('Member not found');

    const thresholdDate = new Date();
    thresholdDate.setMonth(thresholdDate.getMonth() - months);

    const payments = await this.prisma.payment.findMany({
      where: {
        memberId,
        createdAt: { gte: thresholdDate },
      },
      include: {
        verification: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      member,
      windowMonths: months,
      thresholdDate,
      totalCount: payments.length,
      payments: payments.map((p) => ({
        id: p.id,
        amount: p.amount,
        method: p.method,
        status: p.status,
        paymentType: p.paymentType || 'MEMBERSHIP',
        txnRef: p.txnRef || p.verification?.txnRef || null,
        notes: p.notes,
        paidAt: p.paidAt,
        createdAt: p.createdAt,
        verificationStatus: p.verification?.status || p.status,
        screenshotUrl: p.verification?.screenshotUrl || null,
        upiId: p.verification?.upiId || null,
        rejectionReason: p.verification?.rejectionReason || null,
        verifiedBy: p.verification?.verifiedBy || null,
        verifiedAt: p.verification?.verifiedAt || null,
      })),
    };
  }
}
