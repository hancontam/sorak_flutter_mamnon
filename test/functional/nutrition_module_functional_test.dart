import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';

import 'helpers/test_app.dart';

void main() {
  group('Nutrition module functional test', () {
    testWidgets('Nutrition list supports search detail and form', (
      tester,
    ) async {
      await tester.pumpLoggedInSorakApp();

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/nutrition');
      await tester.pumpAndSettle();

      expect(find.text('Đánh giá nuôi dưỡng'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsOneWidget);
      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Ngoc');
      await tester.pumpAndSettle();

      expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);

      await tester.tap(find.text('Trần Bảo Ngọc'));
      await tester.pumpAndSettle();

      expect(find.text('Tình trạng dinh dưỡng'), findsOneWidget);
      expect(find.text('BMI gần nhất'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tạo đánh giá nuôi dưỡng'), findsOneWidget);
      expect(find.text('Mã giai đoạn'), findsOneWidget);
      expect(find.text('Kênh cân nặng'), findsOneWidget);
    });
  });
}
