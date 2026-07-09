import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/student.dart';

class StudentRepository implements CrudRepository<Student> {
  StudentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<Student> _mockItems = [
    const Student(
      id: 1,
      fullName: 'Nguyen Minh An',
      dateOfBirth: '2021-03-10',
      gender: 'Nam',
      classId: 1,
      className: 'Mam 1A',
      contactPhone: '0912000001',
    ),
    const Student(
      id: 2,
      fullName: 'Tran Bao Ngoc',
      dateOfBirth: '2020-09-21',
      gender: 'Nu',
      classId: 2,
      className: 'Choi 2B',
      contactPhone: '0912000002',
    ),
  ];

  @override
  Future<List<Student>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.students);
    return ApiResponse.list(response.data)
        .map((json) => Student.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Student?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.students}/$id');
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Student> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = Student(
        id: _nextId(),
        fullName: data['full_name'] as String,
        dateOfBirth: data['date_of_birth'] as String,
        gender: data['gender'] as String,
        classId: int.tryParse('${data['class_id']}') ?? 0,
        className: data['class_name'] as String? ?? '',
        contactPhone: data['contact_phone'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.students, data: data);
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Student> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        fullName: data['full_name'] as String?,
        dateOfBirth: data['date_of_birth'] as String?,
        gender: data['gender'] as String?,
        classId: int.tryParse('${data['class_id']}'),
        className: data['class_name'] as String?,
        contactPhone: data['contact_phone'] as String?,
        studentStatus: data['student_status'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch('${ApiEndpoints.students}/$id', data: data);
    return Student.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.students}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.students}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
