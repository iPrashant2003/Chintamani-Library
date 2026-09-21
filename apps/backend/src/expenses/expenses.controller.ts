import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('expenses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('expenses')
export class ExpensesController {
  constructor(private readonly expensesService: ExpensesService) {}

  @Post()
  create(@Body() createExpenseDto: CreateExpenseDto) {
    return this.expensesService.create(createExpenseDto);
  }

  @Get()
  findAll(
    @Query('branchId') branchId?: string,
    @Query('category') category?: string,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.expensesService.findAll(branchId, category, dateFrom, dateTo, Number(page || 1), Number(limit || 20));
  }

  @Get('summary')
  getSummary(
    @Query('branchId') branchId: string,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ) {
    return this.expensesService.getSummary(branchId, month ? Number(month) : undefined, year ? Number(year) : undefined);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.expensesService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateExpenseDto: Partial<CreateExpenseDto>) {
    return this.expensesService.update(id, updateExpenseDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.expensesService.remove(id);
  }
}
