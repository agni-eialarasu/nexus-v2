/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// App name displayed in UI.
  static const String appName = 'Nexus';

  /// App version (synced with pubspec.yaml).
  static const String appVersion = '0.1.0';

  /// Minimum password length for registration.
  static const int minPasswordLength = 8;

  /// Default page size for paginated lists.
  static const int defaultPageSize = 25;

  /// Debounce duration for search inputs.
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
