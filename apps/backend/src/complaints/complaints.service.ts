import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QueryComplaintsDto, UpdateComplaintStatusDto } from './dto/complaints.dto';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';
import { CommunicationService } from '../communication/communication.service';

@Injectable()
export class ComplaintsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly communicationService: CommunicationService,
  ) {}

  private normalizeStatus(s: string): string {
    const clean = s.toUpperCase().trim().replace(/[\s-]+/g, '_');
    if (clean === 'SUBMITTED') return 'SUBMITTED';
    if (clean === 'UNDER_REVIEW' || clean === 'REVIEW') return 'UNDER_REVIEW';
    if (clean === 'IN_PROGRESS' || clean === 'PROGRESS') return 'IN_PROGRESS';
    if (clean === 'RESOLVED_PENDING' || clean === 'RESOLVEDPENDING') return 'RESOLVED_PENDING';
    if (clean === 'RESOLVED') return 'RESOLVED';
    if (clean === 'REJECTED') return 'REJECTED';
    if (clean === 'REOPENED') return 'REOPENED';
    if (clean === 'CLOSED') return 'CLOSED';
    return 'OPEN';
  }

  async findAll(query: QueryComplaintsDto) {
    const { status, category, branchId, search, page = '1', limit = '20' } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 20;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (status && status !== 'ALL' && status !== 'all') {
      const norm = this.normalizeStatus(status);
      if (norm === 'OPEN') {
        where.status = { in: ['OPEN', 'SUBMITTED'] };
      } else {
        where.status = norm;
      }
    }
    if (category) {
      where.category = category.toUpperCase();
    }
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
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
          member: { select: { id: true, name: true, memberCode: true, phone: true } },
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

    const newStatus = this.normalizeStatus(dto.status);
    const isResolving = newStatus === 'RESOLVED' || newStatus === 'CLOSED';

    // Parse and append status history
    let history: any[] = [];
    try {
      if (complaint.statusHistory) {
        history = JSON.parse(complaint.statusHistory);
      }
    } catch (_) {
      history = [];
    }

    const historyEntry = {
      fromStatus: complaint.status,
      toStatus: newStatus,
      adminName: adminUser?.name || 'Admin',
      adminId: adminUser?.id || null,
      timestamp: new Date().toISOString(),
      resolution: dto.resolution?.trim() || null,
      internalNotes: dto.internalNotes?.trim() || null,
    };
    history.push(historyEntry);

    const updated = await this.prisma.complaint.update({
      where: { id },
      data: {
        status: newStatus as any,
        resolution: dto.resolution?.trim() || complaint.resolution,
        internalNotes: dto.internalNotes?.trim() || complaint.internalNotes,
        statusHistory: JSON.stringify(history),
        assignedTo: dto.assignedTo || complaint.assignedTo,
        resolvedAt: isResolving ? (complaint.resolvedAt || new Date()) : (newStatus === 'REOPENED' ? null : complaint.resolvedAt),
      },
      include: {
        member: { select: { id: true, name: true, memberCode: true, phone: true } },
        branch: { select: { id: true, name: true } },
      },
    });

    // Send WhatsApp notification when Resolved (with duplicate prevention)
    let whatsappSent = false;
    if (newStatus === 'RESOLVED' && !complaint.whatsappSentAt) {
      try {
        const rawPhone = (complaint.memberPhone || updated.member?.phone || '').replace(/\D/g, '');
        const cleanPhone = rawPhone.slice(-10);

        if (cleanPhone.length === 10) {
          const recipientPhone = `+91${cleanPhone}`;
          const memberName = complaint.memberName || updated.member?.name || 'Member';
          const resolutionMsg = dto.resolution?.trim()
            ? `\n\nResolution Details: ${dto.resolution.trim()}`
            : '';

          const waText = `Dear ${memberName},\n\nYour complaint #${complaint.complaintId} regarding ${complaint.category} has been marked as RESOLVED by the library administration.${resolutionMsg}\n\nThank you for your patience and for helping us maintain Chintamani Library.\n\nWarm regards,\nChintamani Library Administration`;

          const sendResult = await this.communicationService.send({
            channel: 'WHATSAPP',
            recipientPhone,
            templateName: waText,
          });

          if (sendResult.success) {
            whatsappSent = true;
            await this.prisma.complaint.update({
              where: { id },
              data: {
                whatsappSentAt: new Date(),
                whatsappMessageId: sendResult.ref || `wa-${Date.now()}`,
              },
            });
          }
        }
      } catch (waErr) {
        console.error(`[WhatsApp Notification Error] Failed to send resolution message for complaint #${complaint.complaintId}:`, waErr);
      }
    }

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
            newStatus,
            resolution: dto.resolution,
            internalNotes: dto.internalNotes,
            whatsappSent,
            admin: adminUser?.name || 'Admin',
          }),
        },
      });
    } catch (_) {}

    return {
      success: true,
      message: `Complaint ${complaint.complaintId} updated to ${newStatus}${whatsappSent ? ' • WhatsApp alert sent' : ''}`,
      complaint: updated,
    };
  }

  async getOpenCount(branchId?: string) {
    const where: any = { status: { in: ['OPEN', 'IN_PROGRESS'] } };
    if (branchId && branchId !== 'ALL' && branchId !== 'all') {
      const branchInfo = await resolveBranchInfo(this.prisma, branchId);
      if (branchInfo) {
        where.branchId = { in: branchInfo.allIds };
      } else {
        where.branchId = branchId;
      }
    }
    return this.prisma.complaint.count({ where });
  }
}
