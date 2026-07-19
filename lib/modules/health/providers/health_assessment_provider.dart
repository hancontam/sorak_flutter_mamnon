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
  List<HealthAssessment> _dateFilteredItems = const [];
  bool _isLoadingDateFilter = false;
  String? _dateFilterErrorMessage;
  int _dateFilterRevision = 0;

  int? get rosterClassId => _rosterClassId;
  String? get rosterDate => _rosterDate;
  List<HealthAssessment> get latestByStudent => _latestByStudent;
  bool get isLoadingLatest => _isLoadingLatest;
  List<HealthAssessment> get dateFilteredItems => _dateFilteredItems;
  bool get isLoadingDateFilter => _isLoadingDateFilter;
  String? get dateFilterErrorMessage => _dateFilterErrorMessage;

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

  /// Latest assessment per student (list "Xem đánh giá sức khỏe").
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

  Future<void> loadForDate({
    required String assessmentDate,
    int? schoolYearId,
    int? classId,
  }) async {
    final revision = ++_dateFilterRevision;
    _isLoadingDateFilter = true;
    _dateFilterErrorMessage = null;
    notifyListeners();
    try {
      final items = await _healthAssessmentRepository.getForDate(
        assessmentDate: assessmentDate,
        schoolYearId: schoolYearId ?? _academicYearId,
        classId: classId,
      );
      if (revision != _dateFilterRevision) return;
      _dateFilteredItems = items;
    } catch (error) {
      if (revision != _dateFilterRevision) return;
      _dateFilteredItems = const [];
      _dateFilterErrorMessage = apiErrorMessage(error);
    } finally {
      if (revision == _dateFilterRevision) {
        _isLoadingDateFilter = false;
        notifyListeners();
      }
    }
  }

  void clearDateFilter() {
    _dateFilterRevision++;
    _dateFilteredItems = const [];
    _dateFilterErrorMessage = null;
    _isLoadingDateFilter = false;
    notifyListeners();
  }

  /// Student history for roster "Số đo gần nhất" / history sheet.
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
