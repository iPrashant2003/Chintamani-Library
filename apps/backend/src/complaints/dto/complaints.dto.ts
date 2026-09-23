import { IsNotEmpty, IsString, IsOptional } from 'class-validator';

export class QueryComplaintsDto {
  @IsOptional()
  @IsString()
  status?: string; // OPEN, IN_PROGRESS, RESOLVED, CLOSED, ALL

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  branchId?: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  page?: string;

  @IsOptional()
  limit?: string;
}

export class UpdateComplaintStatusDto {
  @IsString()
  @IsNotEmpty()
  status!: string; // OPEN, IN_PROGRESS, RESOLVED, CLOSED

  @IsOptional()
  @IsString()
  resolution?: string;

  @IsOptional()
  @IsString()
  assignedTo?: string;
}
