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

  // ── UNIVERSAL PORTAL QR ───────────────────────────────────────────────────

  async getUniversalPortalQr(branchId?: string, hostOrigin?: string) {
    let branch = branchId
      ? await this.prisma.branch.findUnique({ where: { id: branchId }, include: { tenant: true } })
      : await this.prisma.branch.findFirst({ include: { tenant: true } });

    if (!branch) {
      const tenant = await this.prisma.tenant.findFirst({ include: { branches: true } });
      branch = tenant?.branches[0] ? { ...tenant.branches[0], tenant } : null;
    }

    // Use production BASE_URL from environment (set in Railway dashboard)
    // This ensures QR codes always point to the cloud URL, never localhost
    const base = process.env.BASE_URL
      || hostOrigin
      || 'https://chintamani-backend.up.railway.app';
    const portalUrl = `${base}/portal/index.html?branch=${branch?.id || 'default'}`;

    // Import qrcode
    const QRCode = require('qrcode');
    const qrDataUrl = await QRCode.toDataURL(portalUrl, {
      width: 512,
      margin: 2,
      color: { dark: '#000000', light: '#ffffff' },
      errorCorrectionLevel: 'H',
    });

    // Save PNG file to public/qr
    const fs = require('fs');
    const path = require('path');
    const qrDir = path.join(process.cwd(), 'public', 'qr');
    if (!fs.existsSync(qrDir)) {
      fs.mkdirSync(qrDir, { recursive: true });
    }
    const filePath = path.join(qrDir, 'universal-portal-qr.png');
    await QRCode.toFile(filePath, portalUrl, {
      width: 600,
      margin: 2,
      color: { dark: '#000000', light: '#ffffff' },
      errorCorrectionLevel: 'H',
    });

    // Save or update permanent QrCode record in DB
    const token = `PORTAL_${branch?.id || 'GLOBAL'}`;
    const farFuture = new Date();
    farFuture.setFullYear(farFuture.getFullYear() + 20); // 20 years

    await this.prisma.qrCode.upsert({
      where: { token },
      update: { url: portalUrl, expiresAt: farFuture },
      create: {
        tenantId: branch?.tenantId,
        entityType: 'LIBRARY_PORTAL',
        entityId: branch?.id || 'ALL',
        token,
        url: portalUrl,
        expiresAt: farFuture,
      },
    });

    return {
      portalUrl,
      qrDataUrl,
      qrImageUrl: '/qr/universal-portal-qr.png',
      branchName: branch?.name || 'Chintamani Library',
      tenantName: branch?.tenant?.name || 'Chintamani Library',
    };
  }
}
