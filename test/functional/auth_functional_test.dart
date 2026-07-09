import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/storage/local_storage.dart';
import 'package:sorak_flutter_mamnon/modules/auth/providers/auth_provider.dart';
import 'package:sorak_flutter_mamnon/modules/auth/screens/login_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('Authentication functional test', () {
    testWidgets('shows login form when no session is saved', (tester) async {
      await tester.pumpSorakApp();

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('login success opens home and saves session', (tester) async {
      final localStorage = await tester.pumpSorakApp();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Sorak Mam Non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(localStorage.getToken(), 'demo-token-admin');
      expect(localStorage.getEmail(), 'admin@sorak.edu.vn');
      expect(localStorage.getRole(), 'PRINCIPAL');
    });

    testWidgets('login fail stays on login and stores error', (tester) async {
      await tester.pumpSorakApp();

      await tester.enterText(
        find.byType(TextField).at(0),
        'wrong@sorak.edu.vn',
      );
      await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));

      final authProvider = tester
          .element(find.byType(LoginScreen))
          .read<AuthProvider>();

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Welcome, Principal Admin'), findsNothing);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, 'Incorrect username or password');
    });

    testWidgets('saved session opens home directly', (tester) async {
      await tester.pumpLoggedInSorakApp();

      expect(find.text('Sorak Mam Non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(find.text('Role: PRINCIPAL'), findsOneWidget);
    });

    testWidgets('logout clears session and returns to login', (tester) async {
      final localStorage = await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byIcon(Icons.power_settings_new));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      _expectSessionCleared(localStorage);
    });
  });
}

void _expectSessionCleared(LocalStorage localStorage) {
  expect(localStorage.getToken(), isNull);
  expect(localStorage.getUserId(), isNull);
  expect(localStorage.getFullName(), isNull);
  expect(localStorage.getEmail(), isNull);
  expect(localStorage.getRole(), isNull);
}
