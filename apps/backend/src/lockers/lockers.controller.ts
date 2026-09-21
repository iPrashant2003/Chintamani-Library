import { Controller, Get, Post, Body, Patch, Param, Query, UseGuards } from '@nestjs/common';
import { LockersService } from './lockers.service';
import { CreateLockerDto } from './dto/create-locker.dto';
import { AssignLockerDto } from './dto/assign-locker.dto';
import { UpdateLockerStatusDto } from './dto/update-locker-status.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('lockers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('lockers')
export class LockersController {
  constructor(private readonly lockersService: LockersService) {}

  @Post()
  create(@Body() createLockerDto: CreateLockerDto) {
    return this.lockersService.create(createLockerDto);
  }

  @Get()
  findAll(@Query('branchId') branchId?: string, @Query('status') status?: string) {
    return this.lockersService.findAll(branchId, status);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.lockersService.findOne(id);
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body() updateLockerStatusDto: UpdateLockerStatusDto) {
    return this.lockersService.updateStatus(id, updateLockerStatusDto.status);
  }

  @Post(':id/assign')
  assign(@Param('id') id: string, @Body() assignLockerDto: AssignLockerDto) {
    return this.lockersService.assign(id, assignLockerDto.subscriptionId);
  }

  @Post(':id/release')
  release(@Param('id') id: string) {
    return this.lockersService.release(id);
  }

  @Get(':id/history')
  getHistory(@Param('id') id: string) {
    return this.lockersService.getHistory(id);
  }
}
