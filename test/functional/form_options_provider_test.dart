import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Form options provider functional test', () {
    test('loads dropdown options and filters classes and students', () async {
      final apiClient = await _createApiClient();
      final provider = FormOptionsProvider(
        formOptionsRepository: FormOptionsRepository(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
          classRepository: ClassRepository(apiClient: apiClient),
          teacherRepository: TeacherRepository(apiClient: apiClient),
          studentRepository: StudentRepository(apiClient: apiClient),
        ),
      );

      await provider.loadInitialOptions();

      expect(provider.errorMessage, isNull);
      expect(provider.academicYearOptions, isNotEmpty);
      expect(provider.classOptions, isNotEmpty);
      expect(provider.workingTeacherOptions, isNotEmpty);
      expect(provider.studentOptions, isNotEmpty);
      expect(provider.selectedAcademicYearId, 1);
      expect(provider.selectedClassId, 2);
      expect(provider.studentOptions.single.label, 'Tran Bao Ngoc');

      await provider.selectClass(1);

      expect(provider.selectedClassId, 1);
      expect(provider.studentOptions.single.label, 'Nguyen Minh An');

      await provider.selectAcademicYear(2);

      expect(provider.selectedAcademicYearId, 2);
      expect(provider.classOptions, isEmpty);
      expect(provider.studentOptions, isNotEmpty);
    });
  });
}

Future<ApiClient> _createApiClient() async {
  return ApiClient.memory();
}
