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

  int? get rosterClassId => _rosterClassId;
  String? get rosterDate => _rosterDate;

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
