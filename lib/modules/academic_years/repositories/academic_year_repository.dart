import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/academic_year.dart';

class AcademicYearRepository implements CrudRepository<AcademicYear> {
  AcademicYearRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<AcademicYear> _mockItems = [
    const AcademicYear(
      id: 1,
      name: '2025-2026',
      startDate: '2025-08-01',
      endDate: '2026-05-31',
      status: 'active',
    ),
    const AcademicYear(
      id: 2,
      name: '2026-2027',
      startDate: '2026-08-01',
      endDate: '2027-05-31',
    ),
  ];

  @override
  Future<List<AcademicYear>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.academicYears);
    return ApiResponse.list(response.data)
        .map((json) => AcademicYear.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AcademicYear?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.academicYears}/$id');
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<AcademicYear> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = AcademicYear(
        id: _nextId(),
        name: data['name'] as String,
        startDate: data['start_date'] as String,
        endDate: data['end_date'] as String,
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.academicYears, data: data);
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<AcademicYear> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        name: data['name'] as String?,
        startDate: data['start_date'] as String?,
        endDate: data['end_date'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch('${ApiEndpoints.academicYears}/$id', data: data);
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  Future<void> activate(int id) async {
    if (AppConfig.useMockApi) {
      for (var i = 0; i < _mockItems.length; i++) {
        final item = _mockItems[i];
        _mockItems[i] = item.copyWith(status: item.id == id ? 'active' : 'inactive');
      }
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.academicYears}/$id/activate');
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.academicYears}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.post('${ApiEndpoints.academicYears}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
