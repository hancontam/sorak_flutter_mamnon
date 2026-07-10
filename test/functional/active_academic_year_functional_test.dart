import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/storage/local_storage.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/providers/active_academic_year_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';

import 'helpers/test_app.dart';

void main() {
  group('Active academic year functional test', () {
    test(
      'persists the selected academic year across provider recreation',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final localStorage = LocalStorage(preferences);
        final apiClient = ApiClient.memory();
        final repository = AcademicYearRepository(apiClient: apiClient);

        final firstProvider = ActiveAcademicYearProvider(
          academicYearRepository: repository,
          localStorage: localStorage,
        );
        await firstProvider.loadYears();
        await firstProvider.selectYear(2);

        final restoredProvider = ActiveAcademicYearProvider(
          academicYearRepository: repository,
          localStorage: localStorage,
        );
        await restoredProvider.loadYears();

        expect(restoredProvider.selectedYearId, 2);
        expect(localStorage.getSelectedAcademicYearId(), 2);
      },
    );

    testWidgets('changing AppShell year syncs form options and active list', (
      tester,
    ) async {
      final localStorage = await tester.pumpLoggedInSorakApp();

      await tester.tap(find.byKey(const ValueKey('active_year_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2026-2027').last);
      await tester.pumpAndSettle();

      final shellContext = tester.element(find.byType(AppShell));
      expect(shellContext.read<ActiveAcademicYearProvider>().selectedYearId, 2);
      expect(localStorage.getSelectedAcademicYearId(), 2);
      expect(
        shellContext.read<FormOptionsProvider>().selectedAcademicYearId,
        2,
      );
      expect(shellContext.read<ClassProvider>().items, isEmpty);
    });
  });
}
