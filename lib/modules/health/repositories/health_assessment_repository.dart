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
  Future<List<HealthAssessment>> getByClassDate({
    required int classId,
    required String assessmentDate,
  }) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/by-class-date',
      queryParameters: {'class_id': classId, 'assessment_date': assessmentDate},
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
    return {
      'student_id': int.tryParse('${row['student_id']}'),
      'height_cm': double.tryParse('${row['height_cm']}'),
      'weight_kg': double.tryParse('${row['weight_kg']}'),
      if (row['note'] != null) 'note': row['note'],
    };
  }
}
