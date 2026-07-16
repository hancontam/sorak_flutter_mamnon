import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// Live API is the app default: plain `flutter run` / Run-Debug open the
  /// deployed backend. Automated tests force mock via [forceMockApiForTests].
  /// Opt into mock for local offline work with:
  /// `--dart-define=USE_MOCK_API=true`.
  static const bool _useMockApiFromEnvironment = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static bool? _useMockApiOverride;

  static bool get useMockApi =>
      _useMockApiOverride ?? _useMockApiFromEnvironment;

  /// Default base URL for the live demo backend.
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
