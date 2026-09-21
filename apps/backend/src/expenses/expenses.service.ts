import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateExpenseDto } from './dto/create-expense.dto';

@Injectable()
export class ExpensesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(branchId?: string, category?: string, dateFrom?: string, dateTo?: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const where: any = {};
    if (branchId) where.branchId = branchId;
    if (category) where.category = category;
    if (dateFrom || dateTo) {
      where.date = {
        ...(dateFrom && { gte: new Date(dateFrom) }),
        ...(dateTo && { lte: new Date(dateTo) })
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.expense.findMany({ where, skip, take: limit, orderBy: { date: 'desc' } }),
      this.prisma.expense.count({ where })
    ]);
    return { data, total, page, limit };
  }

  async getSummary(branchId: string, month?: number, year?: number) {
    const now = new Date();
    const m = month || now.getMonth() + 1;
    const y = year || now.getFullYear();
    const start = new Date(y, m - 1, 1);
    const end = new Date(y, m, 0, 23, 59, 59);
    
    const expenses = await this.prisma.expense.findMany({
      where: { branchId, date: { gte: start, lte: end } }
    });
    
    const byCategory = expenses.reduce((acc, e) => {
      acc[e.category] = (acc[e.category] || 0) + e.amount;
      return acc;
    }, {} as Record<string, number>);
    
    const total = expenses.reduce((sum, e) => sum + e.amount, 0);
    return { byCategory, total, month: m, year: y };
  }

  async create(dto: CreateExpenseDto) {
    const branch = await this.prisma.branch.findUniqueOrThrow({ where: { id: dto.branchId } });
    return this.prisma.expense.create({ 
      data: {
        tenantId: branch.tenantId,
        branchId: dto.branchId,
        category: dto.category as any,
        amount: dto.amount,
        description: dto.description || null,
        date: dto.date ? new Date(dto.date) : new Date(),
      } 
    });
  }

  async findOne(id: string) {
    const expense = await this.prisma.expense.findUnique({ where: { id } });
    if (!expense) throw new NotFoundException('Expense not found');
    return expense;
  }

  async update(id: string, data: Partial<CreateExpenseDto>) {
    const updateData: any = {};
    if (data.category) updateData.category = data.category as any;
    if (data.amount !== undefined) updateData.amount = data.amount;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.date) updateData.date = new Date(data.date);
    return this.prisma.expense.update({ where: { id }, data: updateData });
  }

  async remove(id: string) {
    return this.prisma.expense.delete({ where: { id } });
  }
}
