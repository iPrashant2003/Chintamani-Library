import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { QueryMembersDto } from './dto/query-members.dto';

@Injectable()
export class MembersService {
  constructor(private readonly prisma: PrismaService) {}

  private generateMemberCode(prefix = 'LIB'): string {
    return `${prefix}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
  }

  async create(user: any, createMemberDto: CreateMemberDto) {
    let tenantId = user?.tenantId;
    let tenantCode = 'LIB';

    if (createMemberDto.branchId) {
      const branch = await this.prisma.branch.findUnique({
        where: { id: createMemberDto.branchId },
        include: { tenant: true },
      });
      if (branch) {
        tenantId = branch.tenantId;
        tenantCode = branch.tenant?.code || 'LIB';
      }
    }

    if (!tenantId) {
      throw new NotFoundException('Branch or tenant not found');
    }

    const memberCode = this.generateMemberCode(tenantCode);
    const academicData = {
      fatherName: createMemberDto.fatherName,
      gender: createMemberDto.gender,
      emergencyContact: createMemberDto.emergencyContact,
      aadhaar: createMemberDto.aadhaar,
      institute: createMemberDto.institute,
      course: createMemberDto.course,
      batch: createMemberDto.batch,
      photoUrl: createMemberDto.photoUrl,
      notes: createMemberDto.notes,
    };

    return this.prisma.member.create({
      data: {
        tenantId,
        memberCode,
        name: createMemberDto.name,
        phone: createMemberDto.phone,
        email: createMemberDto.email,
        dob: createMemberDto.dob ? new Date(createMemberDto.dob) : null,
        address: createMemberDto.address,
        academicInfo: JSON.stringify(academicData),
        branchId: createMemberDto.branchId,
        isActive: true,
      },
    });
  }

  async findAll(user: any, query: QueryMembersDto) {
    const { branchId, status, search, page = 1, limit = 10 } = query;
    const pageNum = Number(page) || 1;
    const limitNum = Number(limit) || 10;
    const skip = (pageNum - 1) * limitNum;

    const where: any = {};
    if (user?.tenantId) where.tenantId = user.tenantId;
    if (branchId) where.branchId = branchId;
    if (status === 'active') where.isActive = true;
    if (status === 'inactive') where.isActive = false;
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { memberCode: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [members, total] = await Promise.all([
      this.prisma.member.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          subscriptions: {
            where: { status: 'ACTIVE' },
            include: { plan: true, seat: true, locker: true },
            take: 1,
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.member.count({ where }),
    ]);

    return { data: members, total, page: pageNum, limit: limitNum };
  }

  async getMemberProfile(user: any, id: string) {
    const where: any = { id };
    if (user?.tenantId) where.tenantId = user.tenantId;

    const member = await this.prisma.member.findFirst({
      where,
      include: {
        subscriptions: {
          include: { plan: true, seat: true, locker: true },
          orderBy: { createdAt: 'desc' },
        },
        attendances: {
          orderBy: { checkIn: 'desc' },
          take: 30,
        },
        payments: {
          orderBy: { createdAt: 'desc' },
        },
      },
    });
    if (!member) throw new NotFoundException('Member not found');
    return member;
  }

  async update(id: string, updateMemberDto: UpdateMemberDto) {
    const dataToUpdate: any = {};
    if (updateMemberDto.name) dataToUpdate.name = updateMemberDto.name;
    if (updateMemberDto.phone) dataToUpdate.phone = updateMemberDto.phone;
    if (updateMemberDto.email) dataToUpdate.email = updateMemberDto.email;
    if (updateMemberDto.dob) dataToUpdate.dob = new Date(updateMemberDto.dob);
    if (updateMemberDto.address) dataToUpdate.address = updateMemberDto.address;

    return this.prisma.member.update({
      where: { id },
      data: dataToUpdate,
    });
  }

  async remove(id: string) {
    return this.prisma.member.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async getPayments(id: string) {
    return this.prisma.payment.findMany({ where: { memberId: id }, orderBy: { createdAt: 'desc' } });
  }

  async getAttendance(id: string) {
    return this.prisma.attendance.findMany({ where: { memberId: id }, orderBy: { checkIn: 'desc' } });
  }

  async getSubscriptions(id: string) {
    return this.prisma.subscription.findMany({
      where: { memberId: id },
      include: { plan: true, seat: true, locker: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
