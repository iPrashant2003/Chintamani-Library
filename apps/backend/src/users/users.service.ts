import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    const { password, branchIds, ...userData } = createUserDto;
    const existing = await this.prisma.user.findUnique({ where: { email: userData.email } });
    if (existing) throw new BadRequestException('Email already in use');

    const hashedPassword = await bcrypt.hash(password, 10);
    
    return this.prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
        branches: branchIds ? {
          create: branchIds.map(branchId => ({ branchId }))
        } : undefined
      },
    });
  }

  async findAll(branchId?: string) {
    const where = branchId ? { branches: { some: { branchId } } } : {};
    const users = await this.prisma.user.findMany({
      where,
      select: { id: true, name: true, email: true, role: true, phone: true, isActive: true },
    });
    return { data: users, total: users.length, page: 1, limit: users.length };
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { branches: { include: { branch: true } } },
    });
    if (!user) throw new NotFoundException('User not found');
    const { password, ...safeUser } = user;
    return safeUser;
  }

  async update(id: string, updateUserDto: UpdateUserDto) {
    const { branchIds, ...updateData } = updateUserDto;
    return this.prisma.user.update({
      where: { id },
      data: updateData, // Simplified for brevity
    });
  }

  async remove(id: string) {
    return this.prisma.user.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async assignBranch(userId: string, branchId: string) {
    return this.prisma.userBranchAccess.create({
      data: { userId, branchId },
    });
  }
}
