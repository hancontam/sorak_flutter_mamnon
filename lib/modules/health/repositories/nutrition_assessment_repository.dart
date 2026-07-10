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

  /// Year-wide list via grid-all. Prefer [getGrid] for roster class flow.
  @override
  Future<List<NutritionAssessment>> getAll({
    int? schoolYearId,
    String? period,
  }) async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    if (schoolYearId == null) {
      throw StateError('Chưa chọn năm học');
    }
    final selectedPeriod = period ?? _defaultPeriod;
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.nutritionAssessments}/grid-all',
      queryParameters: {
        'school_year_id': schoolYearId,
        'period': selectedPeriod,
      },
    );

    return ApiResponse.list(response.data).map((json) {
      return _fromLiveJson(
        json as Map<String, dynamic>,
        schoolYearId: schoolYearId,
        period: selectedPeriod,
      );
    }).toList();
  }

  /// Class roster grid. Live: GET /nutrition-assessments/grid
  Future<List<NutritionAssessment>> getGrid({
    required int classId,
    required int schoolYearId,
    required String period,
  }) async {
    if (AppConfig.useMockApi) {
      return _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                item.classId == classId &&
                item.period == period,
          )
          .toList();
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.nutritionAssessments}/grid',
      queryParameters: {
        'class_id': classId,
        'school_year_id': schoolYearId,
        'period': period,
      },
    );

    return ApiResponse.list(response.data).map((json) {
      return _fromLiveJson(
        json as Map<String, dynamic>,
        schoolYearId: schoolYearId,
        period: period,
        classId: classId,
      );
    }).toList();
  }

  /// Bulk upsert for class+period. Live: POST /nutrition-assessments/bulk
  Future<Map<String, dynamic>> bulkSave({
    required int classId,
    required int schoolYearId,
    required String period,
    required List<Map<String, dynamic>> rows,
  }) async {
    if (rows.isEmpty) {
      throw StateError('Cần ít nhất một dòng đánh giá');
    }

    if (AppConfig.useMockApi) {
      for (final row in rows) {
        await create({
          ...row,
          'class_id': classId,
          'school_year_id': schoolYearId,
          'period': period,
        });
      }
      return {'saved': rows.length, 'cleared': 0, 'skipped': 0};
    }

    final response = await _apiClient.dio.post(
      '${ApiEndpoints.nutritionAssessments}/bulk',
      data: {
        'class_id': classId,
        'school_year_id': schoolYearId,
        'period': period,
        'rows': rows.map(_liveBulkRow).toList(),
      },
    );
    return ApiResponse.object(response.data);
  }

  @override
  Future<NutritionAssessment?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }
    // Live backend has no GET-by-id; only grid/grid-all.
    return null;
  }

  @override
  Future<NutritionAssessment> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = NutritionAssessment(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        classId: int.tryParse('${data['class_id']}') ?? 0,
        schoolYearId: int.tryParse('${data['school_year_id']}') ?? 0,
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

    final classId = int.tryParse('${data['class_id']}');
    final schoolYearId = _requiredSchoolYearId(data);
    final period = data['period'] as String? ?? _defaultPeriod;
    if (classId == null) {
      throw StateError('Chưa chọn lớp');
    }

    await bulkSave(
      classId: classId,
      schoolYearId: schoolYearId,
      period: period,
      rows: [data],
    );

    return NutritionAssessment(
      id: int.tryParse('${data['student_id']}') ?? 0,
      studentId: int.tryParse('${data['student_id']}') ?? 0,
      classId: classId,
      schoolYearId: schoolYearId,
      period: period,
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

    final classId = int.tryParse('${data['class_id']}');
    final schoolYearId = _requiredSchoolYearId(data);
    final period = data['period'] as String? ?? _defaultPeriod;
    if (classId == null) {
      throw StateError('Chưa chọn lớp');
    }

    await bulkSave(
      classId: classId,
      schoolYearId: schoolYearId,
      period: period,
      rows: [
        {
          ...data,
          'student_id': data['student_id'] ?? id,
        },
      ],
    );

    return NutritionAssessment(
      id: id,
      studentId: int.tryParse('${data['student_id']}') ?? id,
      classId: classId,
      schoolYearId: schoolYearId,
      period: period,
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

  /// Backend has no DELETE/archive for nutrition. Mock soft-hides only.
  /// Live intentionally fails so UI never fakes bulk-clear as Delete.
  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      }
      return;
    }

    throw StateError(
      'Backend không hỗ trợ xóa đánh giá nuôi dưỡng. '
      'Hãy xóa bằng cách lưu hàng trống trên grid (bulk).',
    );
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      }
      return;
    }
    throw StateError('Backend không hỗ trợ khôi phục đánh giá nuôi dưỡng');
  }

  NutritionAssessment _fromLiveJson(
    Map<String, dynamic> json, {
    required int schoolYearId,
    required String period,
    int? classId,
  }) {
    return NutritionAssessment.fromJson({
      ...json,
      'school_year_id': schoolYearId,
      'period': period,
      'class_id': ?classId,
      'student_name': json['student_name'] ?? json['full_name'] ?? '',
      'student_code':
          json['student_code'] ?? json['student_id_card_number'] ?? '',
      'latest_bmi': json['latest_bmi'] ?? 0,
      'latest_bmi_status': json['latest_bmi_status'] ?? '',
      'weight_channel': json['weight_channel'] ?? '',
      'note': json['note'] ?? '',
    });
  }

  Map<String, dynamic> _liveBulkRow(Map<String, dynamic> row) {
    return {
      'student_id': int.tryParse('${row['student_id']}'),
      'weight_channel': _emptyToNull(row['weight_channel']),
      'is_stunting': _readBool(row['is_stunting']),
      'is_severe_stunting': _readBool(row['is_severe_stunting']),
      'is_obese': _readBool(row['is_obese']),
      'note': _emptyToNull(row['note']),
    };
  }

  int _requiredSchoolYearId(Map<String, dynamic> data) {
    final schoolYearId = int.tryParse('${data['school_year_id']}');
    if (schoolYearId == null) {
      throw StateError('Chưa chọn năm học');
    }
    return schoolYearId;
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
