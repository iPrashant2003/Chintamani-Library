import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QueryComplaintsDto, UpdateComplaintStatusDto } from './dto/complaints.dto';

@Injectable()
export class ComplaintsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: QueryComplaintsDto) {
    const { status = 'OPEN', category, branchId, search, page = '1', limit = '20' } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (status && status !== 'ALL') {
      where.status = status;
    }
    if (category) {
      where.category = category.toUpperCase();
    }
    if (branchId) {
      where.branchId = branchId;
    }
    if (search) {
      where.OR = [
        { memberName: { contains: search, mode: 'insensitive' } },
        { memberPhone: { contains: search } },
        { complaintId: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.complaint.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          member: { select: { id: true, name: true, memberCode: true } },
          branch: { select: { id: true, name: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.complaint.count({ where }),
    ]);

    return { data, total, page: pageNum, limit: limitNum };
  }

  async findOne(id: string) {
    const complaint = await this.prisma.complaint.findUnique({
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
              include: { seat: true, plan: true },
              take: 1,
            },
          },
        },
        branch: { select: { id: true, name: true } },
      },
    });

    if (!complaint) throw new NotFoundException('Complaint not found');
    return complaint;
  }

  async updateStatus(id: string, dto: UpdateComplaintStatusDto, adminUser?: any) {
    const complaint = await this.prisma.complaint.findUnique({ where: { id } });
    if (!complaint) throw new NotFoundException('Complaint not found');

    const isResolving = dto.status === 'RESOLVED' || dto.status === 'CLOSED';

    const updated = await this.prisma.complaint.update({
      where: { id },
      data: {
        status: dto.status as any,
        resolution: dto.resolution || complaint.resolution,
        assignedTo: dto.assignedTo || complaint.assignedTo,
        resolvedAt: isResolving ? new Date() : complaint.resolvedAt,
      },
    });

    // Audit Log
    try {
      await this.prisma.auditLog.create({
        data: {
          tenantId: complaint.tenantId,
          userId: adminUser?.id || null,
          branchId: complaint.branchId,
          action: 'UPDATE_COMPLAINT_STATUS',
          entity: 'Complaint',
          entityId: complaint.id,
          metadata: JSON.stringify({
            complaintId: complaint.complaintId,
            oldStatus: complaint.status,
            newStatus: dto.status,
            resolution: dto.resolution,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Complaint ${complaint.complaintId} marked as ${dto.status}`,
      complaint: updated,
    };
  }

  async getOpenCount(branchId?: string) {
    const where: any = { status: { in: ['OPEN', 'IN_PROGRESS'] } };
    if (branchId) where.branchId = branchId;
    return this.prisma.complaint.count({ where });
  }
}
