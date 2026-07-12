import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  group('Accounts web flow functional test', () {
    testWidgets(
      'staff accounts supports work/account filters and account grant',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1200));
        addTearDown(() {
          tester.binding.setSurfaceSize(null);
          tester.view.resetViewInsets();
        });
        await tester.pumpLoggedInSorakApp();

        await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('drawer_accounts')));
        await tester.pumpAndSettle();

        expect(find.text('Tài khoản cán bộ'), findsWidgets);
        // Separate drawer routes — no staff/student toggle on screen.
        expect(find.text('Cán bộ'), findsNothing);
        expect(find.text('Học sinh'), findsNothing);
        expect(find.text('Trạng thái cán bộ'), findsWidgets);
        expect(find.text('Trạng thái tài khoản'), findsWidgets);
        expect(find.text('Đang làm việc'), findsWidgets);

        expect(find.text('Lê Minh Anh'), findsWidgets);
        expect(find.text('Chưa cấp tài khoản'), findsWidgets);

        final unassignedCard = find
            .ancestor(
              of: find.text('Lê Minh Anh').first,
              matching: find.byType(Card),
            )
            .first;
        await tester.ensureVisible(unassignedCard);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: unassignedCard,
            matching: find.byTooltip('Thao tác'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cấp tài khoản').last);
        await tester.pumpAndSettle();

        expect(find.text('Cấp tài khoản'), findsOneWidget);
        expect(find.text('Vai trò'), findsWidgets);
        expect(find.text('Mật khẩu khởi tạo'), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(360, 640));
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.showKeyboard(find.byType(TextField).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Lưu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lưu'));
        await tester.pumpAndSettle();

        expect(find.text('Đã cập nhật tài khoản'), findsOneWidget);
      },
    );

    testWidgets('student accounts supports password and active actions', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tài khoản học sinh'));
      await tester.pumpAndSettle();

      expect(find.text('Tài khoản học sinh'), findsWidgets);
      expect(find.text('Trạng thái học sinh'), findsWidgets);
      expect(find.textContaining('NMA2025.001'), findsWidgets);
      expect(find.text('Trạng thái HS'), findsWidgets);
      expect(find.text('Đang mở'), findsWidgets);

      await tester.tap(find.byTooltip('Thao tác').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đổi mật khẩu PH'));
      await tester.pumpAndSettle();

      expect(find.text('Đổi mật khẩu PH'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Đã cập nhật tài khoản'), findsOneWidget);

      await tester.tap(find.byTooltip('Thao tác').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Khóa tài khoản PH'));
      await tester.pumpAndSettle();

      expect(find.text('Đã cập nhật tài khoản'), findsWidgets);
    });
  });
}
