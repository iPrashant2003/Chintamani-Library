import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { TenantsService } from './tenants.service';
import { RegisterTenantDto } from './dto/register-tenant.dto';
import { UpdateTenantDto } from './dto/update-tenant.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Tenants')
@Controller('tenants')
export class TenantsController {
  constructor(private readonly tenantsService: TenantsService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register a new library / tenant (Public)' })
  async register(@Body() dto: RegisterTenantDto) {
    return this.tenantsService.register(dto);
  }

  @Get('by-code/:code')
  @ApiOperation({ summary: 'Lookup library info by code for branding (Public)' })
  async findByCode(@Param('code') code: string) {
    return this.tenantsService.findByCode(code);
  }

  @Get('profile')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get current user library profile' })
  async getProfile(@CurrentUser() user: any) {
    return this.tenantsService.getProfile(user.tenantId);
  }

  @Patch('profile')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Update library profile (Owner/Admin only)' })
  async updateProfile(@CurrentUser() user: any, @Body() dto: UpdateTenantDto) {
    return this.tenantsService.updateProfile(user.tenantId, dto);
  }

  @Get()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'List all libraries (Super Admin only)' })
  async findAll(@CurrentUser() user: any) {
    return this.tenantsService.findAll();
  }
}
