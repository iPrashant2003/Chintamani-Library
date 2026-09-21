import { IsString, IsOptional, IsNumber, Min, IsEnum, IsDateString } from 'class-validator';

enum PaymentMethod {
  CASH = 'CASH',
  UPI = 'UPI',
  CARD = 'CARD',
  BANK_TRANSFER = 'BANK_TRANSFER'
}

export class CreatePaymentDto {
  @IsString()
  memberId: string;

  @IsOptional()
  @IsString()
  subscriptionId?: string;

  @IsString()
  branchId: string;

  @IsNumber()
  @Min(0)
  amount: number;

  @IsOptional()
  @IsNumber()
  discount?: number;

  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @IsOptional()
  @IsString()
  txnRef?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsDateString()
  paidAt?: string;
}
