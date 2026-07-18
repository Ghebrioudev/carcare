class AppConfig {
  /// Base URL for the Laravel API (includes `/api` prefix).
  ///
  /// Platform defaults:
  /// - Android emulator: `http://10.0.2.2:8000/api`
  /// - iOS simulator:    `http://127.0.0.1:8000/api`
  /// - Physical device:  `http://YOUR_PC_IP:8000/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.70:8000/api',
  );

  static const String appName = 'CarCare';
}
