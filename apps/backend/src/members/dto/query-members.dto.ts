import { IsString, IsOptional, IsNumberString } from 'class-validator';

export class QueryMembersDto {
  @IsString()
  @IsOptional()
  branchId?: string;

  @IsString()
  @IsOptional()
  status?: string;

  @IsString()
  @IsOptional()
  search?: string;

  @IsNumberString()
  @IsOptional()
  page?: string;

  @IsNumberString()
  @IsOptional()
  limit?: string;
}
