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

  Future<bool> updateClassSetup({
    required int classId,
    required String schoolYearId,
    required String room,
    required List<int> teacherAccountIdsToAdd,
    required List<int> teacherIdsToRemove,
  }) async {
    final updated = await updateItem(classId, {
      'school_year_id': schoolYearId,
      'room': room,
    });
    if (!updated) return false;

    try {
      for (final teacherId in teacherIdsToRemove) {
        await _classRepository.removeTeacher(
          classId: classId,
          teacherId: teacherId,
        );
      }
      for (final accountId in teacherAccountIdsToAdd) {
        await _classRepository.assignTeacher(
          classId: classId,
          accountId: accountId,
        );
      }
      await loadItems();
      return true;
    } catch (_) {
      await loadItems();
      return false;
    }
  }
}
