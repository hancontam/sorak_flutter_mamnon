import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorak_flutter_mamnon/app.dart';
import 'package:sorak_flutter_mamnon/core/storage/local_storage.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'test_data.dart';

Future<LocalStorage> createTestLocalStorage({AuthUser? savedUser}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(preferences);
  final user = savedUser;

  if (user != null) {
    await localStorage.saveToken(user.token);
    await localStorage.saveUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
    );
  }

  return localStorage;
}

extension SorakWidgetTester on WidgetTester {
  Future<LocalStorage> pumpSorakApp({AuthUser? savedUser}) async {
    final localStorage = await createTestLocalStorage(savedUser: savedUser);

    await pumpWidget(SorakApp(localStorage: localStorage));
    await pumpAndSettle();

    return localStorage;
  }

  Future<LocalStorage> pumpLoggedInSorakApp() {
    return pumpSorakApp(savedUser: testAuthUser);
  }
}
