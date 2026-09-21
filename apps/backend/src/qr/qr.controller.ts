import { Controller, Post, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { QrService } from './qr.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

class GenerateQrDto {
  @IsUUID()
  @IsNotEmpty()
  memberId!: string;
}

class ValidateQrDto {
  @IsString()
  @IsNotEmpty()
  token!: string;
}

@ApiTags('QR')
@Controller('qr')
export class QrController {
  constructor(private readonly qrService: QrService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('generate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Generate 24h JWT QR token for a member' })
  generate(@Body() dto: GenerateQrDto) {
    return this.qrService.generateToken(dto.memberId);
  }

  @Post('validate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Validate a scanned QR token' })
  validate(@Body() dto: ValidateQrDto) {
    return this.qrService.validateToken(dto.token);
  }
}
