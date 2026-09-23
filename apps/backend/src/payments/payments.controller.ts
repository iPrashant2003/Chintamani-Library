import { Controller, Get, Post, Body, Patch, Param, Query, UseGuards } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { QueryPaymentsDto } from './dto/query-payments.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post()
  create(@Body() createPaymentDto: CreatePaymentDto) {
    return this.paymentsService.create(createPaymentDto);
  }

  @Get()
  findAll(@Query() query: QueryPaymentsDto) {
    return this.paymentsService.findAll(query);
  }

  @Get('dues')
  getDues(@Query('branchId') branchId: string) {
    return this.paymentsService.getDues(branchId);
  }

  @Get('summary')
  getSummary(@Query('branchId') branchId: string, @Query('dateFrom') dateFrom?: string, @Query('dateTo') dateTo?: string) {
    return this.paymentsService.getSummary(branchId, dateFrom, dateTo);
  }

  // ── PAYMENT VERIFICATION (ADMIN) ──────────────────────────────────────────

  @Get('verifications')
  getVerifications(
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.paymentsService.getVerifications({ status, search, page, limit });
  }

  @Get('verifications/pending-count')
  getPendingVerificationCount() {
    return this.paymentsService.getPendingVerificationCount();
  }

  @Get('verifications/:id')
  getVerification(@Param('id') id: string) {
    return this.paymentsService.getVerification(id);
  }

  @Patch('verifications/:id/approve')
  approveVerification(@Param('id') id: string) {
    return this.paymentsService.approveVerification(id);
  }

  @Patch('verifications/:id/reject')
  rejectVerification(@Param('id') id: string, @Body('reason') reason?: string) {
    return this.paymentsService.rejectVerification(id, reason);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.paymentsService.findOne(id);
  }

  @Patch(':id')
  updateStatus(@Param('id') id: string, @Body('status') status: string) {
    return this.paymentsService.updateStatus(id, status);
  }

  @Get('member/:memberId')
  findByMember(@Param('memberId') memberId: string) {
    return this.paymentsService.findByMember(memberId);
  }
}
