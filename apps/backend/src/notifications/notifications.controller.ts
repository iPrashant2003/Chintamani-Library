import { Controller, Get, Post, Body, Patch, Param, Query, UseGuards } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post()
  create(@Body() createNotificationDto: CreateNotificationDto) {
    return this.notificationsService.create(createNotificationDto);
  }

  @Get()
  findAll(
    @Query('userId') userId?: string,
    @Query('isRead') isRead?: string,
  ) {
    const read = isRead !== undefined ? isRead === 'true' : undefined;
    return this.notificationsService.findAll(userId, read);
  }

  @Patch(':id/read')
  markRead(@Param('id') id: string) {
    return this.notificationsService.markRead(id);
  }

  @Patch('read-all')
  markAllRead(@Query('userId') userId?: string) {
    // Optional logic to mark all read for a specific user if userId is provided
    return this.notificationsService.markAllRead();
  }
}
