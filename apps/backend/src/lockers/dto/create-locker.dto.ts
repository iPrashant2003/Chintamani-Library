import { IsString } from 'class-validator';

export class CreateLockerDto {
  @IsString()
  lockerNumber: string;

  @IsString()
  branchId: string;
}
