import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { PortalService } from './portal.service';
import {
  SendOtpDto,
  VerifyOtpDto,
  PortalRegisterDto,
  PortalPaymentDto,
  PortalComplaintDto,
} from './dto/portal.dto';

@ApiTags('Member Portal (Public)')
@Controller('portal')
export class PortalController {
  constructor(private readonly portalService: PortalService) {}

  @Post('otp/send')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send OTP to mobile number for login or verification' })
  sendOtp(@Body() dto: SendOtpDto) {
    return this.portalService.sendOtp(dto);
  }

  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and return session token' })
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.portalService.verifyOtp(dto);
  }

  @Get('info')
  @ApiOperation({ summary: 'Get public library and branch info' })
  getInfo(@Query('branchId') branchId?: string) {
    return this.portalService.getLibraryInfo(branchId);
  }

  @Get('plans')
  @ApiOperation({ summary: 'Get available plans dynamically' })
  getPlans(@Query('branchId') branchId?: string) {
    return this.portalService.getPlans(branchId);
  }

  @Get('seats/stats')
  @ApiOperation({ summary: 'Get live seat availability statistics' })
  getSeatStats(@Query('branchId') branchId?: string) {
    return this.portalService.getSeatStats(branchId);
  }

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit new member registration application' })
  register(@Body() dto: PortalRegisterDto) {
    return this.portalService.register(dto);
  }

  @Get('registration/:applicationId')
  @ApiOperation({ summary: 'Check registration application status' })
  getRegistrationStatus(@Param('applicationId') applicationId: string) {
    return this.portalService.getRegistrationStatus(applicationId);
  }

  @Post('payment')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit payment screenshot and reference for admin verification' })
  submitPayment(@Body() dto: PortalPaymentDto) {
    return this.portalService.submitPayment(dto);
  }

  @Post('complaint')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit complaint' })
  submitComplaint(@Body() dto: PortalComplaintDto) {
    return this.portalService.submitComplaint(dto);
  }

  @Get('complaint/:complaintId')
  @ApiOperation({ summary: 'Check complaint resolution status' })
  getComplaintStatus(@Param('complaintId') complaintId: string) {
    return this.portalService.getComplaintStatus(complaintId);
  }

  @Get('dashboard')
  @ApiOperation({ summary: 'Get member dashboard data by token or phone' })
  getDashboard(@Query('identifier') identifier: string) {
    return this.portalService.getMemberDashboard(identifier);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get 6-month member activity & payment history timeline' })
  getHistory(@Query('identifier') identifier: string) {
    return this.portalService.getMemberHistory(identifier);
  }

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `portal-${uniqueSuffix}${extname(file.originalname || '.jpg')}`);
        },
      }),
      limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    }),
  )
  @ApiOperation({ summary: 'Public file upload for registration docs, selfies & payment screenshots' })
  uploadFile(@UploadedFile() file: Express.Multer.File) {
    return { url: `/uploads/${file.filename}` };
  }
}
