import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to display native Android system notifications (in phone status bar / lockscreen)
/// for app updates, member complaints, service requests, enquiries, and alerts.
class SystemNotificationService {
  SystemNotificationService._();
  static final SystemNotificationService instance = SystemNotificationService._();

  static const MethodChannel _platformChannel =
      MethodChannel('com.chintamani.library/app_updater');

  /// Tracks notification IDs to prevent duplicates within a session
  static final Set<String> _sentAlertKeys = {};

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

  /// Show a native system notification with vibration and high priority
  Future<bool> showNotification({
    required String title,
    required String body,
    int? id,
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
      });
      return res ?? false;
    } catch (e) {
      debugPrint('[SystemNotificationService] showNotification error: $e');
      return false;
    }
  }

  /// Trigger notification for an available app update
  Future<void> notifyUpdateAvailable({
    required String version,
    required String title,
  }) async {
    final key = 'update_$version';
    if (_sentAlertKeys.contains(key)) return;
    _sentAlertKeys.add(key);

    await showNotification(
      id: 2001,
      title: '🚀 New Update Available (v$version)',
      body: '$title. Tap to update Chintamani Library.',
    );
  }

  /// Trigger notification for a new student complaint
  Future<void> notifyComplaint({
    required String id,
    required String memberName,
    required String complaintText,
  }) async {
    final key = 'complaint_$id';
    if (_sentAlertKeys.contains(key)) return;
    _sentAlertKeys.add(key);

    await showNotification(
      id: 3000 + (_sentAlertKeys.length % 500),
      title: '⚠️ New Complaint from $memberName',
      body: complaintText.isNotEmpty ? complaintText : 'A new student complaint has been submitted.',
    );
  }

  /// Trigger notification for a service / maintenance request
  Future<void> notifyServiceRequest({
    required String id,
    required String title,
    required String details,
  }) async {
    final key = 'service_$id';
    if (_sentAlertKeys.contains(key)) return;
    _sentAlertKeys.add(key);

    await showNotification(
      id: 4000 + (_sentAlertKeys.length % 500),
      title: '🛠️ Service Request: $title',
      body: details.isNotEmpty ? details : 'New maintenance or facility ticket reported.',
    );
  }

  /// Trigger notification for a new student enquiry
  Future<void> notifyEnquiry({
    required String id,
    required String name,
    required String courseOrPhone,
  }) async {
    final key = 'enquiry_$id';
    if (_sentAlertKeys.contains(key)) return;
    _sentAlertKeys.add(key);

    await showNotification(
      id: 5000 + (_sentAlertKeys.length % 500),
      title: '📩 New Admission Enquiry: $name',
      body: courseOrPhone.isNotEmpty ? 'Details: $courseOrPhone' : 'New enquiry submitted via portal.',
    );
  }
}
