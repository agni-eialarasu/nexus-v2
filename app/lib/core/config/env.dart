/// Compile-time environment configuration.
///
/// Flutter Web has no runtime dotenv; values are baked in at build time via
/// `--dart-define` (CI) or `--dart-define-from-file` (local dev). This is the
/// single source of truth for which environment a build targets and where its
/// Supabase project lives.
///
/// See docs/DEVELOPMENT.md "Environment selection" and the `app/.env.*.example`
/// templates for the values each environment expects.
library;

/// The deployment target a build was compiled for.
enum AppEnv { local, staging, production }

/// Resolved environment configuration, read from `--dart-define` values.
class Env {
  const Env._();

  /// `APP_ENV` — defaults to `local` so a bare `flutter run` works.
  static const String _rawEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  /// Supabase project URL for the current environment.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon (publishable) key. RLS enforces access; never the
  /// service-role key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Parsed [AppEnv]. Unknown values fall back to [AppEnv.local].
  static AppEnv get current => switch (_rawEnv) {
    'production' => AppEnv.production,
    'staging' => AppEnv.staging,
    _ => AppEnv.local,
  };

  static bool get isLocal => current == AppEnv.local;
  static bool get isStaging => current == AppEnv.staging;
  static bool get isProduction => current == AppEnv.production;

  /// Whether Supabase config was supplied at build time. When false, the app
  /// runs in an offline/unconfigured mode (useful before the first backend
  /// feature lands).
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Short human-readable label for banners/badges (e.g. an env indicator).
  static String get label => switch (current) {
    AppEnv.local => 'LOCAL',
    AppEnv.staging => 'STAGING',
    AppEnv.production => 'PRODUCTION',
  };
}
