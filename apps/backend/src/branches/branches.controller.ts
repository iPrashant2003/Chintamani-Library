import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { BranchesService } from './branches.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('Branches')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Post()
  create(@CurrentUser() user: any, @Body() createBranchDto: CreateBranchDto) {
    return this.branchesService.create(user, createBranchDto);
  }

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.branchesService.findAll(user);
  }

  @Get(':id')
  findOne(@CurrentUser() user: any, @Param('id') id: string) {
    return this.branchesService.findOne(user, id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateBranchDto: UpdateBranchDto) {
    return this.branchesService.update(id, updateBranchDto);
  }

  @Get(':id/stats')
  getStats(@Param('id') id: string) {
    return this.branchesService.getStats(id);
  }
}
