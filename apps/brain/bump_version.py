import json, re, sys

data = {
  "version": "2.8.4",
  "buildNumber": 2084,
  "minimumSupportedVersion": "2.3.0",
  "releaseDate": "18 Oct 2026",
  "title": "Chintamani Library v2.8.4 — Premium AI Chatbot UI, Portal AI Assistant & QR Cleanup",
  "releaseNotes": [
    "PREMIUM AI CHATBOT: Completely redesigned with structured bold/bullet/section rendering, bouncing typing indicator, gold gradient UI, copy-on-longpress, and clear conversation button",
    "PORTAL AI ASSISTANT: ChintaMani AI now embedded in the external Member Portal for students and visitors via public endpoint",
    "STRUCTURED AI RESPONSES: All chatbot answers now use formatted sections, bullet points, and bold values for clarity",
    "QR PORTAL CLEANUP: Removed camera scanner button from Universal QR Portal screen",
    "AI SECURITY: New public /ai/chat-public endpoint for external portal; admin /ai/chat preserved with JWT guard"
  ],
  "apkUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/download/v2.8.4/Chintamani-Library-Release.apk",
  "arm64ApkUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/download/v2.8.4/Chintamani-Library-arm64.apk",
  "fallbackUrl": "https://github.com/iPrashant2003/Chintamani-Library/releases/latest",
  "forceUpdate": True
}

for path in ["version.json", "apps/backend/public/version.json", "apps/mobile/web/version.json"]:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print("Updated:", path)

# pubspec.yaml
with open("apps/mobile/pubspec.yaml", "r", encoding="utf-8") as f:
    pub = f.read()

old_ver = "version: 2.8.3+2083"
new_ver = "version: 2.8.4+2084"
if old_ver in pub:
    pub = pub.replace(old_ver, new_ver)
    with open("apps/mobile/pubspec.yaml", "w", encoding="utf-8") as f:
        f.write(pub)
    print("Updated pubspec.yaml to 2.8.4+2084")
else:
    m = re.search(r"^version: (.+)$", pub, re.MULTILINE)
    print("WARNING: Expected version not found. Current:", m.group(1) if m else "unknown")

# app_update_service.dart
path_svc = "apps/mobile/lib/core/services/app_update_service.dart"
with open(path_svc, "r", encoding="utf-8") as f:
    svc = f.read()

svc2 = svc.replace("static const currentVersion = '2.8.3';", "static const currentVersion = '2.8.4';")
svc2 = svc2.replace("static const currentBuildNumber = 2083;", "static const currentBuildNumber = 2084;")
if svc2 != svc:
    with open(path_svc, "w", encoding="utf-8") as f:
        f.write(svc2)
    print("Updated app_update_service.dart to 2.8.4+2084")
else:
    print("WARNING: app_update_service.dart version constants not found at expected values")
