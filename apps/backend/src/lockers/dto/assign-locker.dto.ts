import { IsString } from 'class-validator';

export class AssignLockerDto {
  @IsString()
  subscriptionId: string;
}
