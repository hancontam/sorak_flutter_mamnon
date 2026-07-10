import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  group('Profile and Settings functional test', () {
    testWidgets('drawer opens real profile screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_profile')));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Phan Thị Hòa'), findsWidgets);
      expect(find.text('Staff profile'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('settings changes password through backend-supported flow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_settings')));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Change password'), findsWidgets);
      expect(
        find.text('Backend endpoint: POST /auth/change-password'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('old_password_field')),
        '123456',
      );
      await tester.enterText(
        find.byKey(const ValueKey('new_password_field')),
        'newpass123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('confirm_password_field')),
        'newpass123',
      );
      await tester.tap(find.byKey(const ValueKey('change_password_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Password changed successfully'), findsOneWidget);
    });
  });
}
