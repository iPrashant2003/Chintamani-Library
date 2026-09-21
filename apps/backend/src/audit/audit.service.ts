import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async createLog(userId: string, branchId: string, action: string, entity: string, entityId: string, metadata?: any) {
    return this.prisma.auditLog.create({
      data: {
        userId,
        branchId,
        action,
        entity,
        entityId,
        metadata: metadata ? JSON.parse(JSON.stringify(metadata)) : undefined,
      }
    });
  }

  async findAll(branchId?: string, entity?: string, action?: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const where: any = {};
    if (branchId) where.branchId = branchId;
    if (entity) where.entity = entity;
    if (action) where.action = action;

    const [data, total] = await Promise.all([
      this.prisma.auditLog.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.auditLog.count({ where })
    ]);
    return { data, total, page, limit };
  }
}
