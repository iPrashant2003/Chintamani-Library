import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RegistrationsService } from './registrations.service';
import {
  QueryRegistrationsDto,
  ApproveRegistrationDto,
  RejectRegistrationDto,
  AssignSeatDto,
} from './dto/registrations.dto';

@ApiTags('Registrations (Admin)')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('registrations')
export class RegistrationsController {
  constructor(private readonly registrationsService: RegistrationsService) {}

  @Get()
  @ApiOperation({ summary: 'List all or pending member registrations' })
  findAll(@Query() query: QueryRegistrationsDto) {
    return this.registrationsService.findAll(query);
  }

  @Get('pending-count')
  @ApiOperation({ summary: 'Get total pending registration count' })
  getPendingCount(@Query('branchId') branchId?: string) {
    return this.registrationsService.getPendingCount(branchId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get complete registration application details' })
  findOne(@Param('id') id: string) {
    return this.registrationsService.findOne(id);
  }

  @Patch(':id/assign-seat')
  @ApiOperation({ summary: 'Assign or reserve a seat for an applicant' })
  assignSeat(
    @Param('id') id: string,
    @Body() dto: AssignSeatDto,
    @CurrentUser() user: any,
  ) {
    return this.registrationsService.assignSeat(id, dto, user);
  }

  @Patch(':id/approve')
  @ApiOperation({ summary: 'Approve registration, activate member and occupy seat' })
  approve(
    @Param('id') id: string,
    @Body() dto: ApproveRegistrationDto,
    @CurrentUser() user: any,
  ) {
    return this.registrationsService.approve(id, dto, user);
  }

  @Patch(':id/reject')
  @ApiOperation({ summary: 'Reject registration and release reserved seat back to AVAILABLE' })
  reject(
    @Param('id') id: string,
    @Body() dto: RejectRegistrationDto,
    @CurrentUser() user: any,
  ) {
    return this.registrationsService.reject(id, dto, user);
  }
}
