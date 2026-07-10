import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('Role guard functional test', () {
    testWidgets('teacher cannot open admin routes by deep link', (
      tester,
    ) async {
      await tester.pumpSorakApp(savedUser: _teacherUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/accounts');
      await tester.pumpAndSettle();

      expect(find.text('Access denied'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      Navigator.of(shellContext).pushNamed('/teachers');
      await tester.pumpAndSettle();

      expect(find.text('Access denied'), findsWidgets);
    });

    testWidgets('parent cannot open staff modules by deep link', (
      tester,
    ) async {
      await tester.pumpSorakApp(savedUser: _parentUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/students');
      await tester.pumpAndSettle();

      expect(find.text('Access denied'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      Navigator.of(shellContext).pushNamed('/health');
      await tester.pumpAndSettle();

      expect(find.text('Access denied'), findsWidgets);
    });

    testWidgets('principal can open admin routes by deep link', (tester) async {
      await tester.pumpSorakApp(savedUser: testAuthUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/accounts');
      await tester.pumpAndSettle();

      expect(find.text('Quản lý tài khoản'), findsWidgets);
      expect(find.text('Access denied'), findsNothing);
    });
  });

  group('Role dashboard polish functional test', () {
    testWidgets('principal dashboard shows overview and management shortcuts', (
      tester,
    ) async {
      await _pumpTall(tester, testAuthUser);

      expect(find.text('Principal dashboard'), findsOneWidget);
      expect(find.text('Principal actions'), findsOneWidget);
      expect(find.text('Pending transfers'), findsOneWidget);
      expect(find.text('Accounts'), findsWidgets);
    });

    testWidgets('teacher dashboard shows assigned classes and quick entry', (
      tester,
    ) async {
      await _pumpTall(tester, _teacherUser);

      expect(find.text('Teacher dashboard'), findsOneWidget);
      expect(find.text('Teacher quick work'), findsOneWidget);
      expect(find.text('Assigned classes'), findsOneWidget);
      expect(find.text('Quick health entry'), findsOneWidget);
      expect(find.text('Quick nutrition entry'), findsOneWidget);
    });

    testWidgets('parent dashboard shows child profile then health tab', (
      tester,
    ) async {
      await _pumpTall(tester, _parentUser);

      expect(find.text('Cổng phụ huynh'), findsOneWidget);
      expect(find.text('Thông tin trẻ'), findsOneWidget);
      expect(find.text('Hồ sơ trẻ'), findsOneWidget);
      expect(find.text('Tình trạng sức khỏe'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('nav_health')));
      await tester.pumpAndSettle();

      expect(find.text('Sức khỏe của trẻ'), findsOneWidget);
      expect(find.text('Tình trạng sức khỏe'), findsOneWidget);
      expect(find.text('Tình trạng nuôi dưỡng'), findsOneWidget);
      expect(find.text('Hồ sơ trẻ'), findsNothing);
    });
  });
}

Future<void> _pumpTall(WidgetTester tester, AuthUser user) async {
  await tester.binding.setSurfaceSize(const Size(400, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpSorakApp(savedUser: user);
}

const _teacherUser = AuthUser(
  id: 2,
  fullName: 'Teacher User',
  email: 'teacher@sorak.edu.vn',
  role: 'TEACHER',
);

const _parentUser = AuthUser(
  id: 3,
  fullName: 'Parent User',
  email: 'parent@sorak.edu.vn',
  role: 'PARENT',
);
