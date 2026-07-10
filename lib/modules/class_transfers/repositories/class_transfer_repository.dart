import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/class_transfer.dart';

class ClassTransferRepository implements CrudRepository<ClassTransfer> {
  ClassTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ClassTransfer>> getAll({int? schoolYearId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
    )).items;
  }

  Future<ApiPage<ClassTransfer>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    String? status,
    int? classId,
    int? studentId,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.classTransfers,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          'class_id': ?classId,
          'student_id': ?studentId,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      ),
    );
    return ApiResponse.page(response.data, ClassTransfer.fromJson);
  }

  @override
  Future<ClassTransfer?> getById(int id) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.classTransfers}/$id',
    );
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<ClassTransfer> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.classTransfers,
      data: {
        'student_id': int.tryParse('${data['student_id']}'),
        'to_class_id': int.tryParse('${data['to_class_id']}'),
        'reason': data['reason'],
        'effective_date': data['effective_date'],
      },
    );
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<ClassTransfer> update(int id, Map<String, dynamic> data) async {
    return updateStatus(
      id,
      data['action'] as String? ?? 'cancel',
      note: data['note'] as String?,
    );
  }

  Future<ClassTransfer> updateStatus(
    int id,
    String action, {
    String? note,
  }) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.classTransfers}/$id/status',
      data: {
        'action': action,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    await updateStatus(id, 'cancel');
  }

  @override
  Future<void> restore(int id) async {
    await updateStatus(id, 'revert');
  }
}
