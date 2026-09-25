import 'dotenv/config';
import { execSync } from 'child_process';
import * as os from 'os';

// Auto-resolve WSL PostgreSQL IP on Windows if 127.0.0.1 is specified
if (
  os.platform() === 'win32' &&
  process.env.DATABASE_URL &&
  (process.env.DATABASE_URL.includes('127.0.0.1') || process.env.DATABASE_URL.includes('localhost'))
) {
  try {
    const wslIp = execSync('wsl hostname -I', { encoding: 'utf8', timeout: 3000 }).trim().split(/\s+/)[0];
    if (wslIp && /^(\d{1,3}\.){3}\d{1,3}$/.test(wslIp)) {
      process.env.DATABASE_URL = process.env.DATABASE_URL.replace('127.0.0.1', wslIp).replace('localhost', wslIp);
      console.log(`[Database] Auto-resolved WSL PostgreSQL on Windows: ${wslIp}:5432`);
    }
  } catch (_) {}
}

import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { ConfigService } from '@nestjs/config';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const configService = app.get(ConfigService);

  // Security
  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );

  app.enableCors({
    origin: configService.get('CORS_ORIGIN') || '*',
    credentials: true,
  });

  // Global Pipes, Filters, Interceptors
  app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalInterceptors(new TransformInterceptor());

  // Serve static assets from public folder
  const publicPath = join(process.cwd(), 'public');
  app.useStaticAssets(publicPath);

  // Serve uploaded files (photos, documents, payment screenshots)
  const uploadsPath = join(process.cwd(), 'uploads');
  app.useStaticAssets(uploadsPath, { prefix: '/uploads/' });

  // Swagger setup
  const config = new DocumentBuilder()
    .setTitle('Chintamani Library API')
    .setDescription('Library Management System API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
  console.log(`Swagger documentation: http://localhost:${port}/api/docs`);
}
bootstrap();

