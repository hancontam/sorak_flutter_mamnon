import '../../../core/providers/crud_provider.dart';
import '../models/teacher.dart';
import '../repositories/teacher_repository.dart';

class TeacherProvider extends CrudProvider<Teacher> {
  TeacherProvider({required TeacherRepository teacherRepository})
    : _teacherRepository = teacherRepository,
      super(repository: teacherRepository);

  final TeacherRepository _teacherRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _teacherRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(() => _teacherRepository.getAll(schoolYearId: yearId));
  }
}
