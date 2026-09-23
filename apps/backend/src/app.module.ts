import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TenantsModule } from './tenants/tenants.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { BranchesModule } from './branches/branches.module';
import { UsersModule } from './users/users.module';
import { MembersModule } from './members/members.module';
import { PlansModule } from './plans/plans.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { SeatsModule } from './seats/seats.module';
import { LockersModule } from './lockers/lockers.module';
import { PaymentsModule } from './payments/payments.module';
import { ExpensesModule } from './expenses/expenses.module';
import { EnquiriesModule } from './enquiries/enquiries.module';
import { NotificationsModule } from './notifications/notifications.module';
import { CommunicationModule } from './communication/communication.module';
import { SearchModule } from './search/search.module';
import { ReportsModule } from './reports/reports.module';
import { UploadModule } from './upload/upload.module';
import { AuditModule } from './audit/audit.module';
import { AttendanceModule } from './attendance/attendance.module';
import { QrModule } from './qr/qr.module';
import { PortalModule } from './portal/portal.module';
import { RegistrationsModule } from './registrations/registrations.module';
import { ComplaintsModule } from './complaints/complaints.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]),
    PrismaModule,
    AuthModule,
    TenantsModule,
    DashboardModule,
    BranchesModule,
    UsersModule,
    MembersModule,
    PlansModule,
    SubscriptionsModule,
    SeatsModule,
    LockersModule,
    AttendanceModule,
    PaymentsModule,
    ExpensesModule,
    EnquiriesModule,
    NotificationsModule,
    CommunicationModule,
    SearchModule,
    ReportsModule,
    UploadModule,
    AuditModule,
    QrModule,
    PortalModule,
    RegistrationsModule,
    ComplaintsModule,
  ],
})
export class AppModule {}
