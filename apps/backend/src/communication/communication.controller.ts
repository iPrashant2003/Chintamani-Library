import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CommunicationService } from './communication.service';
import { SendMessageDto } from './dto/send-message.dto';

@ApiTags('communication')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/communication')
export class CommunicationController {
  constructor(private readonly communicationService: CommunicationService) {}

  @Post('send')
  @ApiOperation({ summary: 'Send a message via SMS/WhatsApp/Push' })
  async send(@Body() dto: SendMessageDto) {
    return this.communicationService.send(dto);
  }

  @Get('logs')
  @ApiOperation({ summary: 'Get communication history' })
  async getLogs(@Query('limit') limit?: number) {
    return this.communicationService.getLogs(limit ? Number(limit) : 100);
  }

  @Get('templates')
  @ApiOperation({ summary: 'Get available message templates' })
  async getTemplates() {
    return this.communicationService.getTemplates();
  }
}
