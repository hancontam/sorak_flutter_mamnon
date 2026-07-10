import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/academic_year.dart';

class AcademicYearRepository implements CrudRepository<AcademicYear> {
  AcademicYearRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<AcademicYear>> getAll() async {
    return (await getPage(query: const ApiListQuery(pageSize: 500))).items;
  }

  Future<ApiPage<AcademicYear>> getPage({
    ApiListQuery query = const ApiListQuery(),
  }) async {
    final response = await _apiClient.dio.get(ApiEndpoints.academicYears);
    return ApiResponse.page(response.data, AcademicYear.fromJson);
  }

  @override
  Future<AcademicYear?> getById(int id) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.academicYears}/$id',
    );
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<AcademicYear> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.academicYears,
      data: data,
    );
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<AcademicYear> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.academicYears}/$id',
      data: data,
    );
    return AcademicYear.fromJson(ApiResponse.object(response.data));
  }

  Future<void> activate(int id) async {
    await _apiClient.dio.patch('${ApiEndpoints.academicYears}/$id/activate');
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.academicYears}/$id');
  }

  @override
  Future<void> restore(int id) async {
    await _apiClient.dio.post('${ApiEndpoints.academicYears}/$id/restore');
  }
}
