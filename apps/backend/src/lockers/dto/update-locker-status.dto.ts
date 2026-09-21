import { IsEnum } from 'class-validator';

enum LockerStatus {
  AVAILABLE = 'AVAILABLE',
  OCCUPIED = 'OCCUPIED',
  RESERVED = 'RESERVED',
  MAINTENANCE = 'MAINTENANCE'
}

export class UpdateLockerStatusDto {
  @IsEnum(LockerStatus)
  status: LockerStatus;
}
