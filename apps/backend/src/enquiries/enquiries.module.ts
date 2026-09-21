import { Module } from '@nestjs/common';
import { EnquiriesService } from './enquiries.service';
import { EnquiriesController } from './enquiries.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [EnquiriesController],
  providers: [EnquiriesService],
  exports: [EnquiriesService],
})
export class EnquiriesModule {}
