import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';

void main() {
  group('Parent Portal functional test', () {
    testWidgets('Parent sees child profile and separate health tab view only', (
      tester,
    ) async {
      const parentUser = AuthUser(
        id: 10,
        fullName: 'Parent Demo',
        email: 'parent@sorak.edu.vn',
        role: 'PARENT',
        token: 'demo-token-parent',
      );

      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpSorakApp(savedUser: parentUser);

      expect(find.text('Cổng phụ huynh'), findsOneWidget);
      expect(find.text('Chỉ xem'), findsWidgets);
      expect(find.text('Hồ sơ trẻ'), findsOneWidget);
      expect(find.text('Nguyen Minh An'), findsWidgets);
      expect(find.text('Tình trạng sức khỏe'), findsNothing);
      expect(find.text('Tình trạng nuôi dưỡng'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('nav_health')));
      await tester.pumpAndSettle();

      expect(find.text('Sức khỏe của trẻ'), findsOneWidget);
      expect(find.text('Tình trạng sức khỏe'), findsOneWidget);
      expect(find.text('Tình trạng nuôi dưỡng'), findsOneWidget);
      expect(find.text('Hồ sơ trẻ'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(EditableText), findsNothing);
    });
  });
}
