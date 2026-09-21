import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { PdfService } from './pdf.service';

@Module({
  imports: [PrismaModule],
  controllers: [ReportsController],
  providers: [ReportsService, PdfService],
  exports: [ReportsService],
})
export class ReportsModule {}
