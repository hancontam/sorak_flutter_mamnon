import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  group('Accounts web flow functional test', () {
    testWidgets('staff tab supports unassigned filter and account grant', (
      tester,
    ) async {
      await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_accounts')));
      await tester.pumpAndSettle();

      expect(find.text('Quản lý tài khoản'), findsOneWidget);
      expect(find.text('Tài khoản cán bộ'), findsOneWidget);
      expect(find.text('Tài khoản phụ huynh'), findsOneWidget);
      expect(find.text('Chưa cấp'), findsOneWidget);
      expect(find.text('Đã cấp'), findsOneWidget);

      await tester.tap(find.text('Chưa cấp'));
      await tester.pumpAndSettle();

      expect(find.text('Lê Minh Anh'), findsOneWidget);
      expect(find.text('Chưa cấp'), findsWidgets);

      await tester.tap(find.byTooltip('Thao tác').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cấp tài khoản'));
      await tester.pumpAndSettle();

      expect(find.text('Cấp tài khoản'), findsOneWidget);
      expect(find.text('Vai trò'), findsOneWidget);
      expect(find.text('Mật khẩu khởi tạo'), findsOneWidget);

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Đã cập nhật tài khoản'), findsOneWidget);
    });

    testWidgets('parent tab supports password and active actions', (
      tester,
    ) async {
      await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('open_drawer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('drawer_accounts')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tài khoản phụ huynh'));
      await tester.pumpAndSettle();

      expect(find.text('Mã thẻ: NMA2025.001'), findsOneWidget);
      expect(find.text('SĐT PH: 0910000401'), findsOneWidget);

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

      expect(find.text('Inactive'), findsWidgets);
    });
  });
}
