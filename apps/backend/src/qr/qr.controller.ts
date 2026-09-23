import { Controller, Post, Get, Body, UseGuards, HttpCode, HttpStatus, Query, Req } from '@nestjs/common';
import { Request } from 'express';
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

  @Get('portal')
  @ApiOperation({ summary: 'Get permanent Universal Library QR code for Member Portal' })
  getPortalQr(@Query('branchId') branchId: string | undefined, @Req() req: Request) {
    const protocol = req.protocol || 'http';
    const host = req.get('host') || 'localhost:3000';
    const origin = `${protocol}://${host}`;
    return this.qrService.getUniversalPortalQr(branchId, origin);
  }

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
