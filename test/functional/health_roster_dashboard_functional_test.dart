import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health roster dashboard functional test', () {
    testWidgets(
      'health dashboard supports class roster preview and quick entry',
      (tester) async {
        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health');
        await tester.pumpAndSettle();

        expect(find.text('Đánh giá sức khỏe'), findsWidgets);
        expect(find.text('Lớp'), findsOneWidget);
        expect(find.text('Ngày đánh giá'), findsOneWidget);
        // Health roster supports class + date entry.
        expect(find.text('Nuôi dưỡng'), findsNothing);
        expect(find.text('Tăng trưởng'), findsNothing);
        await _selectMam1A(tester);

        expect(find.text('Nguyễn Minh An'), findsWidgets);
        expect(find.text('Trần Bảo Ngọc'), findsNothing);
        expect(find.text('1.'), findsWidgets);
        expect(find.text('Mã thẻ'), findsWidgets);
        expect(find.text('Ngày sinh'), findsWidgets);
        expect(find.text('Giới tính'), findsWidgets);

        await tester.tap(find.text('Nguyễn Minh An').first);
        await tester.pumpAndSettle();

        expect(find.text('Số đo gần nhất'), findsOneWidget);
        expect(find.text('Chiều cao (cm)'), findsOneWidget);
        expect(find.text('Cân nặng (kg)'), findsOneWidget);
        expect(find.text('Ghi chú'), findsWidgets);
        expect(find.text('100'), findsWidgets);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nhập chiều cao'),
          '103',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nhập cân nặng'),
          '17',
        );
        await tester.ensureVisible(find.text('Lưu sức khỏe'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lưu sức khỏe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Đã lưu đánh giá'), findsOneWidget);
      },
    );
  });
}

Future<void> _selectMam1A(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mầm 1A - A101').last);
  await tester.pumpAndSettle();
}
