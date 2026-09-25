import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { execSync } from 'child_process';
import * as os from 'os';

function getResolvedDatabaseUrl(): string | undefined {
  const envUrl = process.env.DATABASE_URL;
  if (!envUrl) return undefined;

  // On Windows, if connecting to localhost or 127.0.0.1, check if WSL has PostgreSQL
  if (os.platform() === 'win32' && (envUrl.includes('127.0.0.1') || envUrl.includes('localhost'))) {
    try {
      const wslIp = execSync('wsl hostname -I', { encoding: 'utf8', timeout: 3000 }).trim().split(/\s+/)[0];
      if (wslIp && /^(\d{1,3}\.){3}\d{1,3}$/.test(wslIp)) {
        return envUrl.replace('127.0.0.1', wslIp).replace('localhost', wslIp);
      }
    } catch (_) {}
  }
  return envUrl;
}

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    const url = getResolvedDatabaseUrl();
    super(url ? { datasources: { db: { url } } } : undefined);
    if (url && url !== process.env.DATABASE_URL) {
      this.logger.log(`Auto-resolved WSL PostgreSQL database URL: ${url.replace(/:[^:@]+@/, ':***@')}`);
    }
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
