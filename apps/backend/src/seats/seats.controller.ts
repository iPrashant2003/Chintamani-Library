import { Controller, Get, Post, Body, Patch, Param, Query, UseGuards } from '@nestjs/common';
import { SeatsService } from './seats.service';
import { CreateSeatDto } from './dto/create-seat.dto';
import { AssignSeatDto } from './dto/assign-seat.dto';
import { UpdateSeatStatusDto } from './dto/update-seat-status.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('seats')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('seats')
export class SeatsController {
  constructor(private readonly seatsService: SeatsService) {}

  @Post()
  create(@Body() createSeatDto: CreateSeatDto) {
    return this.seatsService.create(createSeatDto);
  }

  @Get()
  findAll(@Query('branchId') branchId?: string, @Query('floor') floor?: string, @Query('status') status?: string) {
    return this.seatsService.findAll(branchId, floor, status);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.seatsService.findOne(id);
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body() updateSeatStatusDto: UpdateSeatStatusDto) {
    return this.seatsService.updateStatus(id, updateSeatStatusDto.status);
  }

  @Post(':id/assign')
  assign(@Param('id') id: string, @Body() assignSeatDto: AssignSeatDto) {
    return this.seatsService.assign(id, assignSeatDto.subscriptionId);
  }

  @Post(':id/release')
  release(@Param('id') id: string) {
    return this.seatsService.release(id);
  }

  @Get(':id/history')
  getHistory(@Param('id') id: string) {
    return this.seatsService.getHistory(id);
  }
}
