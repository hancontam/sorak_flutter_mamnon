import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/health/screens/health_screen.dart';

import 'helpers/test_app.dart';

void main() {
  group('Health layout regression', () {
    testWidgets(
      'small viewport: Health uses SafeArea and scroll padding for roster',
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
        // Health screen shows roster entry only.
        expect(find.text('Nuôi dưỡng'), findsNothing);
        expect(find.text('Tăng trưởng'), findsNothing);

        final listViews = tester.widgetList<ListView>(find.byType(ListView));
        final healthList = listViews.firstWhere((view) {
          final padding = view.padding?.resolve(TextDirection.ltr);
          return padding != null && padding.bottom > 16;
        }, orElse: () => listViews.first);
        final padding = healthList.padding?.resolve(TextDirection.ltr);
        expect(padding, isNotNull);
        // Dynamic bottom padding must clear nav + safe inset (not a tiny fixed pad).
        expect(padding!.bottom, greaterThan(40));

        // Roster last student remains scrollable into view on small screen.
        await _selectMam1A(tester);
        expect(find.text('Nguyễn Minh An'), findsWidgets);

        await tester.tap(find.text('Nguyễn Minh An').first);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('health_roster_save_button')),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Lưu sức khỏe'));
        await tester.pumpAndSettle();
        expect(find.text('Lưu sức khỏe'), findsOneWidget);
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
