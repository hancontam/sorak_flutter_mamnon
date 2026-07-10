import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
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
  Future<List<Student>> getAll({int? schoolYearId, int? classId}) async {
    if (AppConfig.useMockApi) {
      return _mockItems
          .where(
            (item) =>
                !item.isDeleted && (classId == null || item.classId == classId),
          )
          .toList();
    }

    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
      classId: classId,
    )).items;
  }

  Future<ApiPage<Student>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    int? classId,
    String? gradeLevel,
    bool? isActive,
    String? studentStatus,
  }) async {
    if (AppConfig.useMockApi) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                (classId == null || item.classId == classId) &&
                (studentStatus == null ||
                    item.studentStatus == studentStatus) &&
                (isActive == null || item.isActive == isActive),
          )
          .toList();
      return _mockPage(items, query);
    }

    final response = await _apiClient.dio.get(
      ApiEndpoints.students,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          'class_id': ?classId,
          if (gradeLevel != null && gradeLevel.isNotEmpty)
            'grade_level': gradeLevel,
          if (isActive != null) 'is_active': '$isActive',
          if (studentStatus != null && studentStatus.isNotEmpty)
            'student_status': studentStatus,
        },
      ),
    );
    return ApiResponse.page(response.data, Student.fromJson);
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

    final response = await _apiClient.dio.post(
      ApiEndpoints.students,
      data: data,
    );
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

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.students}/$id',
      data: data,
    );
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
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  ApiPage<Student> _mockPage(List<Student> items, ApiListQuery query) {
    final start = (query.page - 1) * query.pageSize;
    final end = (start + query.pageSize).clamp(0, items.length).toInt();
    return ApiPage(
      items: start >= items.length ? const [] : items.sublist(start, end),
      page: query.page,
      pageSize: query.pageSize,
      total: items.length,
      totalPages: items.isEmpty ? 0 : (items.length / query.pageSize).ceil(),
    );
  }
}
