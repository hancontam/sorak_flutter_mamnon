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

      expect(find.text('Quản lý tài khoản'), findsWidgets);
      expect(find.text('Không có quyền truy cập'), findsNothing);
    });
  });

  group('Role dashboard polish functional test', () {
    testWidgets('principal dashboard shows overview and management shortcuts', (
      tester,
    ) async {
      await _pumpTall(tester, testAuthUser);

      expect(find.text('Tổng quan Ban Giám Hiệu'), findsOneWidget);
      expect(find.text('Thao tác Ban Giám Hiệu'), findsOneWidget);
      expect(find.text('Yêu cầu chuyển lớp chờ duyệt'), findsOneWidget);
      expect(find.text('Tài khoản'), findsWidgets);
    });

    testWidgets('teacher dashboard shows assigned classes and quick entry', (
      tester,
    ) async {
      await _pumpTall(tester, _teacherUser);

      expect(find.text('Công việc giáo viên'), findsOneWidget);
      expect(find.text('Thao tác nhanh cho giáo viên'), findsOneWidget);
      expect(find.text('Lớp được phân công'), findsOneWidget);
      expect(find.text('Nhập nhanh sức khỏe'), findsOneWidget);
      expect(find.text('Nhập nhanh dinh dưỡng'), findsOneWidget);
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
      expect(
        find.byKey(const ValueKey('parent_api_unavailable')),
        findsOneWidget,
      );
      expect(find.text('Chưa có dữ liệu từ nhà trường'), findsOneWidget);
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
