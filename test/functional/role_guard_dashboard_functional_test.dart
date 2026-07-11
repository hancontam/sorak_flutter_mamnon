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

      expect(find.text('Không có quyền truy cập'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      Navigator.of(shellContext).pushNamed('/teachers');
      await tester.pumpAndSettle();

      expect(find.text('Không có quyền truy cập'), findsWidgets);
    });

    testWidgets('parent cannot open staff modules by deep link', (
      tester,
    ) async {
      await tester.pumpSorakApp(savedUser: _parentUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/students');
      await tester.pumpAndSettle();

      expect(find.text('Không có quyền truy cập'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      Navigator.of(shellContext).pushNamed('/health');
      await tester.pumpAndSettle();

      expect(find.text('Không có quyền truy cập'), findsWidgets);
    });

    testWidgets('principal can open admin routes by deep link', (tester) async {
      await tester.pumpSorakApp(savedUser: testAuthUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/accounts');
      await tester.pumpAndSettle();

      expect(find.text('Tài khoản cán bộ'), findsWidgets);
      expect(find.text('Không có quyền truy cập'), findsNothing);
    });
  });

  group('Role dashboard polish functional test', () {
    testWidgets('principal shell shows management tabs', (tester) async {
      await _pumpTall(tester, testAuthUser);

      expect(find.byKey(const ValueKey('nav_academic_years')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_teachers')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
    });

    testWidgets('teacher shell shows assigned working tabs', (tester) async {
      await _pumpTall(tester, _teacherUser);

      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_teachers')), findsNothing);
    });

    testWidgets('parent shell shows report only', (tester) async {
      await _pumpTall(tester, _parentUser);

      expect(find.text('Báo cáo của trẻ'), findsWidgets);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        find.byKey(const ValueKey('parent_api_unavailable')),
        findsNothing,
      );
    });
  });
}

Future<void> _pumpTall(WidgetTester tester, AuthUser user) async {
  await tester.binding.setSurfaceSize(const Size(400, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpSorakApp(savedUser: user);
}

const _teacherUser = AuthUser(
  id: 1002,
  fullName: 'Nguyễn Thị Lan',
  email: 'gv01@sorak.local',
  role: 'TEACHER',
);

const _parentUser = AuthUser(
  id: 1101,
  fullName: 'Nguyễn Minh An',
  email: '',
  role: 'PARENT',
);
