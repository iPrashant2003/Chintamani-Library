import { IsOptional, IsString } from 'class-validator';

export class RenewSubscriptionDto {
  @IsOptional()
  @IsString()
  notes?: string;
}
