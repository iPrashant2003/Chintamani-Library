import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateNotificationDto) {
    return this.prisma.notification.create({
      data: {
        type: dto.type,
        title: dto.title,
        body: dto.body,
      },
    });
  }

  async findAll(userId?: string, isRead?: boolean) {
    return this.prisma.notification.findMany({
      where: {
        ...(isRead !== undefined && { isRead }),
        // ... (userId && { userId })
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async markRead(id: string) {
    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async markAllRead() {
    return this.prisma.notification.updateMany({
      where: { isRead: false },
      data: { isRead: true },
    });
  }
}
