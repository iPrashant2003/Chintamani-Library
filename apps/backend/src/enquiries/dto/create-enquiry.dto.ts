import { IsString, IsOptional, IsDateString } from 'class-validator';

export class CreateEnquiryDto {
  @IsString()
  branchId: string;

  @IsString()
  name: string;

  @IsString()
  phone: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  interestedPlanId?: string;

  @IsOptional()
  @IsString()
  source?: string;

  @IsOptional()
  @IsDateString()
  followUpDate?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
