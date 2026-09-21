import { IsString, IsOptional, IsNotEmpty, IsDateString } from 'class-validator';

export class CreateMemberDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  fatherName?: string;

  @IsDateString()
  @IsOptional()
  dob?: string;

  @IsString()
  @IsOptional()
  gender?: string;

  @IsString()
  @IsNotEmpty()
  phone: string;

  @IsString()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  emergencyContact?: string;

  @IsString()
  @IsOptional()
  aadhaar?: string;

  @IsString()
  @IsOptional()
  institute?: string;

  @IsString()
  @IsOptional()
  course?: string;

  @IsString()
  @IsOptional()
  batch?: string;

  @IsString()
  @IsOptional()
  photoUrl?: string;

  @IsString()
  @IsOptional()
  notes?: string;

  @IsString()
  @IsNotEmpty()
  branchId: string;
}
