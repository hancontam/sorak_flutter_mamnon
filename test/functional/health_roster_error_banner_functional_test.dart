import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/models/health_assessment.dart';
import 'package:sorak_flutter_mamnon/modules/health/providers/health_assessment_provider.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/health_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

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
  test(
    'roster API error remains visible while class options keep students',
    () async {
      final apiClient = ApiClient.memory();
      final formOptions = FormOptionsProvider(
        formOptionsRepository: FormOptionsRepository(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
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

      await formOptions.loadInitialOptions();
      await formOptions.selectClass(301);
      await healthProvider.loadByClassDate(
        classId: 301,
        assessmentDate: '2026-05-10',
      );

      expect(formOptions.students.map((item) => item.fullName), [
        'Nguyễn Minh An',
      ]);
      expect(
        healthProvider.errorMessage,
        contains('Không tải được đánh giá sức khỏe theo lớp'),
      );
      expect(healthProvider.isLoading, isFalse);
    },
  );
}
