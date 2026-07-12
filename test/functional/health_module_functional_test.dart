import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health module functional test', () {
    testWidgets(
      'Health assessment history supports class date search without detail',
      (tester) async {
        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health-assessments');
        await tester.pumpAndSettle();

        expect(find.text('Xem đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Nguyễn Minh An'), findsWidgets);
        expect(find.text('Trần Bảo Ngọc'), findsOneWidget);
        expect(find.text('Ngày'), findsWidgets);
        expect(find.text('BMI/tuổi'), findsWidgets);
        expect(find.text('Cao/tuổi'), findsWidgets);
        expect(find.text('Nặng/tuổi'), findsWidgets);

        // History is view-only: no FAB create, no detail navigation.
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

        // Still on history list — no detail screen fields.
        expect(find.text('Xem đánh giá sức khỏe'), findsOneWidget);
        expect(find.text('Mã trẻ'), findsNothing);
        expect(find.text('Tình trạng BMI'), findsNothing);
      },
    );
  });
}
