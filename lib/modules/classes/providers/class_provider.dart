import '../../../core/providers/crud_provider.dart';
import '../../../core/network/api_exception.dart';
import '../models/school_class.dart';
import '../repositories/class_repository.dart';

class ClassProvider extends CrudProvider<SchoolClass> {
  ClassProvider({required ClassRepository classRepository})
    : _classRepository = classRepository,
      super(repository: classRepository);

  final ClassRepository _classRepository;
  int? _academicYearId;
  String? _classSetupErrorMessage;

  String? get classSetupErrorMessage => _classSetupErrorMessage;

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
    required String room,
    required List<int> teacherAccountIdsToAdd,
    required List<int> teacherIdsToRemove,
  }) async {
    _classSetupErrorMessage = null;
    final updated = await updateItem(classId, {'room': room});
    if (!updated) return false;

    try {
      // Match the web flow: add replacements before removing old assignments.
      for (final accountId in teacherAccountIdsToAdd) {
        await _classRepository.assignTeacher(
          classId: classId,
          accountId: accountId,
        );
      }
      for (final teacherId in teacherIdsToRemove) {
        await _classRepository.removeTeacher(
          classId: classId,
          teacherId: teacherId,
        );
      }
      await loadItems();
      return true;
    } catch (error) {
      _classSetupErrorMessage = apiErrorMessage(error);
      await loadItems();
      return false;
    }
  }
}
