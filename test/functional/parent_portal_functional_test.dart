import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';

import 'helpers/test_app.dart';

void main() {
  group('Parent Portal functional test', () {
    testWidgets(
      'Parent sees child profile health nutrition and growth view only',
      (tester) async {
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

        expect(find.text('Parent Portal'), findsOneWidget);
        expect(find.text('View only'), findsWidgets);
        expect(find.text('Child profile'), findsOneWidget);
        expect(find.text('Nguyen Minh An'), findsWidgets);
        expect(find.text('Health status'), findsOneWidget);
        expect(find.text('Nutrition status'), findsOneWidget);

        await tester.drag(find.byType(ListView).first, const Offset(0, -650));
        await tester.pumpAndSettle();

        expect(find.text('Growth WHO view-only'), findsOneWidget);
        expect(
          find.text(
            'This portal is read-only. Please contact the school if any information looks incorrect.',
          ),
          findsOneWidget,
        );
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byType(EditableText), findsNothing);
      },
    );
  });
}
