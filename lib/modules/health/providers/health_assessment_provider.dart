import '../../../core/providers/crud_provider.dart';
import '../../../core/network/api_exception.dart';
import '../models/health_assessment.dart';
import '../repositories/health_assessment_repository.dart';

class HealthAssessmentProvider extends CrudProvider<HealthAssessment> {
  HealthAssessmentProvider({
    required HealthAssessmentRepository healthAssessmentRepository,
  }) : _healthAssessmentRepository = healthAssessmentRepository,
       super(repository: healthAssessmentRepository);

  final HealthAssessmentRepository _healthAssessmentRepository;
  int? _academicYearId;
  int? _rosterClassId;
  String? _rosterDate;
  List<HealthAssessment> _latestByStudent = const [];
  bool _isLoadingLatest = false;

  int? get rosterClassId => _rosterClassId;
  String? get rosterDate => _rosterDate;
  List<HealthAssessment> get latestByStudent => _latestByStudent;
  bool get isLoadingLatest => _isLoadingLatest;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _healthAssessmentRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(
      () => _healthAssessmentRepository.getAll(schoolYearId: yearId),
    );
  }

  /// Load roster via by-class-date for the Health tab.
  Future<void> loadByClassDate({
    required int classId,
    required String assessmentDate,
  }) {
    _rosterClassId = classId;
    _rosterDate = assessmentDate;
    return loadItemsWith(
      () => _healthAssessmentRepository.getByClassDate(
        classId: classId,
        assessmentDate: assessmentDate,
      ),
    );
  }

  /// Load latest assessment per student for the history list screen.
  Future<void> loadLatest({int? schoolYearId}) async {
    _isLoadingLatest = true;
    notifyListeners();
    try {
      _latestByStudent = await _healthAssessmentRepository.getLatest(
        schoolYearId: schoolYearId ?? _academicYearId,
      );
    } catch (_) {
      _latestByStudent = const [];
    } finally {
      _isLoadingLatest = false;
      notifyListeners();
    }
  }

  Future<List<HealthAssessment>> getStudentHistory({
    required int studentId,
    int? schoolYearId,
  }) {
    return _healthAssessmentRepository.getHistory(
      studentId: studentId,
      schoolYearId: schoolYearId ?? _academicYearId,
    );
  }

  /// Save one or more roster rows via bulk (not single POST).
  /// Returns false and sets errorMessage when year is missing or request fails.
  Future<bool> bulkSaveRoster({
    required int schoolYearId,
    required int classId,
    required String assessmentDate,
    required List<Map<String, dynamic>> rows,
  }) async {
    try {
      await _healthAssessmentRepository.bulkSave(
        schoolYearId: schoolYearId,
        classId: classId,
        assessmentDate: assessmentDate,
        rows: rows,
      );
      await loadByClassDate(classId: classId, assessmentDate: assessmentDate);
      return true;
    } catch (error) {
      // Surface error via CrudProvider without inventing archive semantics.
      final message = apiErrorMessage(error);
      await loadItemsWith(() async {
        throw Exception(message);
      });
      return false;
    }
  }
}
