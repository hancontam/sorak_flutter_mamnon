import '../../../core/providers/crud_provider.dart';
import '../../../core/network/api_exception.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';

class StudentProvider extends CrudProvider<Student> {
  StudentProvider({required StudentRepository studentRepository})
    : _studentRepository = studentRepository,
      super(repository: studentRepository);

  final StudentRepository _studentRepository;
  int? _academicYearId;
  bool _isSavingParents = false;
  String? _parentsErrorMessage;

  bool get isSavingParents => _isSavingParents;
  String? get parentsErrorMessage => _parentsErrorMessage;

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

  Future<bool> updateParents(
    int studentId,
    List<Map<String, dynamic>> parents,
  ) async {
    _isSavingParents = true;
    _parentsErrorMessage = null;
    notifyListeners();
    try {
      await _studentRepository.updateParents(studentId, parents);
      await loadItems();
      return true;
    } catch (error) {
      _parentsErrorMessage = apiErrorMessage(error);
      return false;
    } finally {
      _isSavingParents = false;
      notifyListeners();
    }
  }
}
