import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_backup_service.dart';

class AppUpdateInfo {
  final String version;
  final int buildNumber;
  final String releaseDate;
  final String title;
  final List<String> releaseNotes;
  final String apkUrl;
  final String fallbackUrl;
  final bool forceUpdate;

  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.title,
    required this.releaseNotes,
    required this.apkUrl,
    required this.fallbackUrl,
    this.forceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String? ?? '2.3.0',
      buildNumber: (json['buildNumber'] as num?)?.toInt() ?? 17,
      releaseDate: json['releaseDate'] as String? ?? '',
      title: json['title'] as String? ?? 'New Update Available',
      releaseNotes: (json['releaseNotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      apkUrl: json['apkUrl'] as String? ?? '',
      fallbackUrl: json['fallbackUrl'] as String? ?? '',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
    );
  }
}

class AppUpdateService {
  static const currentVersion = '2.3.0';
  static const currentBuildNumber = 25;
  static const _platformChannel = MethodChannel('com.chintamani.library/app_updater');

  static const _defaultManifestUrl =
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json';
  static const _settingAutoCheckKey = 'app_update_auto_check';
  static const _settingManifestUrlKey = 'app_update_manifest_url';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 45),
  ));

  // ── Settings persistence ──────────────────────────────────────────────────
  Future<bool> isAutoCheckEnabled() async {
    try {
      final data = await DatabaseBackupService.instance.readDatabase();
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      return settings[_settingAutoCheckKey] as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setAutoCheckEnabled(bool enabled) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
      settings[_settingAutoCheckKey] = enabled;
      data['settings'] = settings;
      await db.writeDatabase(data);
    } catch (_) {}
  }

  Future<String> getManifestUrl() async {
    try {
      final data = await DatabaseBackupService.instance.readDatabase();
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      return settings[_settingManifestUrlKey] as String? ?? _defaultManifestUrl;
    } catch (_) {
      return _defaultManifestUrl;
    }
  }

  Future<void> setManifestUrl(String url) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
      settings[_settingManifestUrlKey] = url;
      data['settings'] = settings;
      await db.writeDatabase(data);
    } catch (_) {}
  }

  // ── Check for update with intelligent multi-host resolution ──────────────
  Future<AppUpdateInfo?> checkForUpdate() async {
    final savedUrl = await getManifestUrl();
    // Cache-bust the GitHub URL so CDN always serves fresh content
    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    final candidateUrls = <String>[
      // 1. Primary Global Cloud URL with cache-bust (always fresh)
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json?t=$cacheBust',
      // 2. Primary without cache-bust (fallback)
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json',
      // 3. Custom URL configured in Settings (if valid)
      if (savedUrl.isNotEmpty &&
          !savedUrl.contains('172.21.232.210') &&
          savedUrl != _defaultManifestUrl)
        savedUrl,
    ];

    for (final url in candidateUrls) {
      try {
        final response = await _dio.get(
          url,
          options: Options(
            responseType: ResponseType.plain, // Always get raw text, parse manually
            headers: {
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          Map<String, dynamic> json;
          if (response.data is Map) {
            json = Map<String, dynamic>.from(response.data as Map);
          } else {
            // Force parse as JSON string (handles Dio returning String for plain text)
            final decoded = jsonDecode(response.data.toString());
            if (decoded is! Map) continue;
            json = Map<String, dynamic>.from(decoded);
          }
          final info = AppUpdateInfo.fromJson(json);
          debugPrint('[UpdateService] Remote build: ${info.buildNumber}, Local: $currentBuildNumber');
          if (info.buildNumber > currentBuildNumber) {
            return info;
          }
          // No update needed — stop trying further URLs
          return null;
        }
      } catch (e) {
        debugPrint('[UpdateService] Failed: $url — $e');
        // Continue trying next candidate
      }
    }
    return null;
  }

  // ── In-App Download & Native Install ──────────────────────────────────────
  Future<bool> downloadAndInstall({
    required AppUpdateInfo info,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    // If Web platform, redirect to fallback URL
    if (kIsWeb) {
      if (info.fallbackUrl.isNotEmpty) {
        final uri = Uri.parse(info.fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      return false;
    }

    try {
      // Save in cache directory (maps to cache-path in FileProvider)
      final dir = await getTemporaryDirectory();
      final apkFile = File('${dir.path}/Chintamani_Update_v${info.version}.apk');

      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      // Build candidate download URLs (Cloud primary, followed by local fallbacks)
      final downloadCandidates = <String>{
        if (info.apkUrl.isNotEmpty) info.apkUrl,
        'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-Release.apk',
        'http://192.168.1.35:8090/Chintamani-Library-Release.apk',
        'http://localhost:8090/Chintamani-Library-Release.apk',
        if (info.fallbackUrl.isNotEmpty && info.fallbackUrl.endsWith('.apk')) info.fallbackUrl,
      };

      bool downloaded = false;
      for (final downloadUrl in downloadCandidates) {
        try {
          await _dio.download(
            downloadUrl,
            apkFile.path,
            onReceiveProgress: (received, total) {
              if (total > 0) {
                final p = received / total;
                onProgress(p.clamp(0.0, 1.0), received, total);
              }
            },
          );

          if (await apkFile.exists() && await apkFile.length() > 5000000) {
            downloaded = true;
            break;
          }
        } catch (_) {
          // Try next download URL
        }
      }

      if (!downloaded) {
        throw Exception('Could not download APK from any endpoint.');
      }

      // Invoke Android Package Installer via MethodChannel
      final success = await _platformChannel.invokeMethod<bool>(
        'installApk',
        {'filePath': apkFile.path},
      );

      return success ?? false;
    } catch (e) {
      debugPrint('In-app update install failed: $e');

      // Fallback: Open browser download URL
      if (info.fallbackUrl.isNotEmpty) {
        final uri = Uri.parse(info.fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      return false;
    }
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

final isAppUpdateAutoCheckProvider = FutureProvider<bool>((ref) async {
  return ref.read(appUpdateServiceProvider).isAutoCheckEnabled();
});
