import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';

@Injectable()
export class BranchesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(user: any, createBranchDto: CreateBranchDto) {
    if (!user?.tenantId) {
      throw new NotFoundException('Tenant not found');
    }
    return this.prisma.branch.create({
      data: {
        ...createBranchDto,
        tenantId: user.tenantId,
      },
    });
  }

  async findAll(user?: any) {
    const where = user?.tenantId ? { tenantId: user.tenantId } : {};
    const branches = await this.prisma.branch.findMany({ where });
    return { data: branches, total: branches.length, page: 1, limit: branches.length };
  }

  async findOne(user: any, id: string) {
    const where: any = { id };
    if (user?.tenantId) where.tenantId = user.tenantId;

    const branch = await this.prisma.branch.findFirst({ where });
    if (!branch) throw new NotFoundException('Branch not found');
    return branch;
  }

  async update(id: string, updateBranchDto: UpdateBranchDto) {
    return this.prisma.branch.update({
      where: { id },
      data: updateBranchDto,
    });
  }

  async getStats(id: string) {
    const membersCount = await this.prisma.member.count({ where: { branchId: id } });
    const seatsCount = await this.prisma.seat.count({ where: { branchId: id } });
    const lockersCount = await this.prisma.locker.count({ where: { branchId: id } });
    return { membersCount, seatsCount, lockersCount };
  }
}
