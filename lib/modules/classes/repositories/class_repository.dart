import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/school_class.dart';

class ClassRepository implements CrudRepository<SchoolClass> {
  ClassRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<SchoolClass> _mockItems = [
    const SchoolClass(
      id: 1,
      className: 'Mam 1A',
      schoolYearId: 1,
      ageGroup: '3-4',
      room: 'A101',
      teacherName: 'Co Lan',
    ),
    const SchoolClass(
      id: 2,
      className: 'Choi 2B',
      schoolYearId: 1,
      ageGroup: '4-5',
      room: 'B202',
      teacherName: 'Co Hoa',
    ),
  ];

  @override
  Future<List<SchoolClass>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.classes);
    return ApiResponse.list(response.data)
        .map((json) => SchoolClass.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SchoolClass?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.classes}/$id');
    return SchoolClass.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<SchoolClass> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = SchoolClass(
        id: _nextId(),
        className: data['class_name'] as String,
        schoolYearId: int.tryParse('${data['school_year_id']}') ?? 1,
        ageGroup: data['age_group'] as String? ?? '',
        room: data['room'] as String? ?? '',
        teacherName: data['teacher_name'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.classes, data: data);
    return SchoolClass.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<SchoolClass> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        className: data['class_name'] as String?,
        schoolYearId: int.tryParse('${data['school_year_id']}'),
        ageGroup: data['age_group'] as String?,
        room: data['room'] as String?,
        teacherName: data['teacher_name'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch('${ApiEndpoints.classes}/$id', data: data);
    return SchoolClass.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.classes}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.classes}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
