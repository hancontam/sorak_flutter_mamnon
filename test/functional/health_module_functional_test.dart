import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health module functional test', () {
    testWidgets(
      'Health assessment list supports search detail and quick form',
      (tester) async {
        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health-assessments');
        await tester.pumpAndSettle();

        expect(find.text('Đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Nguyễn Minh An'), findsWidgets);
        expect(find.text('Trần Bảo Ngọc'), findsOneWidget);

        await tester.tap(find.byTooltip('Thao tác khác').first);
        await tester.pumpAndSettle();
        expect(find.text('Chỉnh sửa'), findsOneWidget);
        expect(find.text('Xóa'), findsNothing);
        await tester.tapAt(const Offset(8, 8));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Bao');
        await tester.pumpAndSettle();

        expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
        expect(find.text('Nguyễn Minh An'), findsNothing);

        await tester.tap(find.text('Trần Bảo Ngọc'));
        await tester.pumpAndSettle();

        expect(find.text('Mã trẻ'), findsOneWidget);
        expect(find.text('Ngày đánh giá'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('Nhập nhanh sức khỏe'), findsOneWidget);
        expect(find.text('Ngày đánh giá (yyyy-mm-dd)'), findsOneWidget);
        expect(find.text('Chiều cao (cm)'), findsOneWidget);
      },
    );
  });
}
