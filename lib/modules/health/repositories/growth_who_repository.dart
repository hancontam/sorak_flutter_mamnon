import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/health_assessment.dart';
import '../models/who_curve_point.dart';

class GrowthWhoRepository {
  GrowthWhoRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Latest assessment per student.
  /// Staff live: GET /health-assessments?latest=true&school_year_id=
  /// Parent endpoints do not exist yet. Never substitute fixture data in live mode.
  Future<List<HealthAssessment>> getLatest({
    required String role,
    int? schoolYearId,
  }) async {
    if (role.toUpperCase() == 'PARENT') {
      throw UnsupportedError(
        'Backend chưa hỗ trợ dữ liệu tăng trưởng dành cho phụ huynh.',
      );
    }
    final response = await _apiClient.dio.get(
      ApiEndpoints.healthAssessments,
      queryParameters: {'latest': 'true', 'school_year_id': ?schoolYearId},
    );
    return _readList(response.data)
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Student growth history. Live: GET /health-assessments/history
  /// Response shape: { student, records }
  Future<List<HealthAssessment>> getHistory({
    required int studentId,
    required String role,
    int? schoolYearId,
  }) async {
    if (role.toUpperCase() == 'PARENT') {
      throw UnsupportedError(
        'Backend chưa hỗ trợ lịch sử tăng trưởng dành cho phụ huynh.',
      );
    }
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/history',
      queryParameters: {
        'student_id': studentId,
        'school_year_id': ?schoolYearId,
      },
    );
    final object = ApiResponse.object(response.data);
    final records = object['records'];
    if (records is! List) {
      return const [];
    }
    return records
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// WHO reference curves. Live: GET /health-assessments/who-curves
  /// [indicator]: height | weight | bmi
  /// [gender]: Nam | Nữ
  Future<List<WhoCurvePoint>> getWhoCurves({
    required String indicator,
    required String gender,
  }) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/who-curves',
      queryParameters: {'indicator': indicator, 'gender': gender},
    );
    return ApiResponse.list(response.data)
        .map((json) => WhoCurvePoint.fromJson(json as Map<String, dynamic>))
        .toList();
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
}
