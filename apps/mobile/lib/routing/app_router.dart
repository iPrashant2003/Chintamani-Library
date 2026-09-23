import '../features/photos/presentation/library_photos_screen.dart';
import '../features/maintenance/presentation/maintenance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/app_lock_screen.dart';
import '../features/shell/presentation/main_shell_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/members/presentation/members_screen.dart';
import '../features/members/presentation/member_detail_screen.dart';
import '../features/members/presentation/add_member_screen.dart';
import '../features/attendance/presentation/attendance_screen.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/payments/presentation/record_payment_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/seats/presentation/seats_screen.dart';
import '../features/lockers/presentation/lockers_screen.dart';
import '../features/plans/presentation/plans_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/enquiries/presentation/enquiries_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/communication/presentation/communication_screen.dart';
import '../features/qr_code/presentation/qr_hub_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/change_password_screen.dart';
import '../features/settings/presentation/app_updates_screen.dart';
import '../features/branch/presentation/branch_comparison_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/more/presentation/about_chintamani_screen.dart';
import '../features/more/presentation/contact_chintamani_screen.dart';
import '../features/settings/presentation/database_backup_screen.dart';
import '../features/whatsapp/presentation/whatsapp_screen.dart';
import '../features/registrations/presentation/registrations_screen.dart';
import '../features/registrations/presentation/registration_detail_screen.dart';
import '../features/complaints/presentation/complaints_screen.dart';
import '../features/complaints/presentation/complaint_detail_screen.dart';
import '../features/payments/presentation/payment_verifications_screen.dart';
import '../features/qr_code/presentation/universal_qr_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider).value;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuth = authState is AuthAuthenticated;
      final path = state.uri.toString();
      final isSplash = path == RouteNames.splash;
      final isAppLock = path == RouteNames.appLock;
      final isAuthScreen = path == RouteNames.login ||
          path == RouteNames.forgotPassword ||
          path == RouteNames.signUp;

      // Always let splash and app lock pass through
      if (isSplash || isAppLock) return null;

      // Unauthenticated: redirect to login if hitting a protected route
      if (!isAuth && !isAuthScreen) return RouteNames.login;

      // Authenticated: bounce away from login/signup to dashboard
      if (isAuth && isAuthScreen) return RouteNames.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.appLock,
        builder: (context, state) => const AppLockScreen(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 5-Tab Stateful Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Members
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.members,
                builder: (context, state) => const MembersScreen(),
              ),
            ],
          ),
          // Branch 2: Seats
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.seats,
                builder: (context, state) => const SeatsScreen(),
              ),
            ],
          ),
          // Branch 3: WhatsApp Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.whatsapp,
                builder: (context, state) => const WhatsAppScreen(),
              ),
            ],
          ),
          // Branch 4: More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),

      // Sub-screens outside bottom nav
      GoRoute(
        path: RouteNames.addMember,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddMemberScreen(),
      ),
      GoRoute(
        path: RouteNames.attendance,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: RouteNames.memberDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MemberDetailScreen(memberId: id);
        },
      ),
      GoRoute(
        path: RouteNames.recordPayment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecordPaymentScreen(),
      ),
      GoRoute(
        path: RouteNames.duePayments,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: RouteNames.payments,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: RouteNames.lockers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LockersScreen(),
      ),
      GoRoute(
        path: RouteNames.plans,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: RouteNames.expenses,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: RouteNames.enquiries,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EnquiriesScreen(),
      ),
      GoRoute(
        path: RouteNames.reports,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: RouteNames.communication,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CommunicationScreen(),
      ),
      GoRoute(
        path: RouteNames.qr,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QrHubScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RouteNames.photos,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LibraryPhotosScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.appUpdates,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppUpdatesScreen(),
      ),

      GoRoute(
        path: RouteNames.branchComparison,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BranchComparisonScreen(),
      ),
      GoRoute(
        path: RouteNames.insights,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: RouteNames.about,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutChintaManiScreen(),
      ),
      GoRoute(
        path: RouteNames.contact,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ContactChintaManiScreen(),
      ),
      GoRoute(
        path: RouteNames.maintenance,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: RouteNames.databaseBackup,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DatabaseBackupScreen(),
      ),
      GoRoute(
        path: RouteNames.registrations,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegistrationsScreen(),
      ),
      GoRoute(
        path: RouteNames.registrationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RegistrationDetailScreen(
          registrationId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.complaints,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ComplaintsScreen(),
      ),
      GoRoute(
        path: RouteNames.complaintDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ComplaintDetailScreen(
          complaintId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.paymentVerifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentVerificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.universalQr,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UniversalQrScreen(),
      ),
    ],
  );
});
