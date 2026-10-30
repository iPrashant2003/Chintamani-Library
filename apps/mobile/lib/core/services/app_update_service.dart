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
  final String minimumSupportedVersion;
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
    this.minimumSupportedVersion = '2.5.0',
    required this.releaseDate,
    required this.title,
    required this.releaseNotes,
    required this.apkUrl,
    this.arm64ApkUrl,
    required this.fallbackUrl,
    this.forceUpdate = false,
  });

  AppUpdateInfo copyWith({
    String? version,
    int? buildNumber,
    String? minimumSupportedVersion,
    String? releaseDate,
    String? title,
    List<String>? releaseNotes,
    String? apkUrl,
    String? arm64ApkUrl,
    String? fallbackUrl,
    bool? forceUpdate,
  }) {
    return AppUpdateInfo(
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      minimumSupportedVersion: minimumSupportedVersion ?? this.minimumSupportedVersion,
      releaseDate: releaseDate ?? this.releaseDate,
      title: title ?? this.title,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      apkUrl: apkUrl ?? this.apkUrl,
      arm64ApkUrl: arm64ApkUrl ?? this.arm64ApkUrl,
      fallbackUrl: fallbackUrl ?? this.fallbackUrl,
      forceUpdate: forceUpdate ?? this.forceUpdate,
    );
  }

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String? ?? '2.5.0',
      buildNumber: (json['buildNumber'] as num?)?.toInt() ?? 2050,
      minimumSupportedVersion: json['minimumSupportedVersion'] as String? ?? '2.5.0',
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
  static const currentVersion = '2.8.21';
  static const currentBuildNumber = 2101;
  static const _platformChannel = MethodChannel('com.chintamani.library/app_updater');

  /// The update info discovered from cloud manifest, if any.
  static AppUpdateInfo? discoveredUpdate;

  /// Tracks whether the update dialog was shown to the user in this session.
  static bool hasPromptedThisSession = false;

  /// Holds the human-readable explanation if the last download/install attempt failed.
  String? lastErrorMessage;

  static void markPrompted() {
    hasPromptedThisSession = true;
  }

  /// Semantic version comparison: returns > 0 if a > b, < 0 if a < b, 0 if equal.
  /// Handles numeric comparison: "2.10.0" > "2.9.0" correctly.
  static int compareSemver(String a, String b) {
    try {
      final cleanA = a.replaceAll(RegExp(r'^[vV]'), '').split('+').first.trim();
      final cleanB = b.replaceAll(RegExp(r'^[vV]'), '').split('+').first.trim();

      final partsA = cleanA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final partsB = cleanB.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (partsA.length < 3) {
        partsA.add(0);
      }
      while (partsB.length < 3) {
        partsB.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (partsA[i] > partsB[i]) return 1;
        if (partsA[i] < partsB[i]) return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Query the native Android PackageManager for the real installed versionName.
  static Future<String> getInstalledVersionName() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final info = await _platformChannel.invokeMethod<Map>('getAppVersionInfo');
        if (info != null && info['versionName'] != null) {
          final vn = info['versionName'].toString().trim();
          if (vn.isNotEmpty) return vn;
        }
      }
    } catch (e) {
      debugPrint('[UpdateService] getInstalledVersionName failed: $e');
    }
    return currentVersion;
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
      'https://chintamani-backend.onrender.com/version.json';
  static const _settingAutoCheckKey = 'app_update_auto_check';
  static const _settingManifestUrlKey = 'app_update_manifest_url';

  // Fast lightweight Dio instance for manifest checks
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    },
  ));

  // Dedicated high-speed Dio instance for large APK downloads (NO 45s cutoff!)
  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 45), // Extended: GitHub CDN redirect can be slow on mobile
    receiveTimeout: const Duration(minutes: 30),
    sendTimeout: const Duration(minutes: 10),
    followRedirects: true,
    maxRedirects: 15,
    headers: {
      'User-Agent': 'ChintamaniLibraryApp-Updater/2.8.14',
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

    // Prefer native versionName and versionCode over hard-coded constants
    final installedBuildNumber = await AppUpdateService.getInstalledBuildNumber();
    final installedVersionName = await AppUpdateService.getInstalledVersionName();

    final savedUrl = await getManifestUrl();
    final cacheBust = DateTime.now().millisecondsSinceEpoch;
    final candidateUrls = <String>[
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json?t=$cacheBust',
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/apps/backend/public/version.json?t=$cacheBust',
      'https://chintamani-backend.onrender.com/version.json?t=$cacheBust',
      'https://raw.githubusercontent.com/iPrashant2003/Chintamani-Library/main/version.json',
      'https://chintamani-backend.onrender.com/version.json',
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

          // Strict check: only flag update if remote semver is higher,
          // or if on the same semver and remote build number is strictly higher.
          final semverDiff = compareSemver(info.version, installedVersionName);
          final hasUpdate = semverDiff > 0 || (semverDiff == 0 && info.buildNumber > installedBuildNumber);

          debugPrint('[UpdateService] Remote: v${info.version}+${info.buildNumber}, Installed: v$installedVersionName+$installedBuildNumber (hasUpdate: $hasUpdate) from $url');

          if (hasUpdate) {
            final isBelowMin = compareSemver(info.minimumSupportedVersion, installedVersionName) > 0;
            final resolvedInfo = info.copyWith(forceUpdate: info.forceUpdate || isBelowMin);

            discoveredUpdate = resolvedInfo;
            SystemNotificationService.instance.notifyUpdateAvailable(
              version: resolvedInfo.version,
              title: resolvedInfo.title,
            );
            return resolvedInfo;
          }
          // Do not return null immediately — if this mirror is stale or delayed, continue checking others!
        }
      } catch (e) {
        debugPrint('[UpdateService] Manifest check failed on $url: $e');
      }
    }
    discoveredUpdate = null;
    return null;
  }


  // ── In-App Download & Native Install ──────────────────────────────────────
  Future<bool> downloadAndInstall({
    required AppUpdateInfo info,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    lastErrorMessage = null;
    if (kIsWeb) {
      if (info.fallbackUrl.isNotEmpty) {
        final uri = Uri.parse(info.fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      lastErrorMessage = 'Update download not supported on web.';
      return false;
    }

    try {
      // Check install unknown packages permission on Android upfront
      if (Platform.isAndroid) {
        try {
          final canInstall = await _platformChannel.invokeMethod<bool>('canInstallPackages') ?? true;
          if (!canInstall) {
            await _platformChannel.invokeMethod('openInstallPermissionSetting');
            lastErrorMessage = 'Please enable "Allow from this source" in Settings, then tap Retry Update.';
            return false;
          }
        } catch (_) {}
      }

      // ALWAYS use internal cache directory (never getExternalCacheDirectories which is under /Android/data/
      // and blocked by Android 11+ Scoped Storage from system PackageInstaller).
      final dir = await getTemporaryDirectory();

      final apkFile = File('${dir.path}/Chintamani_Update_v${info.version}.apk');
      final partFile = File('${apkFile.path}.part');

      // Purge any existing partial or stale file to ensure pristine package
      if (await apkFile.exists()) {
        try { await apkFile.delete(); } catch (_) {}
      }
      if (await partFile.exists()) {
        try { await partFile.delete(); } catch (_) {}
      }

      // Detect ABI: Only prioritize arm64 if explicitly confirmed as arm64
      final deviceAbi = (await getDeviceAbi())?.toLowerCase() ?? '';
      final isArm64 = deviceAbi.contains('arm64') || deviceAbi.contains('aarch64');
      final isArmV7 = deviceAbi.contains('v7') || deviceAbi.contains('arm');
      final isX86 = deviceAbi.contains('x86') || deviceAbi.contains('amd64');

      final downloadCandidates = <String>[
        // 1. Matched architecture first
        if (isArm64) ...[
          if (info.arm64ApkUrl != null && info.arm64ApkUrl!.isNotEmpty) info.arm64ApkUrl!,
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-${info.version}-arm64.apk',
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/app-arm64-v8a-release.apk',
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-arm64.apk',
        ] else if (isArmV7) ...[
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-${info.version}-armeabi.apk',
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/app-armeabi-v7a-release.apk',
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-armeabi.apk',
        ] else if (isX86) ...[
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-${info.version}-x86_64.apk',
          'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/app-x86_64-release.apk',
        ],
        // 2. Generic fallbacks (arm64 is 99% of Android devices)
        if (info.apkUrl.isNotEmpty) info.apkUrl,
        'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/app-arm64-v8a-release.apk',
        'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/Chintamani-Library-arm64.apk',
        'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v${info.version}/app-armeabi-v7a-release.apk',
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
        lastErrorMessage = 'Could not download update file. Please verify internet and tap Retry.';
        return false;
      }

      // Invoke Android Package Installer via MethodChannel
      final success = await _platformChannel.invokeMethod<bool>(
        'installApk',
        {'filePath': apkFile.path},
      );

      if (success == true) {
        lastErrorMessage = null;
        return true;
      } else {
        lastErrorMessage = 'Package installer did not launch. Tap Retry Update.';
        return false;
      }
    } on PlatformException catch (pe) {
      debugPrint('[UpdateService] Platform error during install: ${pe.code} - ${pe.message}');
      if (pe.code == 'UNKNOWN_SOURCES_REQUIRED') {
        lastErrorMessage = 'Please enable "Allow from this source" in Settings, then tap Retry Update.';
      } else {
        lastErrorMessage = 'Installation failed: ${pe.message ?? pe.code}';
      }
      return false;
    } catch (e) {
      debugPrint('[UpdateService] In-app update download/install failed: $e');
      lastErrorMessage = 'Update failed. Check internet and tap Retry Update.';
      return false;
    }
  }

  // ── High-Speed Resumable Stream Download Engine ───────────────────────────
  Future<bool> _downloadFileWithResume({
    required String url,
    required File targetFile,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final tempPath = '${targetFile.path}.tmp';
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      try { await tempFile.delete(); } catch (_) {}
    }

    try {
      // Immediately emit 2% so UI leaves "Connecting" phase and shows progress bar
      onProgress(0.02, 0, 0);
      final response = await _downloadDio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            // Map 3%–100% so the bar never appears to go backwards from 2%
            final p = 0.03 + (received / total).clamp(0.0, 1.0) * 0.97;
            onProgress(p, received, total);
          } else {
            // Unknown size: pulse between 3%–50%
            onProgress(0.5, received, 0);
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            'Accept': '*/*',
          },
          followRedirects: true,
          maxRedirects: 15,
          receiveTimeout: const Duration(minutes: 30),
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        if (await tempFile.exists() && await tempFile.length() > 5000000) {
          if (await targetFile.exists()) {
            try { await targetFile.delete(); } catch (_) {}
          }
          try {
            await tempFile.rename(targetFile.path);
          } catch (_) {
            await tempFile.copy(targetFile.path);
            try { await tempFile.delete(); } catch (_) {}
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[UpdateService] Download failed for $url: $e');
      if (await tempFile.exists()) {
        try { await tempFile.delete(); } catch (_) {}
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
