import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDto) {
    const rawId = (loginDto.email || '').trim();
    const phoneDigits = rawId.replace(/\D/g, '');

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: { equals: rawId, mode: 'insensitive' } },
          ...(phoneDigits.length >= 7 ? [{ phone: { contains: phoneDigits.slice(-10) } }] : []),
        ],
      },
      include: {
        branches: true,
        permissions: true,
        tenant: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    let isPasswordValid = false;
    try {
      isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    } catch (_) {}

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const branchIds = user.branches.map((b) => b.branchId);
    const permissions = user.permissions.map((p) => p.action);

    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      tenantId: user.tenantId,
      branchIds,
      permissions,
    };

    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        tenantId: user.tenantId,
        branchIds,
      },
      tenant: user.tenant
        ? {
            id: user.tenant.id,
            name: user.tenant.name,
            code: user.tenant.code,
            slug: user.tenant.slug,
            logo: user.tenant.logo,
            phone: user.tenant.phone,
            email: user.tenant.email,
            city: user.tenant.city,
            state: user.tenant.state,
            country: user.tenant.country,
            plan: user.tenant.plan,
          }
        : null,
    };
  }

  async changePassword(userId: string | undefined, dto: ChangePasswordDto) {
    let user = null;

    if (userId) {
      user = await this.prisma.user.findUnique({
        where: { id: userId },
      });
    } else {
      const rawId = (dto.identifier || '').trim();
      const phoneDigits = rawId.replace(/\D/g, '');

      if (rawId.length > 0) {
        user = await this.prisma.user.findFirst({
          where: {
            OR: [
              { email: { equals: rawId, mode: 'insensitive' } },
              ...(phoneDigits.length >= 7 ? [{ phone: { contains: phoneDigits.slice(-10) } }] : []),
            ],
          },
        });
      }

      // If no identifier specified or not found yet, default to the primary admin owner
      if (!user) {
        user = await this.prisma.user.findFirst({
          where: {
            OR: [
              { phone: { contains: '9415919277' } },
              { email: 'owner@chintamani.com' },
              { role: 'OWNER' },
            ],
          },
        });
      }
    }

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    let isOldPasswordValid = false;
    try {
      isOldPasswordValid = await bcrypt.compare(dto.oldPassword, user.password);
    } catch (_) {}

    if (!isOldPasswordValid) {
      throw new UnauthorizedException('Current password does not match');
    }

    const hashedNewPassword = await bcrypt.hash(dto.newPassword, 10);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { password: hashedNewPassword },
    });

    return {
      message: 'Password changed successfully',
      success: true,
    };
  }
}

