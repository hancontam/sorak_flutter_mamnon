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

      expect(find.text('Sorak Mầm non'), findsOneWidget);
      expect(find.text('Phụ huynh'), findsOneWidget);
      expect(find.text('Cán bộ'), findsOneWidget);
      expect(find.text('Mã thẻ học sinh'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
    });

    testWidgets('staff login success opens principal shell and saves session', (
      tester,
    ) async {
      final localStorage = await tester.pumpSorakApp();

      await tester.tap(find.text('Cán bộ'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('staff_email_field')),
        'phanthihoa@edu.vn',
      );
      await tester.enterText(
        find.byKey(const ValueKey('staff_password_field')),
        '123456',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('nav_academic_years')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.text('Năm học'), findsWidgets);
      expect(localStorage.getEmail(), 'phanthihoa@edu.vn');
      expect(localStorage.getRole(), 'PRINCIPAL');
    });

    testWidgets('parent login success opens child report and saves session', (
      tester,
    ) async {
      final localStorage = await tester.pumpSorakApp();

      await tester.enterText(
        find.byKey(const ValueKey('parent_card_field')),
        'NMA2025.001',
      );
      await tester.enterText(
        find.byKey(const ValueKey('parent_password_field')),
        '123456',
      );

      await tester.ensureVisible(find.byKey(const ValueKey('login_button')));
      await tester.tap(find.byKey(const ValueKey('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Báo cáo của trẻ'), findsWidgets);
      expect(find.byType(NavigationBar), findsNothing);
      expect(localStorage.getEmail(), '');
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
      expect(find.byKey(const ValueKey('nav_academic_years')), findsNothing);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, contains('không đúng'));
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
      expect(find.text('Báo cáo của trẻ'), findsNothing);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, contains('không đúng'));
    });

    testWidgets('saved session opens app shell directly', (tester) async {
      await tester.pumpLoggedInSorakApp();

      expect(find.byKey(const ValueKey('nav_academic_years')), findsOneWidget);
      expect(find.byKey(const ValueKey('active_year_dropdown')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('active_year_dropdown')),
        findsOneWidget,
      );
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
