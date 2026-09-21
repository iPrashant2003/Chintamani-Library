import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterTenantDto } from './dto/register-tenant.dto';
import { UpdateTenantDto } from './dto/update-tenant.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class TenantsService {
  constructor(private readonly prisma: PrismaService) {}

  async register(dto: RegisterTenantDto) {
    const upperCode = dto.code.trim().toUpperCase();

    // Check code collision
    const existingTenant = await this.prisma.tenant.findUnique({
      where: { code: upperCode },
    });
    if (existingTenant) {
      throw new ConflictException(`Library code '${upperCode}' is already registered.`);
    }

    // Check email collision
    const existingUser = await this.prisma.user.findUnique({
      where: { email: dto.ownerEmail.toLowerCase().trim() },
    });
    if (existingUser) {
      throw new ConflictException(`User with email '${dto.ownerEmail}' already exists.`);
    }

    const slug = dto.name
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');

    const passwordHash = await bcrypt.hash(dto.ownerPassword, 12);

    return this.prisma.$transaction(async (tx) => {
      // 1. Create Tenant
      const tenant = await tx.tenant.create({
        data: {
          name: dto.name.trim(),
          code: upperCode,
          slug: `${slug}-${Date.now().toString(36)}`,
          phone: dto.phone || null,
          email: dto.ownerEmail.toLowerCase().trim(),
          address: dto.address || null,
          city: dto.city || null,
          state: dto.state || null,
          country: 'India',
          plan: 'STANDARD',
          status: 'ACTIVE',
        },
      });

      // 2. Create Default Main Branch
      const branch = await tx.branch.create({
        data: {
          tenantId: tenant.id,
          name: `${dto.name.trim()} – Main Branch`,
          address: dto.address || null,
          phone: dto.phone || null,
        },
      });

      // 3. Create Owner User
      const owner = await tx.user.create({
        data: {
          tenantId: tenant.id,
          name: dto.ownerName.trim(),
          email: dto.ownerEmail.toLowerCase().trim(),
          password: passwordHash,
          role: 'OWNER',
          phone: dto.phone || null,
        },
      });

      // 4. Assign Owner to Branch
      await tx.userBranchAccess.create({
        data: {
          userId: owner.id,
          branchId: branch.id,
        },
      });

      // 5. Create Default Membership Plans
      const defaultPlans = [
        { name: 'Daily Pass', durationDays: 1, price: 80, includesSeat: true, includesLocker: false },
        { name: 'Monthly Standard', durationDays: 30, price: 600, includesSeat: true, includesLocker: false },
        { name: 'Quarterly Pro', durationDays: 90, price: 1700, includesSeat: true, includesLocker: true },
        { name: 'Half-Yearly Prime', durationDays: 180, price: 3200, includesSeat: true, includesLocker: true },
        { name: 'Yearly Elite', durationDays: 365, price: 6000, includesSeat: true, includesLocker: true },
      ];

      for (const p of defaultPlans) {
        await tx.membershipPlan.create({
          data: {
            tenantId: tenant.id,
            branchId: branch.id,
            name: p.name,
            durationDays: p.durationDays,
            price: p.price,
            includesSeat: p.includesSeat,
            includesLocker: p.includesLocker,
          },
        });
      }

      // 6. Create Default Settings
      await tx.settings.create({
        data: {
          tenantId: tenant.id,
          branchId: branch.id,
          key: 'library_timing',
          value: JSON.stringify({ open: '06:00', close: '23:00' }),
        },
      });
      await tx.settings.create({
        data: {
          tenantId: tenant.id,
          branchId: branch.id,
          key: 'currency',
          value: JSON.stringify({ symbol: '₹', code: 'INR' }),
        },
      });

      return {
        tenant: {
          id: tenant.id,
          name: tenant.name,
          code: tenant.code,
          slug: tenant.slug,
          plan: tenant.plan,
        },
        branch: {
          id: branch.id,
          name: branch.name,
        },
        owner: {
          id: owner.id,
          name: owner.name,
          email: owner.email,
          role: owner.role,
        },
      };
    });
  }

  async findByCode(code: string) {
    const upperCode = code.trim().toUpperCase();
    const tenant = await this.prisma.tenant.findUnique({
      where: { code: upperCode },
      include: {
        branches: {
          select: { id: true, name: true, phone: true, address: true },
        },
      },
    });

    if (!tenant) {
      throw new NotFoundException(`No library found with code '${upperCode}'`);
    }

    return {
      id: tenant.id,
      name: tenant.name,
      code: tenant.code,
      slug: tenant.slug,
      logo: tenant.logo,
      city: tenant.city,
      state: tenant.state,
      branches: tenant.branches,
    };
  }

  async getProfile(tenantId: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      include: {
        branches: true,
      },
    });

    if (!tenant) {
      throw new NotFoundException('Tenant not found');
    }

    return tenant;
  }

  async updateProfile(tenantId: string, dto: UpdateTenantDto) {
    return this.prisma.tenant.update({
      where: { id: tenantId },
      data: {
        name: dto.name?.trim(),
        phone: dto.phone,
        address: dto.address,
        city: dto.city,
        state: dto.state,
      },
    });
  }

  async findAll() {
    const tenants = await this.prisma.tenant.findMany({
      include: {
        _count: {
          select: {
            branches: true,
            members: true,
            users: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return { data: tenants, total: tenants.length };
  }
}
