import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_backup_service.dart';
import 'system_notification_service.dart';

class AppUpdateInfo {
  final String version;
  final int buildNumber;
  final String releaseDate;
  final String title;
  final List<String> releaseNotes;
  final String apkUrl;
  final String? arm64ApkUrl;
  final String fallbackUrl;
  final bool forceUpdate;

  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.title,
    required this.releaseNotes,
    required this.apkUrl,
    this.arm64ApkUrl,
    required this.fallbackUrl,
    this.forceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String? ?? '2.3.1',
      buildNumber: (json['buildNumber'] as num?)?.toInt() ?? 2035,
      releaseDate: json['releaseDate'] as String? ?? '',
      title: json['title'] as String? ?? 'New Update Available',
      releaseNotes: (json['releaseNotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      apkUrl: json['apkUrl'] as String? ?? '',
      arm64ApkUrl: json['arm64ApkUrl'] as String?,
      fallbackUrl: json['fallbackUrl'] as String? ?? '',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
    );
  }
}

class AppUpdateService {
  static const currentVersion = '2.4.3';
  static const currentBuildNumber = 2043;
  static const _platformChannel = MethodChannel('com.chintamani.library/app_updater');

  /// The update info discovered from cloud manifest, if any.
  static AppUpdateInfo? discoveredUpdate;

  /// Tracks whether the update dialog was shown to the user in this session.
  static bool hasPromptedThisSession = false;

  static void markPrompted() {
    hasPromptedThisSession = true;
  }

  /// Query the native Android PackageManager for the real installed versionCode.
  /// Falls back to [currentBuildNumber] on any error.
  static Future<int> getInstalledBuildNumber() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final info = await _platformChannel.invokeMethod<Map>('getAppVersionInfo');
        if (info != null && info.containsKey('versionCode')) {
          final raw = info['versionCode'];
          if (raw is int) return raw;
          if (raw is num) return raw.toInt();
        }
      }
    } catch (e) {
      debugPrint('[UpdateService] getInstalledBuildNumber failed: $e');
    }
    return currentBuildNumber;
  }

  static const _defaultManifestUrl =
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json';
  static const _settingAutoCheckKey = 'app_update_auto_check';
  static const _settingManifestUrlKey = 'app_update_manifest_url';

  // Fast lightweight Dio instance for manifest checks
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    },
  ));

  // Dedicated high-speed Dio instance for large APK downloads (NO 45s cutoff!)
  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 30),
    sendTimeout: const Duration(minutes: 10),
    followRedirects: true,
    maxRedirects: 10,
    headers: {
      'User-Agent': 'ChintamaniLibraryApp-Updater',
    },
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

  // ── Device Architecture Detection ─────────────────────────────────────────
  Future<String?> getDeviceAbi() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final abi = await _platformChannel.invokeMethod<String>('getDeviceAbi');
        return abi;
      }
    } catch (_) {}
    return null;
  }

  // ── Check for update with intelligent multi-host resolution ──────────────
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    // If not forced and we already discovered an update:
    // If already prompted and not a forceUpdate, don't nag user again this session.
    if (!force && discoveredUpdate != null) {
      if (hasPromptedThisSession && !discoveredUpdate!.forceUpdate) {
        return null;
      }
      return discoveredUpdate;
    }

    // Prefer native versionCode (immune to build-config drift) over the
    // hard-coded constant — falls back to currentBuildNumber on non-Android.
    final installedBuildNumber = await AppUpdateService.getInstalledBuildNumber();

    final savedUrl = await getManifestUrl();
    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    final candidateUrls = <String>[
      'https://cdn.jsdelivr.net/gh/iPrashant2003/Chintamani-Library@main/version.json?t=$cacheBust',
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json?t=$cacheBust',
      'https://chintamani-backend.onrender.com/version.json?t=$cacheBust',
      'https://cdn.jsdelivr.net/gh/iPrashant2003/Chintamani-Library@main/version.json',
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json',
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
            responseType: ResponseType.plain,
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          Map<String, dynamic> json;
          if (response.data is Map) {
            json = Map<String, dynamic>.from(response.data as Map);
          } else {
            final decoded = jsonDecode(response.data.toString());
            if (decoded is! Map) continue;
            json = Map<String, dynamic>.from(decoded);
          }
          final info = AppUpdateInfo.fromJson(json);
          debugPrint('[UpdateService] Remote build: ${info.buildNumber}, Installed: $installedBuildNumber (constant: $currentBuildNumber)');
          if (info.buildNumber > installedBuildNumber) {
            discoveredUpdate = info;
            SystemNotificationService.instance.notifyUpdateAvailable(
              version: info.version,
              title: info.title,
            );
            return info;
          } else {
            discoveredUpdate = null;
            return null; // up to date
          }
        }
      } catch (e) {
        debugPrint('[UpdateService] Manifest check failed on $url: $e');
      }
    }
    return discoveredUpdate;
  }


  // ── In-App Download & Native Install ──────────────────────────────────────
  Future<bool> downloadAndInstall({
    required AppUpdateInfo info,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
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
      final dir = await getTemporaryDirectory();
      final apkFile = File('${dir.path}/Chintamani_Update_v${info.version}.apk');

      // Detect ABI: If arm64-v8a, prioritize the smaller 35 MB package (2.5x faster!)
      final deviceAbi = await getDeviceAbi();
      final isArm64 = deviceAbi == null || deviceAbi.contains('arm64');

      final downloadCandidates = <String>[
        // 1. If device is arm64, try arm64 build first (35 MB vs 85 MB)
        if (isArm64) ...[
          if (info.arm64ApkUrl != null && info.arm64ApkUrl!.isNotEmpty)
            info.arm64ApkUrl!,
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-arm64.apk',
        ],
        // 2. Primary release APK (Universal 85 MB)
        if (info.apkUrl.isNotEmpty) info.apkUrl,
        'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-Release.apk',
        // 3. Fallback URL if pointing to an APK
        if (info.fallbackUrl.isNotEmpty && info.fallbackUrl.endsWith('.apk')) info.fallbackUrl,
      ];

      bool downloaded = false;

      for (final downloadUrl in downloadCandidates) {
        debugPrint('[UpdateService] Attempting download from: $downloadUrl');
        try {
          final success = await _downloadFileWithResume(
            url: downloadUrl,
            targetFile: apkFile,
            onProgress: onProgress,
          );

          if (success && await apkFile.exists() && await apkFile.length() > 5000000) {
            downloaded = true;
            break;
          }
        } catch (err) {
          debugPrint('[UpdateService] Failed candidate $downloadUrl: $err');
          // Try next candidate
        }
      }

      if (!downloaded) {
        throw Exception('Could not complete download from any candidate mirror.');
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

  // ── High-Speed Resumable Stream Download Engine ───────────────────────────
  Future<bool> _downloadFileWithResume({
    required String url,
    required File targetFile,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final partFile = File('${targetFile.path}.part');
    int retryCount = 0;
    const maxRetries = 5;

    while (retryCount < maxRetries) {
      IOSink? sink;
      try {
        int existingBytes = 0;
        if (await partFile.exists()) {
          existingBytes = await partFile.length();
        }

        // Set Range header if partial download exists
        final headers = <String, dynamic>{};
        if (existingBytes > 0) {
          headers['Range'] = 'bytes=$existingBytes-';
        }

        // Resolve direct CDN storage URL (GitHub 302 -> storage CDN) so Range headers are never dropped
        String directUrl = url;
        try {
          final headRes = await _dio.head(
            url,
            options: Options(
              followRedirects: false,
              validateStatus: (s) => s != null && s < 400,
            ),
          );
          final loc = headRes.headers.value('location');
          if (loc != null && loc.isNotEmpty) {
            directUrl = loc;
          }
        } catch (_) {}

        final response = await _downloadDio.get<ResponseBody>(
          directUrl,
          options: Options(
            responseType: ResponseType.stream,
            headers: headers,
          ),
        );

        final statusCode = response.statusCode ?? 200;
        final isPartial = statusCode == 206;
        
        int totalBytes = -1;
        if (isPartial) {
          final contentRange = response.headers.value('content-range');
          if (contentRange != null && contentRange.contains('/')) {
            totalBytes = int.tryParse(contentRange.split('/').last) ?? -1;
          }
        }
        
        if (totalBytes <= 0) {
          final cl = response.headers.value('content-length');
          if (cl != null) {
            final len = int.tryParse(cl) ?? -1;
            totalBytes = isPartial ? (existingBytes + len) : len;
          }
        }

        if (!isPartial && existingBytes > 0) {
          // Server returned full file (200), reset part file
          existingBytes = 0;
          sink = partFile.openWrite(mode: FileMode.write);
        } else {
          sink = partFile.openWrite(mode: FileMode.append);
        }

        int currentReceived = existingBytes;

        await for (final chunk in response.data!.stream) {
          sink.add(chunk);
          currentReceived += chunk.length;
          if (totalBytes > 0) {
            final p = (currentReceived / totalBytes).clamp(0.0, 1.0);
            onProgress(p, currentReceived, totalBytes);
          } else {
            onProgress(0.5, currentReceived, 0);
          }
        }

        await sink.flush();
        await sink.close();
        sink = null;

        final finalPartLength = await partFile.length();
        if (totalBytes > 0 && finalPartLength < totalBytes) {
          throw Exception('Incomplete chunk stream: got $finalPartLength of $totalBytes');
        }

        if (finalPartLength > 5000000) {
          if (await targetFile.exists()) {
            await targetFile.delete();
          }
          await partFile.rename(targetFile.path);
          return true;
        } else {
          throw Exception('Downloaded file unexpectedly small ($finalPartLength bytes)');
        }
      } catch (e) {
        debugPrint('[UpdateService] Stream interrupted on attempt $retryCount: $e');
        if (sink != null) {
          try {
            await sink.flush();
            await sink.close();
          } catch (_) {}
        }
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }
        // Exponential backoff before resuming
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
    return false;
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

final isAppUpdateAutoCheckProvider = FutureProvider<bool>((ref) async {
  return ref.read(appUpdateServiceProvider).isAutoCheckEnabled();
});
