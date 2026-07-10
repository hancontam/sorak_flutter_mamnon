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

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('Tăng trưởng WHO'), findsWidgets);
      expect(find.text('Nguyễn Minh An'), findsWidgets);
      expect(find.byType(EditableText), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'Ngoc');
      await tester.pumpAndSettle();

      expect(find.text('Tăng trưởng WHO'), findsWidgets);
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Biểu đồ BMI'), findsOneWidget);
    });

    testWidgets('Parent sees view only growth for own child', (tester) async {
      const parentUser = AuthUser(
        id: 1101,
        fullName: 'Nguyễn Minh An',
        email: '',
        role: 'PARENT',
      );

      await tester.pumpSorakApp(savedUser: parentUser);

      final shellContext = tester.element(find.byType(AppShell));
      Navigator.of(shellContext).pushNamed('/growth');
      await tester.pumpAndSettle();

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('parent_growth_api_unavailable')),
        findsOneWidget,
      );
      expect(find.text('Chưa có dữ liệu tăng trưởng'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsNothing);
      expect(find.byType(EditableText), findsNothing);
    });
  });
}
