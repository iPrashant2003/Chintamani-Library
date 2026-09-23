import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ComplaintsService } from './complaints.service';
import { QueryComplaintsDto, UpdateComplaintStatusDto } from './dto/complaints.dto';

@ApiTags('Complaints (Admin)')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('complaints')
export class ComplaintsController {
  constructor(private readonly complaintsService: ComplaintsService) {}

  @Get()
  @ApiOperation({ summary: 'List all complaints' })
  findAll(@Query() query: QueryComplaintsDto) {
    return this.complaintsService.findAll(query);
  }

  @Get('open-count')
  @ApiOperation({ summary: 'Get count of open / in-progress complaints' })
  getOpenCount(@Query('branchId') branchId?: string) {
    return this.complaintsService.getOpenCount(branchId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get full complaint details' })
  findOne(@Param('id') id: string) {
    return this.complaintsService.findOne(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update complaint status and resolution notes' })
  updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateComplaintStatusDto,
    @CurrentUser() user: any,
  ) {
    return this.complaintsService.updateStatus(id, dto, user);
  }
}
