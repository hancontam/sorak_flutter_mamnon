import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/health/screens/health_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health layout regression (Goal 37)', () {
    testWidgets(
      'small viewport: Health uses SafeArea, scroll padding, no fixed Growth height',
      (tester) async {
        // Phone-sized surface where NavigationBar often occludes content.
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpLoggedInSorakApp();

        final shellContext = tester.element(find.byType(AppShell));
        Navigator.of(shellContext).pushNamed('/health');
        await tester.pumpAndSettle();

        expect(find.byType(HealthScreen), findsOneWidget);
        expect(find.byType(SafeArea), findsWidgets);

        final listViews = tester.widgetList<ListView>(find.byType(ListView));
        final healthList = listViews.firstWhere(
          (view) {
            final padding = view.padding?.resolve(TextDirection.ltr);
            return padding != null && padding.bottom > 16;
          },
          orElse: () => listViews.first,
        );
        final padding = healthList.padding?.resolve(TextDirection.ltr);
        expect(padding, isNotNull);
        // Dynamic bottom padding must clear nav + safe inset (not a tiny fixed pad).
        expect(padding!.bottom, greaterThan(40));

        // No fixed 720 height trap for Growth-in-Health.
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        expect(
          sizedBoxes.any((box) => box.height == 720),
          isFalse,
          reason: 'Growth must not use SizedBox(height: 720) inside Health',
        );

        // Roster last student remains scrollable into view on small screen.
        await _selectMam1A(tester);
        expect(find.text('Nguyen Minh An'), findsOneWidget);

        await tester.tap(find.text('Nguyen Minh An'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('health_roster_save_button')), findsOneWidget);
        await tester.ensureVisible(find.text('Lưu sức khỏe'));
        await tester.pumpAndSettle();
        expect(find.text('Lưu sức khỏe'), findsOneWidget);

        // Dismiss bottom sheet via navigator pop so Growth tab is reachable.
        Navigator.of(tester.element(find.text('Lưu sức khỏe'))).pop();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tăng trưởng'));
        await tester.pumpAndSettle();
        expect(find.text('Tăng trưởng WHO'), findsWidgets);
        expect(
          tester.widgetList<SizedBox>(find.byType(SizedBox)).any(
            (box) => box.height == 720,
          ),
          isFalse,
        );
      },
    );
  });
}

Future<void> _selectMam1A(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mam 1A - A101').last);
  await tester.pumpAndSettle();
}
