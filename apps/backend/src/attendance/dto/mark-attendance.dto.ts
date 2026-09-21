import { IsNotEmpty, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class MarkAttendanceDto {
  @ApiProperty()
  @IsUUID()
  @IsNotEmpty()
  memberId!: string;

  @ApiProperty()
  @IsUUID()
  @IsNotEmpty()
  branchId!: string;
}
