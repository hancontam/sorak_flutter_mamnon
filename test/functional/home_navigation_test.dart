import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('Home navigation functional test', () {
    testWidgets('principal sees four bottom tabs and role drawer', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      expect(
        find.byKey(const ValueKey('active_year_dropdown')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('nav_academic_years')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_teachers')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_home')), findsNothing);
      expect(find.byKey(const ValueKey('nav_transfers')), findsNothing);
      expect(find.byKey(const ValueKey('nav_health')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('drawer_student_accounts')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('drawer_staff_accounts')),
        findsOneWidget,
      );
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
      expect(find.byKey(const ValueKey('drawer_health')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('drawer_health_assessments')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('drawer_profile')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_settings')), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Manual Tests'), findsNothing);
    });

    for (final destination in _bottomDestinations) {
      testWidgets('opens ${destination.label} from bottom navigation', (
        tester,
      ) async {
        await _pumpTallHome(tester);

        await tester.tap(find.byKey(ValueKey(destination.navKey)));
        await tester.pumpAndSettle();

        expect(find.text(destination.expectedListTitle), findsWidgets);
        if (destination.navKey != 'nav_teachers') {
          expect(
            find.byKey(const ValueKey('module_search_field')),
            findsOneWidget,
          );
        }
      });
    }

    testWidgets('opens staff detail bottom sheet from card', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_teachers')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nguyễn Thị Lan').first);
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết cán bộ'), findsOneWidget);
      expect(find.text('Thông tin công việc'), findsOneWidget);
      expect(find.text('Thông tin liên hệ'), findsOneWidget);
      expect(find.text('Thông tin cá nhân'), findsOneWidget);
      expect(find.text('Địa chỉ'), findsOneWidget);
    });

    testWidgets('opens class detail sheet with scoped students', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_classes')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('class_card_301')));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết lớp học'), findsOneWidget);
      expect(find.text('Học sinh trong lớp'), findsOneWidget);
      expect(find.text('Tên lớp'), findsOneWidget);
      expect(find.text('Phòng học'), findsOneWidget);
      expect(find.text('Giáo viên phụ trách'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsOneWidget);
      expect(find.text('Trần Bảo Ngọc'), findsNothing);
    });

    testWidgets('filters students by name or card number', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('module_search_field')), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'Bao Ngoc',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('student_card_402')), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'not found keyword',
      );
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy học sinh'), findsOneWidget);
      expect(find.text('Xóa bộ lọc'), findsOneWidget);
    });

    testWidgets('opens student detail and validates create form', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nguyễn Minh An'));
      await tester.pumpAndSettle();

      expect(find.text('Ngày sinh'), findsOneWidget);
      expect(find.text('10/03/2021'), findsOneWidget);
      expect(find.text('Liên hệ phụ huynh'), findsOneWidget);
      expect(find.text('Mẹ'), findsOneWidget);
      expect(find.text('0980000401'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tạo hồ sơ học sinh'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget);
    });

    testWidgets('delete action confirms archive and removes record', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsOneWidget);

      await tester.tap(find.byTooltip('Thao tác với học sinh').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();

      expect(find.text('Xóa hồ sơ trẻ?'), findsOneWidget);
      expect(
        find.text(
          'Hồ sơ trẻ sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Xóa').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Đã xóa hồ sơ trẻ khỏi danh sách'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
    });

    testWidgets('drawer opens account and transfer routes', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_staff_accounts')));
      await tester.pumpAndSettle();

      expect(find.text('Tài khoản cán bộ'), findsWidgets);
      expect(find.byTooltip('Làm mới'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_class_transfers')));
      await tester.pumpAndSettle();

      expect(find.text('Chuyển lớp'), findsWidgets);
    });

    testWidgets('teacher sees only students and classes bottom tabs', (
      tester,
    ) async {
      await _pumpTallHome(tester, savedUser: _teacherUser);

      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_academic_years')), findsNothing);
      expect(find.byKey(const ValueKey('nav_teachers')), findsNothing);
      expect(find.byKey(const ValueKey('nav_home')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('drawer_class_transfers')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('drawer_health')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('drawer_student_accounts')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('drawer_staff_accounts')), findsNothing);
      expect(find.text('Manual Tests'), findsNothing);
    });

    testWidgets('parent sees report with no bottom navigation', (tester) async {
      await _pumpTallHome(tester, savedUser: _parentUser);

      expect(find.text('Báo cáo của trẻ'), findsWidgets);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byKey(const ValueKey('nav_students')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('drawer_profile')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_accounts')), findsNothing);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Manual Tests'), findsNothing);
    });
  });
}

Future<void> _pumpTallHome(
  WidgetTester tester, {
  AuthUser savedUser = testAuthUser,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpSorakApp(savedUser: savedUser);
}

const _bottomDestinations = [
  _BottomDestination(
    label: 'Năm học',
    navKey: 'nav_academic_years',
    expectedListTitle: 'Năm học',
  ),
  _BottomDestination(
    label: 'Học sinh',
    navKey: 'nav_students',
    expectedListTitle: 'Học sinh',
  ),
  _BottomDestination(
    label: 'Cán bộ',
    navKey: 'nav_teachers',
    expectedListTitle: 'Cán bộ',
  ),
  _BottomDestination(
    label: 'Lớp học',
    navKey: 'nav_classes',
    expectedListTitle: 'Lớp học',
  ),
];

class _BottomDestination {
  const _BottomDestination({
    required this.label,
    required this.navKey,
    required this.expectedListTitle,
  });

  final String label;
  final String navKey;
  final String expectedListTitle;
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
