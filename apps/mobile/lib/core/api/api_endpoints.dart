class ApiEndpoints {
  /// Production cloud backend URL.
  /// Once Railway is deployed, update this to the Railway URL.
  /// Format: https://YOUR_APP_NAME.up.railway.app
  static const String productionUrl = 'https://chintamani-backend.up.railway.app';

  /// Development / local URL (only for developer testing on local machine)
  static const String developmentUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String developmentUrl = 'http://192.168.1.35:3000'; // LAN dev

  /// Active base URL — switch to productionUrl for releases
  static String baseUrl = productionUrl;

  // ── Authentication ──────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ── Core ────────────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String health = '/health';

  // ── Members ─────────────────────────────────────────────────────────────────
  static const String members = '/members';

  // ── Plans ───────────────────────────────────────────────────────────────────
  static const String plans = '/plans';

  // ── Seats ───────────────────────────────────────────────────────────────────
  static const String seats = '/seats';

  // ── Lockers ─────────────────────────────────────────────────────────────────
  static const String lockers = '/lockers';

  // ── Attendance ──────────────────────────────────────────────────────────────
  static const String attendance = '/attendance';

  // ── Payments ────────────────────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String paymentVerifications = '/payments/verifications';

  // ── Expenses ────────────────────────────────────────────────────────────────
  static const String expenses = '/expenses';

  // ── Enquiries ───────────────────────────────────────────────────────────────
  static const String enquiries = '/enquiries';

  // ── Reports ─────────────────────────────────────────────────────────────────
  static const String reports = '/reports';

  // ── Notifications ───────────────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── Communication ───────────────────────────────────────────────────────────
  static const String communication = '/communication';

  // ── QR ──────────────────────────────────────────────────────────────────────
  static const String qr = '/qr';
  static const String portalQr = '/qr/portal';

  // ── Search ──────────────────────────────────────────────────────────────────
  static const String search = '/search';

  // ── Branches ────────────────────────────────────────────────────────────────
  static const String branches = '/branches';

  // ── Users / Admins ──────────────────────────────────────────────────────────
  static const String users = '/users';

  // ── Registrations ───────────────────────────────────────────────────────────
  static const String registrations = '/registrations';

  // ── Complaints ──────────────────────────────────────────────────────────────
  static const String complaints = '/complaints';

  // ── Upload ──────────────────────────────────────────────────────────────────
  static const String uploadPhoto = '/upload/profile-photo';
  static const String uploadDocument = '/upload/document';
  static const String uploadPaymentScreenshot = '/upload/payment-screenshot';
}
