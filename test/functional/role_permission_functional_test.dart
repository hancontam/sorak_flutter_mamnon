import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/network/api_exception.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('teacher sees only actions allowed by role navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpSorakApp(savedUser: _teacher);

    expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_teachers')), findsNothing);
    expect(find.byKey(const ValueKey('nav_academic_years')), findsNothing);
    expect(find.byKey(const ValueKey('module_add_button')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('student_class_filter_')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mầm 1A'), findsWidgets);
    expect(find.textContaining('Chồi 2B'), findsNothing);
    await tester.tap(find.text('Tất cả lớp').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_classes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_add_button')), findsNothing);
    expect(find.byTooltip('Thao tác khác'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('class_grade_filter_')));
    await tester.pumpAndSettle();
    expect(find.text('Mầm'), findsWidgets);
    expect(find.text('Chồi'), findsNothing);
    expect(find.text('Lá'), findsNothing);
    await tester.tap(find.text('Tất cả khối').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_students')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_add_button')), findsNothing);
    expect(find.byTooltip('Thao tác với học sinh'), findsNothing);
    expect(find.text('Cập nhật trẻ'), findsNothing);
    expect(find.text('Xóa'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('drawer_class_transfers')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('drawer_incoming_transfers')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('drawer_outgoing_transfers')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('drawer_staff_accounts')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('drawer_class_transfers')));
    await tester.pumpAndSettle();
    expect(find.text('Duyệt'), findsNothing);
    expect(find.text('Từ chối'), findsNothing);
    expect(find.text('Hủy'), findsOneWidget);
  });

  testWidgets('principal keeps full student class and grade filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpLoggedInSorakApp();

    await tester.tap(find.byKey(const ValueKey('nav_students')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('module_add_button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('student_class_filter_')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mầm 1A'), findsWidgets);
    expect(find.textContaining('Chồi 2B'), findsWidgets);
    await tester.tap(find.text('Tất cả lớp').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_classes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('class_grade_filter_')));
    await tester.pumpAndSettle();
    expect(find.text('Nhà trẻ'), findsOneWidget);
    expect(find.text('Mầm'), findsWidgets);
    expect(find.text('Chồi'), findsWidgets);
    expect(find.text('Lá'), findsOneWidget);
    await tester.tap(find.text('Tất cả khối').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav_teachers')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('module_search_field')),
      'khong ton tai',
    );
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy cán bộ'), findsOneWidget);
    expect(find.text('Xóa bộ lọc'), findsNothing);

    final shellContext = tester.element(find.byType(NavigationBar));
    Navigator.of(shellContext).pushNamed('/class-transfers');
    await tester.pumpAndSettle();
    expect(find.text('Duyệt'), findsOneWidget);
    expect(find.text('Từ chối'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });

  testWidgets('teacher direct routes load only assigned classes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpSorakApp(savedUser: _teacher);

    final shellContext = tester.element(find.byType(NavigationBar));
    Navigator.of(shellContext).pushNamed('/health');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mầm 1A'), findsWidgets);
    expect(find.textContaining('Chồi 2B'), findsNothing);
    await tester.tap(find.textContaining('Mầm 1A').last);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    Navigator.of(shellContext).pushNamed('/health-assessments');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('health_history_class_')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mầm 1A'), findsWidgets);
    expect(find.textContaining('Chồi 2B'), findsNothing);
    await tester.tap(find.textContaining('Mầm 1A').last);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    Navigator.of(shellContext).pushNamed('/class-transfers');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mầm 1A'), findsWidgets);
    expect(find.textContaining('Chồi 2B'), findsNothing);
  });

  testWidgets('teacher school-transfer routes are available and read-only', (
    tester,
  ) async {
    await tester.pumpSorakApp(savedUser: _teacher);
    final shellContext = tester.element(find.byType(NavigationBar));

    for (final route in const [
      '/transfers',
      '/incoming-transfers',
      '/outgoing-transfers',
    ]) {
      Navigator.of(shellContext).pushNamed(route);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('permission_denied_state')),
        findsNothing,
      );
      if (route != '/transfers') {
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byTooltip('Thao tác khác'), findsNothing);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
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

    try {
      await StudentRepository(
        apiClient: client,
      ).update(401, {'full_name': 'Không được sửa'});
      fail('Teacher must not update a student');
    } on DioException catch (error) {
      expect(ApiException.from(error).statusCode, 403);
    }

    try {
      await StudentRepository(apiClient: client).updateParents(401, [
        {'full_name': 'Không được sửa'},
      ]);
      fail('Teacher must not update parents');
    } on DioException catch (error) {
      expect(ApiException.from(error).statusCode, 403);
    }

    for (final mutation in <Future<void> Function()>[
      () => IncomingTransferRepository(apiClient: client).cancel(511),
      () => OutgoingTransferRepository(apiClient: client).cancel(521),
    ]) {
      try {
        await mutation();
        fail('Teacher must not mutate school transfers');
      } on DioException catch (error) {
        expect(ApiException.from(error).statusCode, 403);
      }
    }
  });

  testWidgets('parent does not load staff year selector or bottom nav', (
    tester,
  ) async {
    await tester.pumpSorakApp(savedUser: _parent);

    expect(find.byKey(const ValueKey('active_year_dropdown')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Nguyễn Minh An'), findsWidgets);
    expect(find.text('Báo cáo của trẻ'), findsWidgets);
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
