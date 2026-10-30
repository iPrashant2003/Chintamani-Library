import { Controller, Post, Body, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AiService } from './ai.service';
import { ChatRequestDto } from './dto/chat-request.dto';

@ApiTags('ai')
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Chat with ChintaMani AI assistant (authenticated or guest)' })
  chat(@Body() dto: ChatRequestDto, @Request() req: any) {
    return this.aiService.chat(dto, req?.user || null);
  }

  @Post('chat-public')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Public chat with ChintaMani AI (no auth required — external member portal)' })
  publicChat(@Body() dto: ChatRequestDto) {
    return this.aiService.publicChat(dto);
  }
}
