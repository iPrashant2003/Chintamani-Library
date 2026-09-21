import { IsString, IsNotEmpty } from 'class-validator';

export class AssignBranchDto {
  @IsString()
  @IsNotEmpty()
  branchId: string;
}
