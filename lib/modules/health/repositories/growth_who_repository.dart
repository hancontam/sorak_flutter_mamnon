import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/health_assessment.dart';

class GrowthWhoRepository {
  GrowthWhoRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<HealthAssessment> _mockHistory = [
    const HealthAssessment(
      id: 101,
      studentId: 1,
      classId: 1,
      schoolYearId: 1,
      assessmentDate: '2026-01-09',
      heightCm: 98,
      weightKg: 15.2,
      studentName: 'Nguyen Minh An',
      studentCode: 'NBA2024.001',
      className: 'Mam 1A',
      schoolYearName: '2025-2026',
      bmi: 15.82,
      bmiStatus: 'Binh thuong',
      heightStatus: 'Binh thuong',
      weightStatus: 'Binh thuong',
    ),
    const HealthAssessment(
      id: 102,
      studentId: 1,
      classId: 1,
      schoolYearId: 1,
      assessmentDate: '2026-04-09',
      heightCm: 100.5,
      weightKg: 15.9,
      studentName: 'Nguyen Minh An',
      studentCode: 'NBA2024.001',
      className: 'Mam 1A',
      schoolYearName: '2025-2026',
      bmi: 15.74,
      bmiStatus: 'Binh thuong',
      heightStatus: 'Binh thuong',
      weightStatus: 'Binh thuong',
    ),
    const HealthAssessment(
      id: 103,
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
    ),
    const HealthAssessment(
      id: 201,
      studentId: 2,
      classId: 2,
      schoolYearId: 1,
      assessmentDate: '2026-02-09',
      heightCm: 106.8,
      weightKg: 17.2,
      studentName: 'Tran Bao Ngoc',
      studentCode: 'TBN2024.002',
      className: 'Choi 2B',
      schoolYearName: '2025-2026',
      bmi: 15.08,
      bmiStatus: 'Binh thuong',
      heightStatus: 'Binh thuong',
      weightStatus: 'Binh thuong',
    ),
    const HealthAssessment(
      id: 202,
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

  Future<List<HealthAssessment>> getLatest({required String role}) async {
    if (AppConfig.useMockApi || role == 'PARENT') {
      final latest = <int, HealthAssessment>{};
      for (final item in _mockHistory) {
        final current = latest[item.studentId];
        if (current == null ||
            item.assessmentDate.compareTo(current.assessmentDate) > 0) {
          latest[item.studentId] = item;
        }
      }
      final items = latest.values.toList()
        ..sort((a, b) => a.studentName.compareTo(b.studentName));
      if (role == 'PARENT') {
        return items
            .where((item) => item.studentCode == 'NBA2024.001')
            .toList();
      }
      return items;
    }

    final response = await _apiClient.dio.get(ApiEndpoints.healthAssessments);
    return _readList(response.data)
        .map((json) => HealthAssessment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<HealthAssessment>> getHistory({
    required int studentId,
    required String role,
  }) async {
    if (AppConfig.useMockApi || role == 'PARENT') {
      return _mockHistory.where((item) => item.studentId == studentId).toList()
        ..sort((a, b) => a.assessmentDate.compareTo(b.assessmentDate));
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.healthAssessments}/history',
      queryParameters: {'student_id': studentId, 'school_year_id': 1},
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
