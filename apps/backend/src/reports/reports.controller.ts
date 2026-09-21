import { Controller, Get, Query, Res, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ReportsService } from './reports.service';
import { PdfService } from './pdf.service';

@ApiTags('reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/reports')
export class ReportsController {
  constructor(
    private readonly reportsService: ReportsService,
    private readonly pdfService: PdfService,
  ) {}

  @Get('members')
  @ApiOperation({ summary: 'Member report' })
  async getMemberReport(@Query('branchId') branchId: string, @Query('status') status?: string) {
    return this.reportsService.getMemberReport(branchId, status);
  }

  @Get('collection')
  @ApiOperation({ summary: 'Collection report' })
  async getCollectionReport(
    @Query('branchId') branchId: string,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
  ) {
    return this.reportsService.getCollectionReport(branchId, dateFrom, dateTo);
  }

  @Get('dues')
  @ApiOperation({ summary: 'Due payments report' })
  async getDueReport(@Query('branchId') branchId: string) {
    return this.reportsService.getDueReport(branchId);
  }

  @Get('attendance')
  @ApiOperation({ summary: 'Attendance report' })
  async getAttendanceReport(
    @Query('branchId') branchId: string,
    @Query('dateFrom') dateFrom?: string,
    @Query('dateTo') dateTo?: string,
  ) {
    return this.reportsService.getAttendanceReport(branchId, dateFrom, dateTo);
  }

  @Get('expenses')
  @ApiOperation({ summary: 'Expense report' })
  async getExpenseReport(
    @Query('branchId') branchId: string,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ) {
    return this.reportsService.getExpenseReport(branchId, month ? Number(month) : undefined, year ? Number(year) : undefined);
  }

  @Get('expiry')
  @ApiOperation({ summary: 'Membership expiry report' })
  async getExpiryReport(@Query('branchId') branchId: string, @Query('days') days?: string) {
    return this.reportsService.getExpiryReport(branchId, days ? Number(days) : 15);
  }

  @Get('seats')
  @ApiOperation({ summary: 'Seat occupancy report' })
  async getSeatOccupancyReport(@Query('branchId') branchId: string) {
    return this.reportsService.getSeatOccupancyReport(branchId);
  }

  @Get('members/pdf')
  @ApiOperation({ summary: 'Download member report as PDF' })
  async getMemberReportPdf(@Query('branchId') branchId: string, @Res() res: Response) {
    const data = await this.reportsService.getMemberReport(branchId);
    const buffer = await this.pdfService.generateMembersReport(data);
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'attachment; filename=member-report.pdf',
      'Content-Length': buffer.length.toString(),
    });
    res.end(buffer);
  }
}
