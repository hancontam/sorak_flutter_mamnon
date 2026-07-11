import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/health_assessment.dart';

class HealthAssessmentRepository implements CrudRepository<HealthAssessment> {
  HealthAssessmentRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<HealthAssessment>> getAll({int? schoolYearId}) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.healthAssessments,
      queryParameters: {'school_year_id': ?schoolYearId},
    );
    return _readList(response.data)
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Roster prefill for one class + assessment date.
  /// Live: GET /health-assessments/by-class-date
  ///
  /// Backend only returns existing records (not full class roster) and omits
  /// `school_year_id` / `assessment_date` / nested class. Inject query context
  /// so parsing and roster matching stay stable.
  Future<List<HealthAssessment>> getByClassDate({
    required int classId,
    required String assessmentDate,
  }) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/by-class-date',
      queryParameters: {'class_id': classId, 'assessment_date': assessmentDate},
    );
    return ApiResponse.list(response.data).map((raw) {
      final json = Map<String, dynamic>.from(raw as Map);
      json['class_id'] ??= classId;
      json['assessment_date'] ??= assessmentDate;
      // Prefer date string without time for UI matching.
      final date = json['assessment_date'];
      if (date is String && date.length >= 10) {
        json['assessment_date'] = date.substring(0, 10);
      }
      return HealthAssessment.fromJson(json);
    }).toList();
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
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/$id',
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<HealthAssessment> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.healthAssessments,
      data: _liveCreatePayload(data),
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<HealthAssessment> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.healthAssessments}/$id',
      data: _liveUpdatePayload(data),
    );
    return HealthAssessment.fromJson(ApiResponse.object(response.data));
  }

  /// Live DELETE is hard delete (backend has no soft archive).
  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.healthAssessments}/$id');
  }

  @override
  Future<void> restore(int id) async {
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
    final studentId = int.tryParse('${row['student_id']}');
    final height = _parseMeasure(row['height_cm']);
    final weight = _parseMeasure(row['weight_kg']);
    if (studentId == null) {
      throw StateError('Thiếu mã học sinh trong dòng đánh giá');
    }
    // Backend bulk rejects partial rows (height-only or weight-only).
    if (height == null || height <= 0) {
      throw StateError('Chiều cao không hợp lệ');
    }
    if (weight == null || weight <= 0) {
      throw StateError(
        'Cân nặng không hợp lệ — cần nhập cả chiều cao và cân nặng',
      );
    }
    return {
      'student_id': studentId,
      'height_cm': height,
      'weight_kg': weight,
      if (row['note'] != null && '${row['note']}'.trim().isNotEmpty)
        'note': '${row['note']}'.trim(),
    };
  }

  double? _parseMeasure(Object? raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    final text = '${raw ?? ''}'.trim().replaceAll(',', '.');
    if (text.isEmpty || text == 'null') {
      return null;
    }
    return double.tryParse(text);
  }
}
