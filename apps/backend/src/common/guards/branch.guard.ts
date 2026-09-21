import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

@Injectable()
export class BranchGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    
    if (!user) return false;
    if (user.role === 'OWNER') return true;

    const branchId = request.params.branchId || request.query.branchId || request.body.branchId;
    
    if (!branchId) {
      return true; // No branchId specified, allow access (or could be strict and deny)
    }

    const hasAccess = user.branchIds?.includes(branchId);
    if (!hasAccess) {
      throw new ForbiddenException('You do not have access to this branch');
    }

    return true;
  }
}
