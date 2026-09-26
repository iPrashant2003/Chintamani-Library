import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routing/route_names.dart';
import '../../features/branch/providers/branch_provider.dart';
import '../../features/branch/domain/branch_model.dart';
import '../../features/notifications/data/notifications_repository.dart';
import 'database_backup_service.dart';

/// Service to display native Android system notifications (status bar / lockscreen)
/// with real server-side identity tracking, deduplication, branch awareness, and tap routing.
class SystemNotificationService {
  SystemNotificationService._();
  static final SystemNotificationService instance = SystemNotificationService._();

  static const MethodChannel _platformChannel =
      MethodChannel('com.chintamani.library/app_updater');

  static const String _processedNotifsKey = 'processed_notification_ids';
  static bool _routingInitialized = false;

  /// Request notification permission on Android 13+ (API 33+)
  Future<bool> requestPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      final res = await _platformChannel.invokeMethod<bool>('requestNotificationPermission');
      return res ?? true;
    } catch (e) {
      debugPrint('[SystemNotificationService] requestPermission error: $e');
      return false;
    }
  }

  /// Read the set of notification IDs that have already been displayed
  Future<Set<String>> getProcessedNotificationIds() async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final list = (data[_processedNotifsKey] as List<dynamic>?) ?? [];
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Mark a notification ID as permanently processed across app launches
  Future<void> markNotificationProcessed(String id) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final list = (data[_processedNotifsKey] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      if (!list.contains(id)) {
        list.add(id);
        // Retain last 300 IDs to prevent unbounded database growth
        if (list.length > 300) {
          list.removeRange(0, list.length - 300);
        }
        data[_processedNotifsKey] = list;
        await db.writeDatabase(data);
      }
    } catch (_) {}
  }

  /// Show a native system notification with vibration and high priority
  Future<bool> showNotification({
    required String title,
    required String body,
    int? id,
    String? route,
    String? branch,
    String? type,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[SystemNotificationService] Non-Android or Web: $title - $body');
      return false;
    }

    try {
      final notifId = id ?? (DateTime.now().millisecondsSinceEpoch % 100000);
      final res = await _platformChannel.invokeMethod<bool>('showNotification', {
        'title': title,
        'body': body,
        'id': notifId,
        'route': route,
        'branch': branch,
        'type': type,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('[SystemNotificationService] showNotification error: $e');
      return false;
    }
  }

  /// Synchronize server notifications. Compares notification IDs against
  /// locally-tracked processed IDs to ensure ONLY genuinely new events are alerted.
  Future<void> syncServerNotifications(WidgetRef ref) async {
    try {
      final repo = ref.read(notificationsRepositoryProvider);
      final notifications = await repo.getNotifications();
      if (notifications.isEmpty) return;

      final processedIds = await getProcessedNotificationIds();

      for (final notif in notifications) {
        // Skip mock or empty IDs
        if (notif.id.isEmpty || notif.id.startsWith('notif-')) continue;

        // Deduplication: NEVER replay a notification that was already processed
        if (processedIds.contains(notif.id)) continue;

        // Resolve branch from title/body (e.g. "[Mehdawal]" or "[Khalilabad]")
        String? branch;
        final combined = '${notif.title} ${notif.body}'.toLowerCase();
        if (combined.contains('mehda')) {
          branch = 'mehdawal';
        } else if (combined.contains('khalil')) {
          branch = 'khalilabad';
        }

        // Map notification type to route
        final route = _resolveRouteForType(notif.type);

        await showNotification(
          id: notif.id.hashCode.abs() % 100000,
          title: notif.title,
          body: notif.body,
          route: route,
          branch: branch,
          type: notif.type,
        );

        // Mark as permanently processed so it is NEVER shown again on app restart
        await markNotificationProcessed(notif.id);
      }
    } catch (e) {
      debugPrint('[SystemNotificationService] syncServerNotifications error: $e');
    }
  }

  /// Resolve app destination route from notification event type
  String _resolveRouteForType(String type) {
    switch (type.toUpperCase()) {
      case 'NEW_REGISTRATION':
        return RouteNames.registrations;
      case 'PAYMENT_VERIFICATION':
        return RouteNames.paymentVerifications;
      case 'NEW_COMPLAINT':
      case 'COMPLAINT':
        return RouteNames.complaints;
      case 'ATTENDANCE':
        return RouteNames.universalQr;
      case 'APP_UPDATE':
      case 'UPDATE':
        return RouteNames.appUpdates;
      case 'ENQUIRY':
        return RouteNames.enquiries;
      default:
        return RouteNames.notifications;
    }
  }

  /// Initialize tap routing: listens for notification clicks and navigates to the screen
  void initNotificationRouting(WidgetRef ref) {
    if (_routingInitialized) return;
    _routingInitialized = true;

    _platformChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationTap') {
        final data = call.arguments as Map<dynamic, dynamic>?;
        if (data != null) {
          final route = data['route'] as String?;
          final branch = data['branch'] as String?;
          _handleNotificationRouting(ref, route, branch);
        }
      }
    });

    // Also check if app was opened directly from a notification when terminated
    _checkInitialNotification(ref);
  }

  Future<void> _checkInitialNotification(WidgetRef ref) async {
    try {
      final initial = await _platformChannel.invokeMethod<Map>('getInitialNotificationPayload');
      if (initial != null) {
        final route = initial['route'] as String?;
        final branch = initial['branch'] as String?;
        _handleNotificationRouting(ref, route, branch);
      }
    } catch (_) {}
  }

  void _handleNotificationRouting(WidgetRef ref, String? route, String? branch) {
    if (branch != null) {
      final bLower = branch.toLowerCase();
      if (bLower.contains('mehda')) {
        ref.read(activeBranchProvider.notifier).state = Branch.mehdawalBranch;
      } else if (bLower.contains('khalil')) {
        ref.read(activeBranchProvider.notifier).state = Branch.khalilabadBranch;
      }
    }

    if (route != null && route.isNotEmpty) {
      debugPrint('[SystemNotificationService] Routing to: $route (branch: $branch)');
    }
  }

  /// Trigger notification for an available app update (deduplicated by version)
  Future<void> notifyUpdateAvailable({
    required String version,
    required String title,
  }) async {
    final key = 'update_$version';
    final processed = await getProcessedNotificationIds();
    if (processed.contains(key)) return;
    await markNotificationProcessed(key);

    await showNotification(
      id: 2001,
      title: '🚀 New Update Available (v$version)',
      body: '$title. Tap to update Chintamani Library.',
      route: RouteNames.appUpdates,
      type: 'APP_UPDATE',
    );
  }
}
