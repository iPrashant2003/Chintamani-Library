import { Injectable, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class QrService {
  constructor(
    private jwtService: JwtService,
    private prisma: PrismaService,
  ) {}

  async generateToken(memberId: string) {
    const member = await this.prisma.member.findUnique({ where: { id: memberId } });
    if (!member) throw new BadRequestException('Member not found');

    const payload = { memberId, type: 'ATTENDANCE_QR' };
    const token = this.jwtService.sign(payload);

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    await this.prisma.qrCode.create({
      data: {
        entityType: 'MEMBER',
        entityId: memberId,
        token,
        expiresAt,
      },
    });

    return { token, expiresAt };
  }

  async validateToken(token: string) {
    try {
      const decoded = this.jwtService.verify(token);
      
      const qrRecord = await this.prisma.qrCode.findUnique({
        where: { token },
      });

      if (!qrRecord || qrRecord.expiresAt < new Date()) {
        throw new BadRequestException('QR token expired or invalid');
      }

      const member = await this.prisma.member.findUnique({
        where: { id: decoded.memberId },
        select: { id: true, name: true, memberCode: true, branchId: true },
      });

      if (!member) throw new BadRequestException('Member not found');

      return member;
    } catch (e) {
      throw new BadRequestException('Invalid QR token');
    }
  }
}
