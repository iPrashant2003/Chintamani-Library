import { OmitType, PartialType } from '@nestjs/mapped-types';
import { CreatePlanDto } from './create-plan.dto';

export class UpdatePlanDto extends PartialType(OmitType(CreatePlanDto, ['branchId'] as const)) {}
