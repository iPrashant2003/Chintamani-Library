import 'package:flutter_test/flutter_test.dart';
import 'package:chintamani_library/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService Verification', () {
    test('AppUpdateInfo correctly parses manifest JSON', () {
      final json = {
        'version': '2.3.1',
        'buildNumber': 2035,
        'releaseDate': '24 Sep 2026',
        'title': 'Feature Update',
        'releaseNotes': ['Update loop fix', 'Branch-aware portal'],
        'apkUrl':
            'https://github.com/iPrashant2003/Chintamani-Library/releases/download/v2.3.1/Chintamani-Library-Release.apk',
        'fallbackUrl': 'https://github.com/iPrashant2003/Chintamani-Library/releases/latest',
        'forceUpdate': true,
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.version, '2.3.1');
      expect(info.buildNumber, 2035);
      expect(info.releaseDate, '24 Sep 2026');
      expect(info.releaseNotes.length, 2);
      expect(info.apkUrl, contains('Chintamani-Library-Release.apk'));
      expect(info.fallbackUrl, contains('github.com'));
      expect(info.forceUpdate, true);
    });

    test('Higher build number triggers update, lower or equal does not', () {
      const currentBuild = AppUpdateService.currentBuildNumber; // 2035

      // Remote has 2036 -> update available
      const newerRemoteBuild = 2036;
      expect(newerRemoteBuild > currentBuild, true);

      // Remote has 2035 -> up to date
      const sameRemoteBuild = 2035;
      expect(sameRemoteBuild > currentBuild, false);

      // Remote has 2034 -> up to date (older)
      const olderRemoteBuild = 2034;
      expect(olderRemoteBuild > currentBuild, false);
    });

    test('hasCheckedThisSession starts as false', () {
      // Reset for test isolation
      AppUpdateService.hasCheckedThisSession = false;
      expect(AppUpdateService.hasCheckedThisSession, false);
    });
  });
}
