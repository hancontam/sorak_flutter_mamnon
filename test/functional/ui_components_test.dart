import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sorak_flutter_mamnon/core/theme/app_colors.dart';
import 'package:sorak_flutter_mamnon/core/theme/app_spacing.dart';
import 'package:sorak_flutter_mamnon/core/theme/app_theme.dart';
import 'package:sorak_flutter_mamnon/core/widgets/sorak_avatar.dart';
import 'package:sorak_flutter_mamnon/core/widgets/sorak_toggle_group.dart';

import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('UI component regression', () {
    testWidgets('locks theme tokens and Montserrat radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(
                      theme.textTheme.bodyMedium?.fontFamily ?? '',
                      key: const ValueKey('font_family_probe'),
                    ),
                    FilledButton(
                      key: const ValueKey('destructive_button_probe'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                      ),
                      onPressed: () {},
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(AppColors.primary, const Color(0xFFC96442));
      expect(AppColors.error, AppColors.destructive);
      expect(AppColors.warning, AppColors.chartNeutral);
      expect(AppSpacing.radius, 8);
      expect(find.textContaining('Montserrat'), findsOneWidget);

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('destructive_button_probe')),
      );
      final background = button.style?.backgroundColor?.resolve({});
      expect(background, AppColors.destructive);
    });

    testWidgets('avatar falls back safely in tests and toggle changes value', (
      tester,
    ) async {
      var selected = 'staff';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    const SorakAvatar(seed: 101, fallbackLabel: 'An'),
                    SorakToggleGroup<String>(
                      options: const [
                        SorakToggleOption(
                          value: 'staff',
                          label: 'Cán bộ',
                          icon: LucideIcons.badgeCheck,
                        ),
                        SorakToggleOption(
                          value: 'student',
                          label: 'Học sinh',
                          icon: LucideIcons.users,
                        ),
                      ],
                      selected: selected,
                      onChanged: (value) => setState(() => selected = value),
                    ),
                    Text(selected, key: const ValueKey('selected_probe')),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('staff'), findsOneWidget);

      await tester.tap(find.text('Học sinh'));
      await tester.pumpAndSettle();

      expect(find.text('student'), findsOneWidget);
    });

    testWidgets('academic year AppBar selector opens and selects year', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpSorakApp(savedUser: testAuthUser);
      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('active_year_dropdown')),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('active_year_selector_surface')))
            .width,
        140,
      );
      expect(find.text('2025-2026'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('active_year_dropdown')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('academic_year_option_101')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('academic_year_option_102')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('academic_year_option_102')),
        findsNothing,
      );
    });
  });
}
