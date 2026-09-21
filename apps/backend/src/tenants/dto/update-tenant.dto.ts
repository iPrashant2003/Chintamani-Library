import { PartialType } from '@nestjs/swagger';
import { RegisterTenantDto } from './register-tenant.dto';

export class UpdateTenantDto extends PartialType(RegisterTenantDto) {}
