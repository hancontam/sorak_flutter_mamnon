import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('Home navigation functional test', () {
    testWidgets('app shell shows user information and main navigation', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      expect(find.text('Sorak Mầm non'), findsWidgets);
      expect(
        find.byKey(const ValueKey('active_year_dropdown')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('app_logout_button')), findsNothing);
      expect(find.text('Xin chào, Phan Thị Hòa'), findsOneWidget);
      expect(find.text('Vai trò: PRINCIPAL'), findsOneWidget);
      expect(find.text('Tổng quan hôm nay'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Thao tác nhanh'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Thao tác nhanh'), findsOneWidget);

      for (final destination in _bottomDestinations) {
        expect(find.byKey(ValueKey(destination.navKey)), findsOneWidget);
      }

      for (final label in ['Trẻ', 'Lớp học', 'Giáo viên', 'Chờ duyệt']) {
        expect(find.text(label), findsWidgets);
      }

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();

      expect(find.text('Năm học'), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_accounts')), findsOneWidget);
      expect(find.text('Hồ sơ'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.text('Manual Tests'), findsNothing);
    });

    for (final destination in _bottomDestinations.where(
      (destination) => destination.expectedListTitle != null,
    )) {
      testWidgets('opens ${destination.label} from bottom navigation', (
        tester,
      ) async {
        await _pumpTallHome(tester);

        await tester.tap(find.byKey(ValueKey(destination.navKey)));
        await tester.pumpAndSettle();

        expect(find.text(destination.expectedListTitle!), findsWidgets);
        expect(find.byTooltip('Làm mới'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    }

    testWidgets('opens transfer hub from bottom navigation', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_transfers')));
      await tester.pumpAndSettle();

      expect(find.text('Quản lý chuyển trường'), findsOneWidget);
      expect(find.text('Chuyển lớp'), findsWidgets);
      expect(find.text('Chuyển đi'), findsOneWidget);
      expect(find.text('Chuyển đến'), findsOneWidget);

      await tester.tap(find.text('Chuyển đi'));
      await tester.pumpAndSettle();

      expect(find.text('Chuyển trường đi'), findsWidgets);

      await tester.tap(find.text('Chuyển đến'));
      await tester.pumpAndSettle();

      expect(find.text('Chuyển trường đến'), findsWidgets);
    });

    testWidgets('filters a module list with the search field', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('module_search_field')), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsOneWidget);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'Bao Ngoc',
      );
      await tester.pumpAndSettle();

      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'not found keyword',
      );
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy dữ liệu'), findsOneWidget);
      expect(find.text('Xóa bộ lọc'), findsOneWidget);
    });

    testWidgets('filters a module list with filter chips', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('module_filter_chip_row')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('filter_chip_all')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('filter_chip_Đang học')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('filter_chip_Đang học')));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsOneWidget);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'not found keyword',
      );
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy dữ liệu'), findsOneWidget);

      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsOneWidget);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
    });

    testWidgets('opens detail and validates create form', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nguyễn Minh An'));
      await tester.pumpAndSettle();

      expect(find.text('Ngày sinh'), findsOneWidget);
      expect(find.text('2021-03-10'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tạo hồ sơ học sinh'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget);

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Trẻ'), findsWidgets);
    });

    testWidgets('delete action confirms archive and removes record', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsOneWidget);

      await tester.tap(find.byTooltip('Thao tác khác').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();

      expect(find.text('Xóa dữ liệu'), findsOneWidget);
      expect(
        find.text(
          'Dữ liệu sẽ được ẩn khỏi danh sách đang hoạt động và không bị xóa vĩnh viễn.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsOneWidget);

      await tester.tap(find.byTooltip('Thao tác khác').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Đã xóa dữ liệu khỏi danh sách'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
    });

    testWidgets('transfer list actions are grouped in the more menu', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_transfers')));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Thao tác khác').first);
      await tester.pumpAndSettle();

      expect(find.text('Duyệt'), findsOneWidget);
      expect(find.text('Từ chối'), findsOneWidget);
      expect(find.text('Hủy yêu cầu'), findsOneWidget);
      expect(find.text('Chỉnh sửa'), findsNothing);
    });

    testWidgets('quick actions open Students and Transfers tabs', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.drag(find.byType(ListView).first, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(find.text('Thao tác nhanh'), findsOneWidget);

      await tester.tap(find.text('Trẻ').last);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Làm mới'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_home')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Chuyển lớp'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Chuyển lớp').last);
      await tester.pumpAndSettle();

      expect(find.text('Quản lý chuyển trường'), findsOneWidget);
      expect(find.text('Chuyển lớp'), findsWidgets);
      expect(find.text('Chuyển đi'), findsOneWidget);
      expect(find.text('Chuyển đến'), findsOneWidget);
    });

    testWidgets('drawer opens Academic Years and Accounts routes', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Năm học'));
      await tester.pumpAndSettle();

      expect(find.text('Năm học'), findsWidgets);
      expect(find.byTooltip('Làm mới'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_accounts')));
      await tester.pumpAndSettle();

      expect(find.text('Quản lý tài khoản'), findsWidgets);
      expect(find.byTooltip('Refresh'), findsOneWidget);
    });

    testWidgets('teacher sees teacher navigation only', (tester) async {
      await _pumpTallHome(tester, savedUser: _teacherUser);

      expect(find.byKey(const ValueKey('nav_home')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_classes')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_transfers')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_health')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_teachers')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('drawer_growth')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_profile')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('drawer_academic_years')), findsNothing);
      expect(find.byKey(const ValueKey('drawer_accounts')), findsNothing);
      expect(find.text('Manual Tests'), findsNothing);
    });

    testWidgets('parent sees read only parent portal navigation', (
      tester,
    ) async {
      await _pumpTallHome(tester, savedUser: _parentUser);

      expect(find.text('Cổng phụ huynh'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_child')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_growth')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_health')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsNothing);
      expect(find.byKey(const ValueKey('nav_transfers')), findsNothing);

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
  _BottomDestination(label: 'Trang chủ', navKey: 'nav_home'),
  _BottomDestination(
    label: 'Trẻ',
    navKey: 'nav_students',
    expectedListTitle: 'Trẻ',
  ),
  _BottomDestination(
    label: 'Lớp học',
    navKey: 'nav_classes',
    expectedListTitle: 'Lớp học',
  ),
  _BottomDestination(label: 'Chuyển lớp', navKey: 'nav_transfers'),
  _BottomDestination(label: 'Sức khỏe', navKey: 'nav_health'),
];

class _BottomDestination {
  const _BottomDestination({
    required this.label,
    required this.navKey,
    this.expectedListTitle,
  });

  final String label;
  final String navKey;
  final String? expectedListTitle;
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
