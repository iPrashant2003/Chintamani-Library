import { IsString, IsInt, Min, IsNumber, IsOptional, IsBoolean } from 'class-validator';

export class CreatePlanDto {
  @IsString()
  name: string;

  @IsInt()
  @Min(1)
  durationDays: number;

  @IsNumber()
  @Min(0)
  price: number;

  @IsOptional()
  @IsNumber()
  discount?: number;

  @IsOptional()
  @IsBoolean()
  includesSeat?: boolean;

  @IsOptional()
  @IsBoolean()
  includesLocker?: boolean;

  @IsOptional()
  @IsString()
  description?: string;

  @IsString()
  branchId: string;
}
