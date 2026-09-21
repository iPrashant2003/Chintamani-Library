import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MockSmsProvider } from './providers/sms.provider';
import { MockWhatsappProvider } from './providers/whatsapp.provider';
import { MockPushProvider } from './providers/push.provider';
import { CommunicationTemplates } from './templates/communication-templates';
import { SendMessageDto } from './dto/send-message.dto';

@Injectable()
export class CommunicationService {
  constructor(private readonly prisma: PrismaService) {}

  async send(dto: SendMessageDto) {
    const templateDef = CommunicationTemplates[dto.templateName];
    let message = templateDef ? templateDef.template : dto.templateName;

    if (dto.variables) {
      Object.keys(dto.variables).forEach((key) => {
        message = message.replace(new RegExp(`{{${key}}}`, 'g'), dto.variables[key]);
      });
    }

    let result: { success: boolean; ref?: string };

    switch (dto.channel) {
      case 'SMS':
        result = await new MockSmsProvider().send(dto.recipientPhone, message);
        break;
      case 'WHATSAPP':
        result = await new MockWhatsappProvider().send(dto.recipientPhone, message);
        break;
      case 'PUSH':
        result = await new MockPushProvider().send(dto.recipientPhone, 'Chintamani Library', message);
        break;
      default:
        result = { success: false };
    }

    await this.prisma.communicationLog.create({
      data: {
        channel: dto.channel as any,
        recipient: dto.recipientPhone,
        message,
        status: result.success ? 'SENT' : 'FAILED',
      },
    });

    return { success: result.success, ref: result.ref, message: 'Message processed' };
  }

  async getLogs(limit = 100) {
    return this.prisma.communicationLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async getTemplates() {
    return Object.entries(CommunicationTemplates).map(([key, val]) => ({
      key,
      ...val,
    }));
  }
}
