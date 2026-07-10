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
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(find.text('Role: PRINCIPAL'), findsOneWidget);
      expect(find.text('Today overview'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Quick actions'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Quick actions'), findsOneWidget);

      for (final destination in _bottomDestinations) {
        expect(find.byKey(ValueKey(destination.navKey)), findsOneWidget);
      }

      for (final label in ['Students', 'Classes', 'Teachers', 'Pending']) {
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
        expect(find.byTooltip('Refresh'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    }

    testWidgets('opens transfer hub from bottom navigation', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_transfers')));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Management'), findsOneWidget);
      expect(find.text('Class'), findsOneWidget);
      expect(find.text('Outgoing'), findsOneWidget);
      expect(find.text('Incoming'), findsOneWidget);
      expect(find.text('Class Transfers'), findsWidgets);

      await tester.tap(find.text('Outgoing'));
      await tester.pumpAndSettle();

      expect(find.text('Outgoing Transfers'), findsWidgets);

      await tester.tap(find.text('Incoming'));
      await tester.pumpAndSettle();

      expect(find.text('Incoming Transfers'), findsWidgets);
    });

    testWidgets('filters a module list with the search field', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('module_search_field')), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsOneWidget);
      expect(find.text('Tran Bao Ngoc'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'Bao Ngoc',
      );
      await tester.pumpAndSettle();

      expect(find.text('Tran Bao Ngoc'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'not found keyword',
      );
      await tester.pumpAndSettle();

      expect(find.text('No matching records'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
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
        find.byKey(const ValueKey('filter_chip_Dang hoc')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('filter_chip_Dang hoc')));
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Minh An'), findsOneWidget);
      expect(find.text('Tran Bao Ngoc'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('module_search_field')),
        'not found keyword',
      );
      await tester.pumpAndSettle();

      expect(find.text('No matching records'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Minh An'), findsOneWidget);
      expect(find.text('Tran Bao Ngoc'), findsOneWidget);
    });

    testWidgets('opens detail and validates create form', (tester) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nguyen Minh An'));
      await tester.pumpAndSettle();

      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('2021-03-10'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);

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

      expect(find.text('Students'), findsWidgets);
    });

    testWidgets('delete action confirms archive and removes record', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Minh An'), findsOneWidget);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete record'), findsOneWidget);
      expect(
        find.text(
          'This will archive the record so it no longer appears in the active list.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Minh An'), findsOneWidget);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Record archived'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsNothing);
      expect(find.text('Tran Bao Ngoc'), findsOneWidget);
    });

    testWidgets('transfer list actions are grouped in the more menu', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('nav_transfers')));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('quick actions open Students and Transfers tabs', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.drag(find.byType(ListView).first, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(find.text('Quick actions'), findsOneWidget);

      await tester.tap(find.text('Students').last);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Refresh'), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_students')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_home')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Transfers'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Transfers').last);
      await tester.pumpAndSettle();

      expect(find.text('Transfer Management'), findsOneWidget);
      expect(find.text('Class Transfers'), findsWidgets);
      expect(find.text('Outgoing'), findsOneWidget);
      expect(find.text('Incoming'), findsOneWidget);
    });

    testWidgets('drawer opens Academic Years and Accounts routes', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Năm học'));
      await tester.pumpAndSettle();

      expect(find.text('Academic Years'), findsWidgets);
      expect(find.byTooltip('Refresh'), findsOneWidget);

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
  _BottomDestination(label: 'Home', navKey: 'nav_home'),
  _BottomDestination(
    label: 'Students',
    navKey: 'nav_students',
    expectedListTitle: 'Students',
  ),
  _BottomDestination(
    label: 'Classes',
    navKey: 'nav_classes',
    expectedListTitle: 'Classes',
  ),
  _BottomDestination(label: 'Transfers', navKey: 'nav_transfers'),
  _BottomDestination(label: 'Health', navKey: 'nav_health'),
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
  id: 2,
  fullName: 'Teacher User',
  email: 'teacher@sorak.edu.vn',
  role: 'TEACHER',
  token: 'demo-token-teacher',
);

const _parentUser = AuthUser(
  id: 3,
  fullName: 'Parent User',
  email: 'parent@sorak.edu.vn',
  role: 'PARENT',
  token: 'demo-token-parent',
);
