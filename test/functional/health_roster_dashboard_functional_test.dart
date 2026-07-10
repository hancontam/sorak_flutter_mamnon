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

        expect(find.text('Đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Lớp'), findsOneWidget);
        expect(find.text('Ngày đánh giá'), findsOneWidget);
        await _selectMam1A(tester);

        expect(find.text('Nguyễn Minh An'), findsOneWidget);
        expect(find.text('Trần Bảo Ngọc'), findsNothing);

        await tester.tap(find.text('Nguyễn Minh An'));
        await tester.pumpAndSettle();

        expect(find.text('Preview sức khỏe'), findsOneWidget);
        expect(find.text('Lịch sử gần đây'), findsOneWidget);
        expect(find.text('Nhập nhanh sức khỏe'), findsOneWidget);
        expect(find.text('Chiều cao (cm)'), findsOneWidget);
        expect(find.text('Cân nặng (kg)'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Chiều cao (cm)'),
          '103',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Cân nặng (kg)'),
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

    testWidgets(
      'nutrition dashboard supports period roster and quick preview',
      (tester) async {
        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Nuôi dưỡng'));
        await tester.pumpAndSettle();

        expect(find.text('Đánh giá nuôi dưỡng'), findsOneWidget);
        expect(find.text('Giai đoạn'), findsOneWidget);
        await _selectMam1A(tester);

        expect(find.text('Nguyễn Minh An'), findsOneWidget);

        await tester.tap(find.text('Nguyễn Minh An'));
        await tester.pumpAndSettle();

        expect(find.text('Preview nuôi dưỡng'), findsOneWidget);
        expect(find.text('Nhập nhanh nuôi dưỡng'), findsOneWidget);
        expect(find.text('Kênh tăng trưởng cân nặng'), findsOneWidget);
        expect(find.text('SDD thấp còi'), findsOneWidget);
        expect(find.text('Béo phì'), findsOneWidget);
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
