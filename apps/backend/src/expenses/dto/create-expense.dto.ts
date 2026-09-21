import { IsString, IsNumber, Min, IsEnum, IsOptional, IsDateString } from 'class-validator';

enum ExpenseCategory {
  RENT = 'RENT',
  ELECTRICITY = 'ELECTRICITY',
  MAINTENANCE = 'MAINTENANCE',
  SALARY = 'SALARY',
  OTHER = 'OTHER'
}

export class CreateExpenseDto {
  @IsString()
  branchId: string;

  @IsEnum(ExpenseCategory)
  category: ExpenseCategory;

  @IsNumber()
  @Min(0)
  amount: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsDateString()
  date?: string;
}
