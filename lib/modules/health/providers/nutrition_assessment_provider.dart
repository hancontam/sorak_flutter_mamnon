import '../../../core/providers/crud_provider.dart';
import '../models/nutrition_assessment.dart';
import '../repositories/nutrition_assessment_repository.dart';

class NutritionAssessmentProvider extends CrudProvider<NutritionAssessment> {
  NutritionAssessmentProvider({
    required NutritionAssessmentRepository nutritionAssessmentRepository,
  }) : _nutritionAssessmentRepository = nutritionAssessmentRepository,
       super(repository: nutritionAssessmentRepository);

  final NutritionAssessmentRepository _nutritionAssessmentRepository;
  int? _academicYearId;
  int? _gridClassId;
  String _gridPeriod = 'dau_nam';

  int? get gridClassId => _gridClassId;
  String get gridPeriod => _gridPeriod;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _nutritionAssessmentRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId, {String? period}) {
    _academicYearId = yearId;
    if (period != null) {
      _gridPeriod = period;
    }
    return loadItemsWith(
      () => _nutritionAssessmentRepository.getAll(
        schoolYearId: yearId,
        period: _gridPeriod,
      ),
    );
  }

  /// Load class-scoped nutrition grid (preferred for roster).
  Future<void> loadGrid({
    required int classId,
    required int schoolYearId,
    required String period,
  }) {
    _academicYearId = schoolYearId;
    _gridClassId = classId;
    _gridPeriod = period;
    return loadItemsWith(
      () => _nutritionAssessmentRepository.getGrid(
        classId: classId,
        schoolYearId: schoolYearId,
        period: period,
      ),
    );
  }

  /// Bulk save nutrition rows for class+period.
  Future<bool> bulkSaveGrid({
    required int classId,
    required int schoolYearId,
    required String period,
    required List<Map<String, dynamic>> rows,
  }) async {
    try {
      await _nutritionAssessmentRepository.bulkSave(
        classId: classId,
        schoolYearId: schoolYearId,
        period: period,
        rows: rows,
      );
      await loadGrid(
        classId: classId,
        schoolYearId: schoolYearId,
        period: period,
      );
      return true;
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      await loadItemsWith(() async {
        throw Exception(message);
      });
      return false;
    }
  }
}
