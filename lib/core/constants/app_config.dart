class AppConfig {
  const AppConfig._();

  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  // Temporary compatibility switch while repositories are migrated to the
  // shared in-memory HTTP backend. New code must not add legacy mock branches.
  static const bool useLegacyRepositoryMocks = false;

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
