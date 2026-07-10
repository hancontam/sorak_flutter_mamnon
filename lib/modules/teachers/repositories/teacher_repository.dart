import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/teacher.dart';

class TeacherRepository implements CrudRepository<Teacher> {
  TeacherRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Teacher>> getAll({int? schoolYearId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
    )).items;
  }

  Future<ApiPage<Teacher>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    bool? isActive,
    String? position,
    String? role,
    String? workStatus,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.teachers,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          if (isActive != null) 'is_active': '$isActive',
          if (position != null && position.isNotEmpty) 'position': position,
          if (role != null && role.isNotEmpty) 'role': role,
          if (workStatus != null && workStatus.isNotEmpty)
            'work_status': workStatus,
        },
      ),
    );
    return ApiResponse.page(response.data, Teacher.fromJson);
  }

  @override
  Future<Teacher?> getById(int id) async {
    final response = await _apiClient.dio.get('${ApiEndpoints.teachers}/$id');
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Teacher> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.teachers,
      data: data,
    );
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Teacher> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.teachers}/$id',
      data: data,
    );
    return Teacher.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.teachers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    await _apiClient.dio.patch('${ApiEndpoints.teachers}/$id/restore');
  }
}
