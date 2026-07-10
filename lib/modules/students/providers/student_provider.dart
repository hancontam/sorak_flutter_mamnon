import '../../../core/providers/crud_provider.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';

class StudentProvider extends CrudProvider<Student> {
  StudentProvider({required StudentRepository studentRepository})
    : _studentRepository = studentRepository,
      super(repository: studentRepository);

  final StudentRepository _studentRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _studentRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(() => _studentRepository.getAll(schoolYearId: yearId));
  }
}
