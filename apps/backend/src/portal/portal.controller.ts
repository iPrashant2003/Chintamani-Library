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
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { memoryStorage } from 'multer';
import { PortalService } from './portal.service';
import { UploadService } from '../upload/upload.service';
import {
  SendOtpDto,
  VerifyOtpDto,
  PortalRegisterDto,
  PortalPaymentDto,
  PortalComplaintDto,
  PortalFeedbackDto,
  PortalAttendanceDto,
} from './dto/portal.dto';

@ApiTags('Member Portal (Public)')
@Controller(['portal', 'api/portal'])
export class PortalController {
  constructor(
    private readonly portalService: PortalService,
    private readonly uploadService: UploadService,
  ) {}

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

  @Post('feedback')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit feedback & review' })
  submitFeedback(@Body() dto: PortalFeedbackDto) {
    return this.portalService.submitFeedback(dto);
  }

  @Get('feedback')
  @ApiOperation({ summary: 'Get public feedback & reviews' })
  getFeedback(@Query('branchId') branchId?: string) {
    return this.portalService.getFeedback(branchId);
  }

  @Get('seats/by-batch')
  @ApiOperation({ summary: 'Get dynamic available seats filtered by batch and timing' })
  getSeatsByBatch(
    @Query('batch') batch?: string,
    @Query('timing') timing?: string,
    @Query('branchId') branchId?: string,
  ) {
    return this.portalService.getSeatsByBatch(batch, timing, branchId);
  }

  @Post('attendance')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit member self-attendance (Check-in/Check-out via QR or mobile)' })
  submitAttendance(@Body() dto: PortalAttendanceDto) {
    return this.portalService.submitAttendance(dto);
  }

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.startsWith('image/')) {
          return cb(new BadRequestException('Only image files (JPG, PNG, WEBP, HEIC) are allowed') as any, false);
        }
        cb(null, true);
      },
    }),
  )
  @ApiOperation({ summary: 'Public branch-isolated upload for student photos, Aadhaar & payment screenshots (Max 5MB)' })
  async uploadFile(
    @UploadedFile() file: any,
    @Query('branchId') branchId?: string,
    @Query('folder') folderType?: string,
  ) {
    if (!file || !file.buffer) {
      throw new BadRequestException('No file provided or file is empty');
    }
    if (file.size > 5 * 1024 * 1024) {
      throw new BadRequestException('Photo is larger than 5 MB. Please choose a smaller image.');
    }
    try {
      const bKey = (branchId || '').toLowerCase().includes('mehda') ? 'mehdawal' : 'khalilabad';
      const subFolder = folderType === 'payment'
        ? 'payments'
        : (folderType === 'document' ? 'documents' : 'members/photos');
      const folderPath = `chintamani/${bKey}/${subFolder}`;

      const url = await this.uploadService.uploadFile(
        file.buffer,
        file.originalname || 'photo.jpg',
        folderPath,
      );
      return { success: true, url, branch: bKey, folder: folderPath };
    } catch (err: any) {
      throw new BadRequestException(`Upload failed: ${err?.message || 'Unknown error'}`);
    }
  }
}
