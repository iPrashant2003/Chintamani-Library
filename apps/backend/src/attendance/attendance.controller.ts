import { Controller, Post, Get, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { AttendanceService } from './attendance.service';
import { MarkAttendanceDto } from './dto/mark-attendance.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { BranchGuard } from '../common/guards/branch.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Attendance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, BranchGuard)
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Post('mark')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark manual attendance (Check-in/Check-out toggled automatically)' })
  markManual(@Body() dto: MarkAttendanceDto) {
    return this.attendanceService.markAttendance(dto, 'MANUAL');
  }

  @Get('today')
  @ApiOperation({ summary: "Get today's branch attendance stream" })
  getToday(@Query('branchId') branchId: string) {
    return this.attendanceService.getTodayAttendance(branchId);
  }

  @Get()
  @ApiOperation({ summary: 'Get attendance history' })
  getHistory(@Query('branchId') branchId: string, @Query('limit') limit?: number) {
    return this.attendanceService.getAttendanceHistory(branchId, limit ? Number(limit) : 50);
  }
}

