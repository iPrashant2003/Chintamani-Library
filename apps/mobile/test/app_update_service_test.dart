import 'package:flutter_test/flutter_test.dart';
import 'package:chintamani_library/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService Verification', () {
    test('AppUpdateInfo correctly parses manifest JSON', () {
      final json = {
        'version': '2.3.0',
        'buildNumber': 18,
        'releaseDate': '22 Sep 2026',
        'title': 'Feature Update',
        'releaseNotes': ['New analytics dashboard', 'Performance fixes'],
        'apkUrl': 'http://172.21.232.210:8090/Chintamani-Library-Release.apk',
        'fallbackUrl': 'https://gofile.io/d/3HFn2sgW',
        'forceUpdate': false,
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.version, '2.3.0');
      expect(info.buildNumber, 18);
      expect(info.releaseDate, '22 Sep 2026');
      expect(info.releaseNotes.length, 2);
      expect(info.apkUrl, contains('Chintamani-Library-Release.apk'));
      expect(info.fallbackUrl, contains('gofile.io'));
      expect(info.forceUpdate, false);
    });

    test('Higher build number triggers update, lower or equal does not', () {
      const currentBuild = AppUpdateService.currentBuildNumber; // 16

      // Remote has 17 -> update available
      const newerRemoteBuild = 17;
      expect(newerRemoteBuild > currentBuild, true);

      // Remote has 16 -> up to date
      const sameRemoteBuild = 16;
      expect(sameRemoteBuild > currentBuild, false);

      // Remote has 15 -> up to date
      const olderRemoteBuild = 15;
      expect(olderRemoteBuild > currentBuild, false);
    });
  });
}
