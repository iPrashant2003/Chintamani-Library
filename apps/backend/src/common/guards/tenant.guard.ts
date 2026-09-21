import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('User not authenticated');
    }

    if (user.role === 'SUPER_ADMIN') {
      return true;
    }

    if (!user.tenantId) {
      throw new ForbiddenException('User has no tenant assigned');
    }

    const requestedTenantId =
      request.params?.tenantId ||
      request.query?.tenantId ||
      request.body?.tenantId ||
      request.headers['x-tenant-id'];

    if (requestedTenantId && requestedTenantId !== user.tenantId) {
      throw new ForbiddenException('Access to requested tenant is forbidden');
    }

    return true;
  }
}
