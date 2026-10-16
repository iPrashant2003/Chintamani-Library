# Firebase Cloud Messaging (FCM) Push Notification Setup Guide

This document details the configuration required to enable server-to-device push notifications for background and terminated-app states across the Chintamani Library ecosystem.

---

## 1. Why Push Notifications Require FCM for Closed Apps

Android OS enforces strict background execution limits (Doze mode and App Standby). When the app process is terminated or the phone is restarted:
- **Foreground & Resumed App**: Handled natively by `SystemNotificationService` with high-priority Android Notification Channels (`cml_alerts`), real-time polling every 20 seconds, and deduplicated notification delivery.
- **Closed / Process Terminated App**: Android requires a Google Play Services push transport mechanism (**Firebase Cloud Messaging**) to wake up the device or display a system tray notification directly from Google's servers.

---

## 2. Firebase Console Setup (Owner Action Required)

To enable push notifications when the app is completely closed:

### Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create or select a project (e.g., `chintamani-library`).

### Step 2: Register Android Application
1. Add an Android app with package name:
   ```
   com.chintamani.library
   ```
2. App nickname: `Chintamani Library`
3. Download the configuration file:
   ```
   google-services.json
   ```
4. Place this file in:
   ```
   apps/mobile/android/app/google-services.json
   ```

### Step 3: Enable Firebase Cloud Messaging
1. In Firebase Console, go to **Project Settings** > **Cloud Messaging**.
2. Enable Firebase Cloud Messaging API (V1).
3. Under **Service accounts**, click **Generate new private key** to download the JSON service account file (e.g. `firebase-service-account.json`).
4. Place this key securely on the backend server or export credentials as environment variables:
   ```env
   FIREBASE_PROJECT_ID="chintamani-library"
   FIREBASE_CLIENT_EMAIL="firebase-adminsdk-...@chintamani-library.iam.gserviceaccount.com"
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
   ```

---

## 3. Client-Side Integration in Flutter

Once `google-services.json` is placed in `apps/mobile/android/app/`:

1. In `apps/mobile/pubspec.yaml`, add:
   ```yaml
   dependencies:
     firebase_core: ^3.6.0
     firebase_messaging: ^15.1.3
   ```
2. In `apps/mobile/android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.2'
   }
   ```
3. In `apps/mobile/android/app/build.gradle` (at bottom):
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```
4. In `apps/mobile/lib/main.dart`:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
   ```

---

## 4. Current In-App Notification System (Active Now)

Even without FCM keys configured externally, the following is fully implemented and operating:

1. **Foreground Polling**: Every 20 seconds, the app queries the backend for new events (`NEW_REGISTRATION`, `PAYMENT_VERIFICATION`, `NEW_COMPLAINT`, `APP_UPDATE`).
2. **App Lifecycle Resumption**: Immediately upon opening or returning from background, the app synchronizes all pending notifications.
3. **High-Priority Native Heads-Up Notifications**: Dispatched via Android `NotificationManager` on `cml_alerts` channel with sound, vibration, and lights.
4. **Permanent Deduplication**: IDs are tracked in local storage to prevent duplicate alerts.
5. **Direct Deep-Linking**: Tapping an alert automatically switches to the relevant branch and opens the appropriate destination screen.
