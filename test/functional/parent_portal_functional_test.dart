import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';

void main() {
  group('Parent Portal functional test', () {
    testWidgets('Parent sees child report view only without unsupported tabs', (
      tester,
    ) async {
      const parentUser = AuthUser(
        id: 1101,
        fullName: 'Nguyễn Minh An',
        email: '',
        role: 'PARENT',
      );

      await tester.binding.setSurfaceSize(const Size(400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpSorakApp(savedUser: parentUser);

      expect(find.text('Báo cáo của trẻ'), findsWidgets);
      expect(find.text('Chỉ xem'), findsWidgets);
      expect(find.text('Mã trẻ'), findsOneWidget);
      expect(find.text('Nguyễn Minh An'), findsWidgets);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(EditableText), findsNothing);
      expect(
        find.byKey(const ValueKey('parent_api_unavailable')),
        findsNothing,
      );
      expect(find.text('Tình trạng sức khỏe'), findsNothing);
      expect(find.text('Tình trạng nuôi dưỡng'), findsNothing);
      expect(find.text('Lịch sử khám sức khỏe'), findsOneWidget);
      expect(find.text('10/05/2026'), findsOneWidget);
      expect(find.text('10/01/2026'), findsOneWidget);
    });
  });
}
