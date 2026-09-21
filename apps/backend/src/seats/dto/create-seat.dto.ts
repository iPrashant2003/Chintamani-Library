import { IsString } from 'class-validator';

export class CreateSeatDto {
  @IsString()
  seatNumber: string;

  @IsString()
  floor: string;

  @IsString()
  branchId: string;
}
