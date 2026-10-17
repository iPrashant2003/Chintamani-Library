import json, re

data = {
  "version": "2.8.6",
  "buildNumber": 2086,
  "minimumSupportedVersion": "2.3.0",
  "releaseDate": "18 Oct 2026",
  "title": "Chintamani Library v2.8.6 — Live Quote Animation & Clean Universal Portal",
  "releaseNotes": [
    "LOADING PAGE: Added luxury live specular shimmer sweep and breathing glow animation to \"Where Silence Meets Ambition • Infinity Under A Roof\"",
    "UNIVERSAL PORTAL: Completely removed the AI chatbot from the public member portal web interface",
    "APP STABILITY: All prior update loop and authentication fixes preserved"
  ],
  "apkUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/download/v2.8.6/Chintamani-Library-Release.apk",
  "arm64ApkUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/download/v2.8.6/Chintamani-Library-arm64.apk",
  "fallbackUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/latest",
  "forceUpdate": False
}

for path in ["version.json", "apps/backend/public/version.json", "apps/mobile/web/version.json"]:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print("Updated:", path)

# Update pubspec.yaml
with open("apps/mobile/pubspec.yaml", "r", encoding="utf-8") as f:
    pub = f.read()
pub = re.sub(r"^version: .+$", "version: 2.8.6+2086", pub, flags=re.MULTILINE)
with open("apps/mobile/pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(pub)
print("Updated pubspec.yaml to 2.8.6+2086")

# Update app_update_service.dart
path_svc = "apps/mobile/lib/core/services/app_update_service.dart"
with open(path_svc, "r", encoding="utf-8") as f:
    svc = f.read()
svc = re.sub(r"static const currentVersion = '.*?';", "static const currentVersion = '2.8.6';", svc)
svc = re.sub(r"static const currentBuildNumber = \d+;", "static const currentBuildNumber = 2086;", svc)
with open(path_svc, "w", encoding="utf-8") as f:
    f.write(svc)
print("Updated app_update_service.dart to 2.8.6+2086")
