class ApiEndpoints {
  static String baseUrl = 'http://192.168.1.35:3000'; // Active PC Wi-Fi IP
  static const String defaultWifiUrl = 'http://192.168.1.35:3000';
  static const String defaultTunnelUrl = 'https://fluffy-crabs-speak.loca.lt';

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String dashboard = '/dashboard';
  static const String members = '/members';
  static const String plans = '/plans';
  static const String seats = '/seats';
  static const String lockers = '/lockers';
  static const String attendance = '/attendance';
  static const String payments = '/payments';
  static const String expenses = '/expenses';
  static const String enquiries = '/enquiries';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String communication = '/communication';
  static const String qr = '/qr';
  static const String search = '/search';
  static const String branches = '/branches';
  static const String users = '/users';
}
