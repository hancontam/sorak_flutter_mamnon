import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/nutrition_assessment.dart';

class NutritionAssessmentRepository
    implements CrudRepository<NutritionAssessment> {
  NutritionAssessmentRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  final int _defaultSchoolYearId = 1;
  final String _defaultPeriod = 'dau_nam';

  final List<NutritionAssessment> _mockItems = [
    const NutritionAssessment(
      id: 1,
      studentId: 1,
      classId: 1,
      schoolYearId: 1,
      period: 'dau_nam',
      studentName: 'Nguyen Minh An',
      studentCode: 'NBA2024.001',
      className: 'Mam 1A',
      latestBmi: 15.86,
      latestBmiStatus: 'Binh thuong',
      note: 'Eat well at school',
    ),
    const NutritionAssessment(
      id: 2,
      studentId: 2,
      classId: 2,
      schoolYearId: 1,
      period: 'dau_nam',
      studentName: 'Tran Bao Ngoc',
      studentCode: 'TBN2024.002',
      className: 'Choi 2B',
      weightChannel: 'Can nang cao hon tuoi',
      isObese: true,
      latestBmi: 17.8,
      latestBmiStatus: 'Can theo doi',
      note: 'Need parent follow up',
    ),
  ];

  @override
  Future<List<NutritionAssessment>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.nutritionAssessments}/grid-all',
      queryParameters: {
        'school_year_id': _defaultSchoolYearId,
        'period': _defaultPeriod,
      },
    );

    return ApiResponse.list(
      response.data,
    ).map((json) => _fromLiveJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<NutritionAssessment?> getById(int id) async {
    final matches = (await getAll()).where((item) => item.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<NutritionAssessment> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = NutritionAssessment(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        classId: int.tryParse('${data['class_id']}') ?? 0,
        schoolYearId:
            int.tryParse('${data['school_year_id']}') ?? _defaultSchoolYearId,
        period: data['period'] as String? ?? _defaultPeriod,
        studentName: data['student_name'] as String? ?? 'New student',
        studentCode: data['student_code'] as String? ?? '',
        className: data['class_name'] as String? ?? '',
        weightChannel: data['weight_channel'] as String? ?? '',
        isStunting: _readBool(data['is_stunting']),
        isSevereStunting: _readBool(data['is_severe_stunting']),
        isObese: _readBool(data['is_obese']),
        latestBmi: double.tryParse('${data['latest_bmi']}') ?? 0,
        latestBmiStatus: data['latest_bmi_status'] as String? ?? '',
        note: data['note'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

    await _bulkSave(data);
    return NutritionAssessment(
      id: int.tryParse('${data['student_id']}') ?? 0,
      studentId: int.tryParse('${data['student_id']}') ?? 0,
      classId: int.tryParse('${data['class_id']}') ?? 0,
      schoolYearId:
          int.tryParse('${data['school_year_id']}') ?? _defaultSchoolYearId,
      period: data['period'] as String? ?? _defaultPeriod,
      studentName: data['student_name'] as String? ?? '',
      studentCode: data['student_code'] as String? ?? '',
      className: data['class_name'] as String? ?? '',
      weightChannel: data['weight_channel'] as String? ?? '',
      isStunting: _readBool(data['is_stunting']),
      isSevereStunting: _readBool(data['is_severe_stunting']),
      isObese: _readBool(data['is_obese']),
      note: data['note'] as String? ?? '',
    );
  }

  @override
  Future<NutritionAssessment> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        classId: int.tryParse('${data['class_id']}'),
        schoolYearId: int.tryParse('${data['school_year_id']}'),
        period: data['period'] as String?,
        studentName: data['student_name'] as String?,
        studentCode: data['student_code'] as String?,
        className: data['class_name'] as String?,
        weightChannel: data['weight_channel'] as String?,
        isStunting: _readBool(data['is_stunting']),
        isSevereStunting: _readBool(data['is_severe_stunting']),
        isObese: _readBool(data['is_obese']),
        latestBmi: double.tryParse('${data['latest_bmi']}'),
        latestBmiStatus: data['latest_bmi_status'] as String?,
        note: data['note'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    await _bulkSave(data);
    final updated = await getById(id);
    return updated ??
        NutritionAssessment(
          id: id,
          studentId: int.tryParse('${data['student_id']}') ?? id,
          classId: int.tryParse('${data['class_id']}') ?? 0,
          schoolYearId:
              int.tryParse('${data['school_year_id']}') ?? _defaultSchoolYearId,
          period: data['period'] as String? ?? _defaultPeriod,
        );
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    final item = await getById(id);
    if (item == null) {
      return;
    }

    await _apiClient.dio.post(
      '${ApiEndpoints.nutritionAssessments}/bulk',
      data: {
        'class_id': item.classId,
        'school_year_id': item.schoolYearId,
        'period': item.period,
        'rows': [
          {
            'student_id': item.studentId,
            'weight_channel': null,
            'is_stunting': false,
            'is_severe_stunting': false,
            'is_obese': false,
            'note': null,
          },
        ],
      },
    );
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
    }
  }

  Future<void> _bulkSave(Map<String, dynamic> data) async {
    await _apiClient.dio.post(
      '${ApiEndpoints.nutritionAssessments}/bulk',
      data: {
        'class_id': int.tryParse('${data['class_id']}'),
        'school_year_id':
            int.tryParse('${data['school_year_id']}') ?? _defaultSchoolYearId,
        'period': data['period'] ?? _defaultPeriod,
        'rows': [
          {
            'student_id': int.tryParse('${data['student_id']}'),
            'weight_channel': _emptyToNull(data['weight_channel']),
            'is_stunting': _readBool(data['is_stunting']),
            'is_severe_stunting': _readBool(data['is_severe_stunting']),
            'is_obese': _readBool(data['is_obese']),
            'note': _emptyToNull(data['note']),
          },
        ],
      },
    );
  }

  NutritionAssessment _fromLiveJson(Map<String, dynamic> json) {
    return NutritionAssessment.fromJson({
      ...json,
      'school_year_id': _defaultSchoolYearId,
      'period': _defaultPeriod,
    });
  }

  bool _readBool(dynamic value) {
    final text = '$value'.trim().toLowerCase();
    return value == true || text == 'true' || text == '1' || text == 'yes';
  }

  Object? _emptyToNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = '$value'.trim();
    return text.isEmpty || text == 'none' ? null : text;
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }
}
