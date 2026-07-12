import '../../../core/providers/crud_provider.dart';
import '../models/academic_year.dart';
import '../repositories/academic_year_repository.dart';

class AcademicYearProvider extends CrudProvider<AcademicYear> {
  AcademicYearProvider({required AcademicYearRepository academicYearRepository})
    : _academicYearRepository = academicYearRepository,
      super(repository: academicYearRepository);

  final AcademicYearRepository _academicYearRepository;

  Future<void> activateYear(int id) async {
    await _academicYearRepository.activate(id);
    await loadItems();
  }

  Future<Map<String, dynamic>> promoteStudents(int id) async {
    final result = await _academicYearRepository.promoteStudents(id);
    await loadItems();
    return result;
  }
}
