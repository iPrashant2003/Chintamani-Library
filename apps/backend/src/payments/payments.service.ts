import { Injectable, NotFoundException } from '@nestjs/common';
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
}
