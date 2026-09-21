import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';

@Injectable()
export class PlansService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, isActive?: boolean) {
    return this.prisma.membershipPlan.findMany({
      where: {
        ...(branchId && { branchId }),
        ...(isActive !== undefined && { isActive }),
      },
      orderBy: { durationDays: 'asc' },
    });
  }

  async create(dto: CreatePlanDto) {
    const branch = await this.prisma.branch.findUniqueOrThrow({ where: { id: dto.branchId } });
    return this.prisma.membershipPlan.create({
      data: {
        ...dto,
        tenantId: branch.tenantId,
      },
    });
  }

  async findOne(id: string) {
    const plan = await this.prisma.membershipPlan.findUnique({ where: { id } });
    if (!plan) throw new NotFoundException('Plan not found');
    return plan;
  }

  async update(id: string, dto: UpdatePlanDto) {
    return this.prisma.membershipPlan.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    return this.prisma.membershipPlan.update({ where: { id }, data: { isActive: false } });
  }
}
