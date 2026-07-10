import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/storage/local_storage.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/providers/active_academic_year_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/models/health_assessment.dart';
import 'package:sorak_flutter_mamnon/modules/health/providers/health_assessment_provider.dart';
import 'package:sorak_flutter_mamnon/modules/health/providers/nutrition_assessment_provider.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/health_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/nutrition_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/screens/health_roster_dashboard.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

/// Fails roster prefill while FormOptions still returns class students.
class _FailingByClassDateRepository extends HealthAssessmentRepository {
  _FailingByClassDateRepository({required super.apiClient});

  @override
  Future<List<HealthAssessment>> getByClassDate({
    required int classId,
    required String assessmentDate,
  }) async {
    throw Exception('Không tải được đánh giá sức khỏe theo lớp');
  }
}

void main() {
  group('Health roster error banner', () {
    testWidgets(
      'shows by-class-date load error even when class still has students',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final localStorage = LocalStorage(prefs);
        final apiClient = ApiClient.memory();

        final formOptions = FormOptionsProvider(
          formOptionsRepository: FormOptionsRepository(
            academicYearRepository: AcademicYearRepository(
              apiClient: apiClient,
            ),
            classRepository: ClassRepository(apiClient: apiClient),
            teacherRepository: TeacherRepository(apiClient: apiClient),
            studentRepository: StudentRepository(apiClient: apiClient),
          ),
        );
        final healthProvider = HealthAssessmentProvider(
          healthAssessmentRepository: _FailingByClassDateRepository(
            apiClient: apiClient,
          ),
        );
        final nutritionProvider = NutritionAssessmentProvider(
          nutritionAssessmentRepository: NutritionAssessmentRepository(
            apiClient: apiClient,
          ),
        );
        final yearProvider = ActiveAcademicYearProvider(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
          localStorage: localStorage,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: formOptions),
              ChangeNotifierProvider.value(value: healthProvider),
              ChangeNotifierProvider.value(value: nutritionProvider),
              ChangeNotifierProvider.value(value: yearProvider),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: HealthRosterDashboard(mode: HealthRosterMode.health),
                ),
              ),
            ),
          ),
        );

        await yearProvider.loadYears();
        await formOptions.loadInitialOptions();
        await tester.pumpAndSettle();

        // Class students still available from FormOptions (Mam 1A has An).
        expect(formOptions.classes, isNotEmpty);
        expect(formOptions.allStudents, isNotEmpty);

        // Select Mam 1A so dashboard reloads roster via getByClassDate (fails).
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mam 1A - A101').last);
        await tester.pumpAndSettle();

        // Error must be visible even though students list is non-empty.
        expect(find.byKey(const Key('health_roster_error_banner')), findsOneWidget);
        expect(
          find.textContaining('Không tải được đánh giá sức khỏe theo lớp'),
          findsOneWidget,
        );
        expect(find.text('Thử lại'), findsOneWidget);
        // Students still listed under the banner (not replaced by empty-only error).
        expect(find.text('Nguyen Minh An'), findsOneWidget);
        expect(healthProvider.errorMessage, isNotNull);
      },
    );
  });
}
