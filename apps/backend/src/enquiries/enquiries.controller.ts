import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from '@nestjs/common';
import { EnquiriesService } from './enquiries.service';
import { CreateEnquiryDto } from './dto/create-enquiry.dto';
import { UpdateEnquiryDto } from './dto/update-enquiry.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('enquiries')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('enquiries')
export class EnquiriesController {
  constructor(private readonly enquiriesService: EnquiriesService) {}

  @Post()
  create(@Body() createEnquiryDto: CreateEnquiryDto) {
    return this.enquiriesService.create(createEnquiryDto);
  }

  @Get()
  findAll(
    @Query('branchId') branchId?: string,
    @Query('status') status?: string,
    @Query('todayFollowups') todayFollowups?: string,
  ) {
    if (todayFollowups === 'true' && branchId) {
      return this.enquiriesService.getTodayFollowups(branchId);
    }
    return this.enquiriesService.findAll(branchId, status);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.enquiriesService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateEnquiryDto: UpdateEnquiryDto) {
    return this.enquiriesService.update(id, updateEnquiryDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.enquiriesService.remove(id);
  }

  @Patch(':id/convert')
  convert(@Param('id') id: string, @Query('memberId') memberId: string) {
    return this.enquiriesService.convert(id, memberId);
  }
}
