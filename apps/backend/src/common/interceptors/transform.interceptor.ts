import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  data: T;
  statusCode: number;
  message: string;
  total?: number;
  page?: number;
  limit?: number;
}

@Injectable()
export class TransformInterceptor<T> implements NestInterceptor<T, any> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const statusCode = context.switchToHttp().getResponse().statusCode;
    return next.handle().pipe(
      map(data => {
        // Preserve pagination metadata if present
        if (data && typeof data === 'object' && 'total' in data && Array.isArray(data.data)) {
          return {
            data: data.data,
            total: data.total,
            page: data.page,
            limit: data.limit,
            statusCode,
            message: data.message || 'Success',
          };
        }

        return {
          data: data?.data !== undefined ? data.data : data,
          statusCode,
          message: data?.message || 'Success',
        };
      }),
    );
  }
}
