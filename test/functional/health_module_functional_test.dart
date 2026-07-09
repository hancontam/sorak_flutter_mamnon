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

        expect(find.text('Health Assessments'), findsOneWidget);
        expect(find.text('Nguyen Minh An'), findsOneWidget);
        expect(find.text('Tran Bao Ngoc'), findsOneWidget);

        await tester.enterText(find.byType(TextField).first, 'Bao');
        await tester.pumpAndSettle();

        expect(find.text('Tran Bao Ngoc'), findsOneWidget);
        expect(find.text('Nguyen Minh An'), findsNothing);

        await tester.tap(find.text('Tran Bao Ngoc'));
        await tester.pumpAndSettle();

      expect(find.text('Student code'), findsOneWidget);
      expect(find.text('Assessment date'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

      expect(find.text('Quick Health Entry'), findsOneWidget);
      expect(find.text('Assessment date (yyyy-mm-dd)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);
      },
    );
  });
}
