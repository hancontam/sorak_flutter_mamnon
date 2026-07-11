import 'dart:async';

import 'package:sorak_flutter_mamnon/core/constants/app_config.dart';

/// Flutter loads this before every test file under `test/`.
/// Force mock so the suite stays offline-safe even when app defaults to live.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppConfig.forceMockApiForTests();
  await testMain();
}
