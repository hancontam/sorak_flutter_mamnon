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

      expect(find.text('Sorak Mam Non'), findsOneWidget);
      expect(find.text('Phụ huynh'), findsOneWidget);
      expect(find.text('Cán bộ'), findsOneWidget);
      expect(find.text('Mã thẻ học sinh'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('staff login success opens home and saves session', (
      tester,
    ) async {
      final localStorage = await tester.pumpSorakApp();

      await tester.tap(find.text('Cán bộ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sorak Mầm non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(localStorage.getEmail(), 'admin@sorak.edu.vn');
      expect(localStorage.getRole(), 'PRINCIPAL');
    });

    testWidgets('parent login success opens parent portal and saves session', (
      tester,
    ) async {
      final localStorage = await tester.pumpSorakApp();

      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Cổng phụ huynh'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_child')), findsOneWidget);
      expect(localStorage.getEmail(), 'parent@sorak.edu.vn');
      expect(localStorage.getRole(), 'PARENT');
    });

    testWidgets('staff login fail stays on login and stores error', (
      tester,
    ) async {
      await tester.pumpSorakApp();

      await tester.tap(find.text('Cán bộ'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('staff_email_field')),
        'wrong@sorak.edu.vn',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff_password_field')),
        'wrong-password',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));

      final authProvider = tester
          .element(find.byType(LoginScreen))
          .read<AuthProvider>();

      expect(find.text('Cán bộ'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsNothing);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, 'Incorrect username or password');
    });

    testWidgets('parent login fail stays on login and stores error', (
      tester,
    ) async {
      await tester.pumpSorakApp();

      await tester.enterText(
        find.byKey(const ValueKey('parent_card_field')),
        'wrong-card',
      );
      await tester.enterText(
        find.byKey(const ValueKey('parent_password_field')),
        'wrong-password',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));

      final authProvider = tester
          .element(find.byType(LoginScreen))
          .read<AuthProvider>();

      expect(find.text('Phụ huynh'), findsOneWidget);
      expect(find.text('Child overview'), findsNothing);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, 'Incorrect student card or password');
    });

    testWidgets('saved session opens home directly', (tester) async {
      await tester.pumpLoggedInSorakApp();

      expect(find.text('Sorak Mầm non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(find.text('Role: PRINCIPAL'), findsOneWidget);
    });

    testWidgets('logout clears session and returns to login', (tester) async {
      final localStorage = await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      expect(find.text('Phụ huynh'), findsOneWidget);
      expect(find.text('Mã thẻ học sinh'), findsOneWidget);
      _expectSessionCleared(localStorage);
    });
  });
}

void _expectSessionCleared(LocalStorage localStorage) {
  expect(localStorage.getUserId(), isNull);
  expect(localStorage.getFullName(), isNull);
  expect(localStorage.getEmail(), isNull);
  expect(localStorage.getRole(), isNull);
}
