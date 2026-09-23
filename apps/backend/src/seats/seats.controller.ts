import { Controller, Get, Post, Body, Patch, Delete, Param, Query, UseGuards } from '@nestjs/common';
import { SeatsService } from './seats.service';
import { CreateSeatDto } from './dto/create-seat.dto';
import { AssignSeatDto } from './dto/assign-seat.dto';
import { UpdateSeatStatusDto } from './dto/update-seat-status.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
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

  @Get('summary')
  getSummary(@Query('branchId') branchId?: string) {
    return this.seatsService.getSummary(branchId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.seatsService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() body: { seatNumber?: string; floor?: string; notes?: string }) {
    return this.seatsService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.seatsService.remove(id);
  }

  @Patch(':id/block')
  block(@Param('id') id: string, @Body('notes') notes?: string, @CurrentUser() user?: any) {
    return this.seatsService.block(id, notes, user);
  }

  @Patch(':id/unblock')
  unblock(@Param('id') id: string, @CurrentUser() user?: any) {
    return this.seatsService.unblock(id, user);
  }

  @Post(':id/reassign')
  reassign(@Param('id') id: string, @Body('newSeatId') newSeatId: string, @CurrentUser() user?: any) {
    return this.seatsService.reassign(id, newSeatId, user);
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
