import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { RenewSubscriptionDto } from './dto/renew-subscription.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('subscriptions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Post()
  create(@Body() createSubscriptionDto: CreateSubscriptionDto) {
    return this.subscriptionsService.create(createSubscriptionDto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.subscriptionsService.findOne(id);
  }

  @Patch(':id/renew')
  renew(@Param('id') id: string, @Body() renewSubscriptionDto: RenewSubscriptionDto) {
    return this.subscriptionsService.renew(id, renewSubscriptionDto);
  }

  @Patch(':id/cancel')
  cancel(@Param('id') id: string) {
    return this.subscriptionsService.cancel(id);
  }
}
