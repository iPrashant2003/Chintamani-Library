import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { SchedulerService } from './scheduler.service';
import { BackupModule } from '../backup/backup.module';

@Module({
  imports: [ScheduleModule.forRoot(), BackupModule],
  providers: [SchedulerService],
  exports: [SchedulerService],
})
export class SchedulerModule {}
