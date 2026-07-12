import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/models/academic_year.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/providers/academic_year_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/screens/academic_year_form_screen.dart';

void main() {
  testWidgets('active academic year shows the student promotion flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final apiClient = ApiClient.memory();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AcademicYearProvider(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
        ),
        child: const MaterialApp(
          home: AcademicYearFormScreen(
            academicYear: AcademicYear(
              id: 102,
              name: '2025-2026',
              startDate: '2025-09-01',
              endDate: '2026-05-31',
              status: 'active',
            ),
          ),
        ),
      ),
    );

    final promoteButton = find.byKey(const ValueKey('promote_students_button'));
    await tester.scrollUntilVisible(
      promoteButton,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(promoteButton);
    await tester.pumpAndSettle();

    expect(find.text('Lên lớp học sinh?'), findsOneWidget);
    expect(find.text('Nhà trẻ'), findsOneWidget);
    expect(find.text('Mầm'), findsNWidgets(2));
    expect(find.text('Chồi'), findsNWidgets(2));
    expect(find.text('Lá'), findsNWidgets(2));
    expect(find.text('Tốt nghiệp'), findsOneWidget);
    expect(find.text('Lên lớp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive academic year does not show promotion action', (
    tester,
  ) async {
    final apiClient = ApiClient.memory();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AcademicYearProvider(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
        ),
        child: const MaterialApp(
          home: AcademicYearFormScreen(
            academicYear: AcademicYear(
              id: 103,
              name: '2026-2027',
              startDate: '2026-09-01',
              endDate: '2027-05-31',
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('promote_students_button')), findsNothing);
  });
}
