import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { MembersService } from './members.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { QueryMembersDto } from './dto/query-members.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('Members')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('members')
export class MembersController {
  constructor(private readonly membersService: MembersService) {}

  @Post()
  create(@CurrentUser() user: any, @Body() createMemberDto: CreateMemberDto) {
    return this.membersService.create(user, createMemberDto);
  }

  @Get()
  findAll(@CurrentUser() user: any, @Query() query: QueryMembersDto) {
    return this.membersService.findAll(user, query);
  }

  @Get(':id')
  findOne(@CurrentUser() user: any, @Param('id') id: string) {
    return this.membersService.getMemberProfile(user, id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateMemberDto: UpdateMemberDto) {
    return this.membersService.update(id, updateMemberDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.membersService.remove(id);
  }

  @Get(':id/payments')
  getPayments(@Param('id') id: string) {
    return this.membersService.getPayments(id);
  }

  @Get(':id/attendance')
  getAttendance(@Param('id') id: string) {
    return this.membersService.getAttendance(id);
  }

  @Get(':id/subscriptions')
  getSubscriptions(@Param('id') id: string) {
    return this.membersService.getSubscriptions(id);
  }
}
