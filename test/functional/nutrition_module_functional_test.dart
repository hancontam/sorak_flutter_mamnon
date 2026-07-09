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

      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsOneWidget);
      expect(find.text('Tran Bao Ngoc'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Ngoc');
      await tester.pumpAndSettle();

      expect(find.text('Tran Bao Ngoc'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsNothing);

      await tester.tap(find.text('Tran Bao Ngoc'));
      await tester.pumpAndSettle();

      expect(find.text('Nutrition status'), findsOneWidget);
      expect(find.text('Latest BMI'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Nutrition Record'), findsOneWidget);
      expect(find.text('Period code'), findsOneWidget);
      expect(find.text('Weight channel'), findsOneWidget);
    });
  });
}
