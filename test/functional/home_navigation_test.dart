import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  group('Home navigation functional test', () {
    testWidgets('home shows user information and all module menus', (
      tester,
    ) async {
      await _pumpTallHome(tester);

      expect(find.text('Sorak Mam Non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(find.text('Role: PRINCIPAL'), findsOneWidget);

      for (final module in _homeModules) {
        expect(find.text(module.menuTitle), findsOneWidget);
      }
    });

    for (final module in _homeModules) {
      testWidgets('opens ${module.listTitle} from home menu', (tester) async {
        await _pumpTallHome(tester);

        await tester.ensureVisible(find.text(module.menuTitle));
        await tester.tap(find.text(module.menuTitle));
        await tester.pumpAndSettle();

        expect(find.text(module.listTitle), findsOneWidget);
        expect(find.byTooltip('Refresh'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    }
  });
}

Future<void> _pumpTallHome(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpLoggedInSorakApp();
}

const _homeModules = [
  _HomeModule(menuTitle: 'Academic Years', listTitle: 'Academic Years'),
  _HomeModule(menuTitle: 'Classes', listTitle: 'Classes'),
  _HomeModule(menuTitle: 'Teachers', listTitle: 'Teachers'),
  _HomeModule(menuTitle: 'Students', listTitle: 'Students'),
  _HomeModule(menuTitle: 'Accounts', listTitle: 'Accounts'),
  _HomeModule(menuTitle: 'Class Transfer', listTitle: 'Class Transfers'),
  _HomeModule(menuTitle: 'Outgoing Transfer', listTitle: 'Outgoing Transfers'),
  _HomeModule(menuTitle: 'Incoming Transfer', listTitle: 'Incoming Transfers'),
];

class _HomeModule {
  const _HomeModule({required this.menuTitle, required this.listTitle});

  final String menuTitle;
  final String listTitle;
}
