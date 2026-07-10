import '../../../core/providers/crud_provider.dart';
import '../models/school_class.dart';
import '../repositories/class_repository.dart';

class ClassProvider extends CrudProvider<SchoolClass> {
  ClassProvider({required ClassRepository classRepository})
    : _classRepository = classRepository,
      super(repository: classRepository);

  final ClassRepository _classRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _classRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(() => _classRepository.getAll(schoolYearId: yearId));
  }
}
