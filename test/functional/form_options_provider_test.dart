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
      expect(provider.selectedAcademicYearId, 101);
      expect(provider.selectedClassId, 301);
      expect(provider.studentOptions.single.label, 'Nguyễn Minh An');

      await provider.selectClass(302);

      expect(provider.selectedClassId, 302);
      expect(provider.studentOptions.single.label, 'Trần Bảo Ngọc');

      await provider.selectAcademicYear(103);

      expect(provider.selectedAcademicYearId, 103);
      expect(provider.classOptions, isEmpty);
      expect(provider.studentOptions, isEmpty);
    });
  });
}

Future<ApiClient> _createApiClient() async {
  return ApiClient.memory();
}
