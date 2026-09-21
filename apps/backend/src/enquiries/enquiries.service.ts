import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEnquiryDto } from './dto/create-enquiry.dto';
import { UpdateEnquiryDto } from './dto/update-enquiry.dto';

@Injectable()
export class EnquiriesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, status?: string) {
    return this.prisma.enquiry.findMany({
      where: {
        ...(branchId && { branchId }),
        ...(status && { status: status as any }),
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  async getTodayFollowups(branchId: string) {
    const today = new Date();
    const start = new Date(today.setHours(0,0,0,0));
    const end = new Date(today.setHours(23,59,59,999));
    return this.prisma.enquiry.findMany({
      where: { branchId, followUpDate: { gte: start, lte: end }, status: { not: 'CONVERTED' } },
      orderBy: { followUpDate: 'asc' }
    });
  }

  async create(dto: CreateEnquiryDto) {
    const branch = await this.prisma.branch.findUniqueOrThrow({ where: { id: dto.branchId } });
    return this.prisma.enquiry.create({ 
      data: {
        tenantId: branch.tenantId,
        ...dto,
        followUpDate: dto.followUpDate ? new Date(dto.followUpDate) : undefined,
      } 
    });
  }

  async findOne(id: string) {
    const enquiry = await this.prisma.enquiry.findUnique({ where: { id } });
    if (!enquiry) throw new NotFoundException('Enquiry not found');
    return enquiry;
  }

  async update(id: string, dto: UpdateEnquiryDto) {
    const updateData: any = {};
    if (dto.status) updateData.status = dto.status;
    if (dto.notes !== undefined) updateData.notes = dto.notes;
    if (dto.followUpDate) updateData.followUpDate = new Date(dto.followUpDate);
    return this.prisma.enquiry.update({ 
      where: { id }, 
      data: updateData,
    });
  }

  async remove(id: string) {
    return this.prisma.enquiry.delete({ where: { id } });
  }

  async convert(id: string, memberId: string) {
    return this.prisma.enquiry.update({ where: { id }, data: { status: 'CONVERTED' } });
  }
}
