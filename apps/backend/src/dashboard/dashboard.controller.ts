import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { BranchGuard } from '../common/guards/branch.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('Dashboard')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, BranchGuard)
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get()
  @ApiOperation({ summary: 'Get overall dashboard statistics' })
  @ApiQuery({ name: 'branchId', required: false, type: String })
  getDashboard(@CurrentUser() user: any, @Query('branchId') branchId?: string) {
    return this.dashboardService.getDashboardStats(user, branchId);
  }
}
