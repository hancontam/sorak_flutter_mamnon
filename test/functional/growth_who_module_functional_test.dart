import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';

void main() {
  group('Growth WHO module functional test', () {
    testWidgets('Principal can search students and view WHO chart summary', (
      tester,
    ) async {
      await tester.pumpLoggedInSorakApp();

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/growth');
      await tester.pumpAndSettle();

      expect(find.text('Growth WHO'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsWidgets);
      expect(find.byType(EditableText), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'Ngoc');
      await tester.pumpAndSettle();

      expect(find.text('Growth WHO'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Mobile BMI chart'), findsOneWidget);
    });

    testWidgets('Parent sees view only growth for own child', (tester) async {
      const parentUser = AuthUser(
        id: 10,
        fullName: 'Parent Demo',
        email: 'parent@sorak.edu.vn',
        role: 'PARENT',
        token: 'demo-token-parent',
      );

      await tester.pumpSorakApp(savedUser: parentUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/growth');
      await tester.pumpAndSettle();

      expect(find.text('View only'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsWidgets);
      expect(find.text('Tran Bao Ngoc'), findsNothing);
      expect(find.byType(EditableText), findsNothing);
    });
  });
}
