import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/teacher.dart';

class TeacherRepository implements CrudRepository<Teacher> {
  TeacherRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<Teacher> _mockItems = [
    const Teacher(
      id: 1,
      fullName: 'Nguyen Thi Lan',
      email: 'lan@sorak.edu.vn',
      position: 'Teacher',
      phone: '0901000001',
      gender: 'Nu',
    ),
    const Teacher(
      id: 2,
      fullName: 'Tran Thi Hoa',
      email: 'hoa@sorak.edu.vn',
      position: 'Teacher',
      phone: '0901000002',
      gender: 'Nu',
    ),
  ];

  @override
  Future<List<Teacher>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.teachers);
    return ApiResponse.list(
      response.data,
    ).map((json) => Teacher.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Teacher?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.teachers}/$id');
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Teacher> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = Teacher(
        id: _nextId(),
        fullName: data['full_name'] as String,
        email: data['email'] as String,
        position: data['position'] as String,
        phone: data['phone'] as String? ?? '',
        gender: data['gender'] as String? ?? '',
        workStatus: data['work_status'] as String? ?? 'Dang lam viec',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.teachers,
      data: data,
    );
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Teacher> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        fullName: data['full_name'] as String?,
        email: data['email'] as String?,
        position: data['position'] as String?,
        phone: data['phone'] as String?,
        gender: data['gender'] as String?,
        workStatus: data['work_status'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.teachers}/$id',
      data: data,
    );
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.teachers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.teachers}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }
}
