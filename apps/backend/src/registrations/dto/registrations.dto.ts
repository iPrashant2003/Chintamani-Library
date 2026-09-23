import { IsNotEmpty, IsString, IsOptional, IsNumber } from 'class-validator';

export class QueryRegistrationsDto {
  @IsOptional()
  @IsString()
  status?: string; // PENDING, APPROVED, REJECTED, ALL

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

export class ApproveRegistrationDto {
  @IsOptional()
  @IsString()
  seatId?: string; // Optional manual seat assignment on approval

  @IsOptional()
  @IsString()
  notes?: string;
}

export class RejectRegistrationDto {
  @IsOptional()
  @IsString()
  reason?: string;
}

export class AssignSeatDto {
  @IsString()
  @IsNotEmpty()
  seatId!: string;
}
