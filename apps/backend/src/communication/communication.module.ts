import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { CommunicationController } from './communication.controller';
import { CommunicationService } from './communication.service';

@Module({
  imports: [PrismaModule],
  controllers: [CommunicationController],
  providers: [CommunicationService],
  exports: [CommunicationService],
})
export class CommunicationModule {}
