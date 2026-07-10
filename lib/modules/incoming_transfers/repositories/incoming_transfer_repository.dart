import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/incoming_transfer.dart';

class IncomingTransferRepository implements CrudRepository<IncomingTransfer> {
  IncomingTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<IncomingTransfer>> getAll({int? schoolYearId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
    )).items;
  }

  Future<ApiPage<IncomingTransfer>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    String? status,
    int? classId,
    int? studentId,
    String? previousSchool,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.incomingTransfers,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          'class_id': ?classId,
          'student_id': ?studentId,
          if (status != null && status.isNotEmpty) 'status': status,
          if (previousSchool != null && previousSchool.isNotEmpty)
            'previous_school': previousSchool,
        },
      ),
    );
    return ApiResponse.page(response.data, IncomingTransfer.fromJson);
  }

  @override
  Future<IncomingTransfer?> getById(int id) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.incomingTransfers}/$id',
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<IncomingTransfer> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.incomingTransfers,
      data: _createPayload(data),
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<IncomingTransfer> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.incomingTransfers}/$id',
      data: _updatePayload(data),
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id, {String? cancelReason}) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.incomingTransfers}/$id/cancel',
      data: {
        if (cancelReason != null && cancelReason.isNotEmpty)
          'cancel_reason': cancelReason,
      },
    );
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.incomingTransfers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    throw UnsupportedError('Backend khong ho tro khoi phuc ho so chuyen den');
  }

  Map<String, dynamic> _createPayload(Map<String, dynamic> data) => {
    'student_id': int.tryParse('${data['student_id']}'),
    'school_year_id': int.tryParse('${data['school_year_id']}'),
    'previous_school': data['previous_school'],
    'transfer_date': data['transfer_date'],
    if (data['reason'] != null) 'reason': data['reason'],
    if (data['note'] != null) 'note': data['note'],
  };

  Map<String, dynamic> _updatePayload(Map<String, dynamic> data) => {
    if (data['previous_school'] != null)
      'previous_school': data['previous_school'],
    if (data['transfer_date'] != null) 'transfer_date': data['transfer_date'],
    if (data['reason'] != null) 'reason': data['reason'],
    if (data['note'] != null) 'note': data['note'],
  };
}
