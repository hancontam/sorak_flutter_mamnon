import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/school_class.dart';

class ClassRepository implements CrudRepository<SchoolClass> {
  ClassRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<SchoolClass>> getAll({int? schoolYearId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
    )).items;
  }

  Future<ApiPage<SchoolClass>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    String? ageGroup,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.classes,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          if (ageGroup != null && ageGroup.isNotEmpty) 'age_group': ageGroup,
        },
      ),
    );
    return ApiResponse.page(response.data, SchoolClass.fromJson);
  }

  @override
  Future<SchoolClass?> getById(int id) async {
    final response = await _apiClient.dio.get('${ApiEndpoints.classes}/$id');
    return SchoolClass.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<SchoolClass> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.classes,
      data: _createPayload(data),
    );
    var item = SchoolClass.fromJson(ApiResponse.object(response.data));
    final accountId = int.tryParse('${data['teacher_account_id'] ?? ''}');
    if (accountId != null && accountId > 0) {
      await assignTeacher(classId: item.id, accountId: accountId);
      item = (await getById(item.id)) ?? item;
    }
    return item;
  }

  @override
  Future<SchoolClass> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.classes}/$id',
      data: _updatePayload(data),
    );
    var item = SchoolClass.fromJson(ApiResponse.object(response.data));
    final accountId = int.tryParse('${data['teacher_account_id'] ?? ''}');
    if (accountId != null && accountId > 0) {
      await assignTeacher(classId: id, accountId: accountId);
      item = (await getById(id)) ?? item;
    }
    return item;
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.classes}/$id');
  }

  @override
  Future<void> restore(int id) async {
    await _apiClient.dio.patch('${ApiEndpoints.classes}/$id/restore');
  }

  Map<String, dynamic> _createPayload(Map<String, dynamic> data) => {
    'class_name': data['class_name'],
    'school_year_id': int.tryParse('${data['school_year_id']}'),
    if (data['age_group'] != null) 'age_group': data['age_group'],
    if (data['room'] != null) 'room': data['room'],
  };

  Map<String, dynamic> _updatePayload(Map<String, dynamic> data) => {
    if (data['class_name'] != null) 'class_name': data['class_name'],
    if (data['age_group'] != null) 'age_group': data['age_group'],
    if (data['room'] != null) 'room': data['room'],
  };

  Future<void> assignTeacher({
    required int classId,
    required int accountId,
  }) async {
    await _apiClient.dio.post(
      '${ApiEndpoints.classes}/$classId/teachers',
      data: {'account_id': accountId},
    );
  }

  Future<void> removeTeacher({
    required int classId,
    required int teacherId,
  }) async {
    await _apiClient.dio.delete(
      '${ApiEndpoints.classes}/$classId/teachers/$teacherId',
    );
  }
}
