import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health module functional test', () {
    testWidgets(
      'Health assessment cards open read-only student history sheet',
      (tester) async {
        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health-assessments');
        await tester.pumpAndSettle();

        expect(find.text('Xem đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Nguyễn Minh An'), findsWidgets);
        expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
        expect(find.text('Đánh giá mới nhất'), findsWidgets);
        expect(find.text('BMI/tuổi'), findsWidgets);
        expect(find.text('Cao/tuổi'), findsWidgets);
        expect(find.text('Nặng/tuổi'), findsWidgets);

        // History is view-only: no create action.
        expect(find.byType(FloatingActionButton), findsNothing);

        await tester.enterText(
          find.byKey(const ValueKey('module_search_field')),
          'Bao',
        );
        await tester.pumpAndSettle();

        expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
        expect(find.text('Nguyễn Minh An'), findsNothing);

        await tester.tap(find.text('Trần Bảo Ngọc'));
        await tester.pumpAndSettle();

        expect(find.text('Lịch sử đánh giá sức khỏe'), findsOneWidget);
        expect(find.textContaining('lần đánh giá'), findsOneWidget);
        expect(find.text('Chiều cao'), findsWidgets);
        expect(find.text('Cân nặng'), findsWidgets);
        expect(find.text('BMI'), findsWidgets);
        expect(find.textContaining('Thêm đánh giá'), findsNothing);
        expect(find.textContaining('Thêm kết quả'), findsNothing);

        // Bottom sheet stays inside the history flow, not a detail route.
        expect(find.text('Xem đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Mã trẻ'), findsNothing);
        expect(find.text('Tình trạng BMI'), findsNothing);
      },
    );

    testWidgets('date filter keeps roster cards read-only', (tester) async {
      await tester.pumpLoggedInSorakApp();

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/health-assessments');
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.chevronRight), findsWidgets);

      final dateField = find.widgetWithText(TextFormField, 'Ngày đánh giá');
      await tester.tap(dateField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('11').last);
      await tester.tap(find.text('Chọn'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Minh An'), findsWidgets);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
      expect(find.text('Ngày đánh giá'), findsWidgets);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);

      await tester.tap(find.text('Trần Bảo Ngọc'));
      await tester.pumpAndSettle();
      expect(find.text('Lịch sử đánh giá sức khỏe'), findsNothing);
    });
  });
}
