import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
      include: {
        branches: true,
        permissions: true,
        tenant: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
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
}
