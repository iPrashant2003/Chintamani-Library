import { IsString, IsOptional, IsEnum, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty({ enum: ['SMS', 'WHATSAPP', 'PUSH'] })
  @IsEnum(['SMS', 'WHATSAPP', 'PUSH'])
  channel: string;

  @ApiProperty()
  @IsString()
  recipientPhone: string;

  @ApiProperty()
  @IsString()
  templateName: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  variables?: Record<string, string>;
}
