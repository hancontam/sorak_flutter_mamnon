import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// Live API is the default for `flutter run` / UI work.
  /// Automated tests force mock via [forceMockApiForTests].
  static const bool _useMockApiFromEnvironment = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static bool? _useMockApiOverride;

  static bool get useMockApi =>
      _useMockApiOverride ?? _useMockApiFromEnvironment;

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://103.69.191.210:8082/api',
  );

  /// Keeps `flutter test` on mock without requiring dart-defines on every run.
  @visibleForTesting
  static void forceMockApiForTests() {
    _useMockApiOverride = true;
  }

  /// Used by live-contract tests that pass `--dart-define=USE_MOCK_API=false`.
  @visibleForTesting
  static void clearUseMockApiOverride() {
    _useMockApiOverride = null;
  }
}
