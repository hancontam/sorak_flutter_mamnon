import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/health_assessment.dart';

class HealthAssessmentRepository implements CrudRepository<HealthAssessment> {
  HealthAssessmentRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<HealthAssessment> _mockItems = [
    const HealthAssessment(
      id: 1,
      studentId: 1,
      classId: 1,
      schoolYearId: 1,
      assessmentDate: '2026-07-09',
      heightCm: 102,
      weightKg: 16.5,
      studentName: 'Nguyen Minh An',
      studentCode: 'NBA2024.001',
      className: 'Mam 1A',
      schoolYearName: '2025-2026',
      bmi: 15.86,
      bmiStatus: 'Binh thuong',
      heightStatus: 'Binh thuong',
      weightStatus: 'Binh thuong',
      note: 'Healthy today',
    ),
    const HealthAssessment(
      id: 2,
      studentId: 2,
      classId: 2,
      schoolYearId: 1,
      assessmentDate: '2026-07-09',
      heightCm: 109,
      weightKg: 18.2,
      studentName: 'Tran Bao Ngoc',
      studentCode: 'TBN2024.002',
      className: 'Choi 2B',
      schoolYearName: '2025-2026',
      bmi: 15.32,
      bmiStatus: 'Binh thuong',
      heightStatus: 'Binh thuong',
      weightStatus: 'Binh thuong',
    ),
  ];

  @override
  Future<List<HealthAssessment>> getAll({int? schoolYearId}) async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(
      ApiEndpoints.healthAssessments,
      queryParameters: {
        'school_year_id': ?schoolYearId,
      },
    );
    return _readList(response.data)
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Roster prefill for one class + assessment date.
  /// Live: GET /health-assessments/by-class-date
  Future<List<HealthAssessment>> getByClassDate({
    required int classId,
    required String assessmentDate,
  }) async {
    if (AppConfig.useMockApi) {
      return _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                item.classId == classId &&
                item.assessmentDate.startsWith(assessmentDate),
          )
          .toList();
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/by-class-date',
      queryParameters: {
        'class_id': classId,
        'assessment_date': assessmentDate,
      },
    );
    return ApiResponse.list(response.data)
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Roster bulk upsert. Live: POST /health-assessments/bulk
  /// [schoolYearId] must come from ActiveAcademicYearProvider — no silent fallback.
  Future<Map<String, dynamic>> bulkSave({
    required int schoolYearId,
    required int classId,
    required String assessmentDate,
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
          'assessment_date': assessmentDate,
        });
      }
      return {
        'created': rows.length,
        'updated': 0,
        'skipped': 0,
        'errors': <dynamic>[],
      };
    }

    final response = await _apiClient.dio.post(
      '${ApiEndpoints.healthAssessments}/bulk',
      data: {
        'school_year_id': schoolYearId,
        'class_id': classId,
        'assessment_date': assessmentDate,
        'rows': rows.map(_liveBulkRow).toList(),
      },
    );
    return ApiResponse.object(response.data);
  }

  @override
  Future<HealthAssessment?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/$id',
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<HealthAssessment> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = HealthAssessment(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        classId: int.tryParse('${data['class_id']}') ?? 0,
        schoolYearId: int.tryParse('${data['school_year_id']}') ?? 0,
        assessmentDate: data['assessment_date'] as String,
        heightCm: double.tryParse('${data['height_cm']}') ?? 0,
        weightKg: double.tryParse('${data['weight_kg']}') ?? 0,
        studentName: data['student_name'] as String? ?? 'New student',
        studentCode: data['student_code'] as String? ?? '',
        className: data['class_name'] as String? ?? '',
        schoolYearName: data['school_year_name'] as String? ?? '2025-2026',
        bmi: _calculateBmi(data['height_cm'], data['weight_kg']),
        bmiStatus: 'Binh thuong',
        heightStatus: 'Binh thuong',
        weightStatus: 'Binh thuong',
        note: data['note'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.healthAssessments,
      data: _liveCreatePayload(data),
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<HealthAssessment> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        assessmentDate: data['assessment_date'] as String?,
        heightCm: double.tryParse('${data['height_cm']}'),
        weightKg: double.tryParse('${data['weight_kg']}'),
        note: data['note'] as String?,
      );
      _mockItems[index] = item.copyWith(
        bmi: _calculateBmi(item.heightCm, item.weightKg),
      );
      return _mockItems[index];
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.healthAssessments}/$id',
      data: _liveUpdatePayload(data),
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  /// Live DELETE is hard delete (backend has no soft archive).
  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.healthAssessments}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }
    throw StateError('Backend không hỗ trợ khôi phục đánh giá sức khỏe');
  }

  List<dynamic> _readList(dynamic body) {
    final direct = ApiResponse.list(body);
    if (direct.isNotEmpty) {
      return direct;
    }
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['rows'] ?? data['data'];
        if (items is List) {
          return items;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _liveCreatePayload(Map<String, dynamic> data) {
    final schoolYearId = int.tryParse('${data['school_year_id']}');
    if (schoolYearId == null) {
      throw StateError('Chưa chọn năm học');
    }
    return {
      'student_id': int.tryParse('${data['student_id']}'),
      'school_year_id': schoolYearId,
      'assessment_date': data['assessment_date'],
      'height_cm': double.tryParse('${data['height_cm']}'),
      'weight_kg': double.tryParse('${data['weight_kg']}'),
      'note': data['note'],
    };
  }

  Map<String, dynamic> _liveUpdatePayload(Map<String, dynamic> data) {
    return {
      'assessment_date': data['assessment_date'],
      'height_cm': double.tryParse('${data['height_cm']}'),
      'weight_kg': double.tryParse('${data['weight_kg']}'),
      'note': data['note'],
    };
  }

  Map<String, dynamic> _liveBulkRow(Map<String, dynamic> row) {
    return {
      'student_id': int.tryParse('${row['student_id']}'),
      'height_cm': double.tryParse('${row['height_cm']}'),
      'weight_kg': double.tryParse('${row['weight_kg']}'),
      if (row['note'] != null) 'note': row['note'],
    };
  }

  double _calculateBmi(dynamic heightValue, dynamic weightValue) {
    final heightCm = double.tryParse('$heightValue') ?? 0;
    final weightKg = double.tryParse('$weightValue') ?? 0;
    if (heightCm <= 0 || weightKg <= 0) {
      return 0;
    }
    final heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(2));
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }
}
