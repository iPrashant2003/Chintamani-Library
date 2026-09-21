import { IsString, IsOptional, IsEnum, IsDateString } from 'class-validator';
import { EnquiryStatus } from '@prisma/client';

export class UpdateEnquiryDto {
  @IsOptional()
  @IsEnum(EnquiryStatus)
  status?: EnquiryStatus;

  @IsOptional()
  @IsDateString()
  followUpDate?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
