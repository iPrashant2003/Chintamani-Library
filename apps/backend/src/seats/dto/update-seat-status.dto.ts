import { IsEnum } from 'class-validator';

enum SeatStatus {
  AVAILABLE = 'AVAILABLE',
  OCCUPIED = 'OCCUPIED',
  RESERVED = 'RESERVED',
  MAINTENANCE = 'MAINTENANCE'
}

export class UpdateSeatStatusDto {
  @IsEnum(SeatStatus)
  status: SeatStatus;
}
