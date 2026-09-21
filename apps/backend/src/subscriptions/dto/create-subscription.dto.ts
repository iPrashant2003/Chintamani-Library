import { IsString, IsOptional, IsNumber, IsDateString, IsEnum } from 'class-validator';

enum PaymentMethod {
  CASH = 'CASH',
  UPI = 'UPI',
  CARD = 'CARD',
  BANK_TRANSFER = 'BANK_TRANSFER'
}

export class CreateSubscriptionDto {
  @IsString()
  memberId: string;

  @IsString()
  planId: string;

  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsString()
  seatId?: string;

  @IsOptional()
  @IsString()
  lockerId?: string;

  @IsOptional()
  @IsNumber()
  amount?: number;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;

  @IsOptional()
  @IsString()
  txnRef?: string;
}
