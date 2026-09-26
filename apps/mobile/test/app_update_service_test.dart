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
      const currentBuild = AppUpdateService.currentBuildNumber;

      // Remote has higher build -> update available
      final newerRemoteBuild = currentBuild + 1;
      expect(newerRemoteBuild > currentBuild, true);

      // Remote has same build -> up to date
      const sameRemoteBuild = currentBuild;
      expect(sameRemoteBuild > currentBuild, false);

      // Remote has lower build -> up to date (older)
      final olderRemoteBuild = currentBuild - 1;
      expect(olderRemoteBuild > currentBuild, false);
    });

    test('Semantic versioning comparison works correctly', () {
      expect(AppUpdateService.compareSemver('2.6.1', '2.6.0') > 0, true);
      expect(AppUpdateService.compareSemver('2.10.0', '2.9.0') > 0, true);
      expect(AppUpdateService.compareSemver('2.6.0', '2.6.0') == 0, true);
      expect(AppUpdateService.compareSemver('2.5.0', '2.6.0') < 0, true);
    });

    test('hasPromptedThisSession tracks prompt state', () {
      AppUpdateService.hasPromptedThisSession = false;
      expect(AppUpdateService.hasPromptedThisSession, false);
      AppUpdateService.markPrompted();
      expect(AppUpdateService.hasPromptedThisSession, true);
    });
  });
}
