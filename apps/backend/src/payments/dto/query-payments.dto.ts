import { IsString, IsOptional, IsNumberString, IsDateString } from 'class-validator';

export class QueryPaymentsDto {
  @IsOptional()
  @IsString()
  branchId?: string;

  @IsOptional()
  @IsString()
  memberId?: string;

  @IsOptional()
  @IsString()
  method?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @IsOptional()
  @IsNumberString()
  page?: string;

  @IsOptional()
  @IsNumberString()
  limit?: string;
}
