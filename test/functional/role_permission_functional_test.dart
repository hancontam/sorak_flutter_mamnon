import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/network/api_exception.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('teacher sees only actions allowed by backend', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpSorakApp(savedUser: _teacher);

    expect(find.text('Yêu cầu chuyển lớp'), findsOneWidget);
    expect(find.text('Giáo viên'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('nav_classes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_add_button')), findsNothing);
    expect(find.byTooltip('Thao tác khác'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('nav_students')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_add_button')), findsOneWidget);
    await tester.tap(find.byTooltip('Thao tác khác').first);
    await tester.pumpAndSettle();
    expect(find.text('Chỉnh sửa'), findsOneWidget);
    expect(find.text('Xóa'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_transfers')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thao tác khác').first);
    await tester.pumpAndSettle();
    expect(find.text('Hủy yêu cầu'), findsOneWidget);
    expect(find.text('Duyệt'), findsNothing);
    expect(find.text('Từ chối'), findsNothing);
  });

  test('teacher API requests outside scope are rejected', () async {
    final client = ApiClient.memory();
    client.configureMockSession(
      role: 'TEACHER',
      accountId: 1002,
      teacherId: 202,
    );

    try {
      await AccountRepository(apiClient: client).getStaffAccounts();
      fail('Teacher must not read Accounts');
    } on DioException catch (error) {
      expect(ApiException.from(error).statusCode, 403);
    }

    try {
      await ClassRepository(apiClient: client).archive(301);
      fail('Teacher must not archive a class');
    } on DioException catch (error) {
      expect(ApiException.from(error).statusCode, 403);
    }
  });

  testWidgets('parent does not load staff academic-year selector', (
    tester,
  ) async {
    await tester.pumpSorakApp(savedUser: _parent);

    expect(find.byKey(const ValueKey('active_year_dropdown')), findsNothing);
    expect(find.byKey(const ValueKey('nav_child')), findsOneWidget);
    expect(find.text('Nguyễn Minh An'), findsWidgets);
  });
}

const _teacher = AuthUser(
  id: 1002,
  fullName: 'Nguyễn Thị Lan',
  email: 'gv01@sorak.local',
  role: 'TEACHER',
);

const _parent = AuthUser(
  id: 1101,
  fullName: 'Nguyễn Minh An',
  email: '',
  role: 'PARENT',
);
