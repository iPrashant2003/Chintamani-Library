import { Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { BackupService } from './backup.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('Backup')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('backup')
export class BackupController {
  constructor(private readonly backupService: BackupService) {}

  @Post('create')
  createBackup(@CurrentUser() user: any) {
    return this.backupService.performBackup('MANUAL', user);
  }

  @Get('logs')
  getLogs(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.backupService.findAll(page ? Number(page) : 1, limit ? Number(limit) : 20);
  }

  @Get('latest')
  getLatest() {
    return this.backupService.getLatest();
  }
}
