import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/outgoing_transfer.dart';

class OutgoingTransferRepository implements CrudRepository<OutgoingTransfer> {
  OutgoingTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<OutgoingTransfer>> getAll({int? schoolYearId}) async {
    return (await getPage(
      query: const ApiListQuery(pageSize: 500),
      schoolYearId: schoolYearId,
    )).items;
  }

  Future<ApiPage<OutgoingTransfer>> getPage({
    ApiListQuery query = const ApiListQuery(),
    int? schoolYearId,
    String? status,
    int? classId,
    int? studentId,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.outgoingTransfers,
      queryParameters: query.toQueryParameters(
        filters: {
          'school_year_id': ?schoolYearId,
          'class_id': ?classId,
          'student_id': ?studentId,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      ),
    );
    return ApiResponse.page(response.data, OutgoingTransfer.fromJson);
  }

  @override
  Future<OutgoingTransfer?> getById(int id) async {
    final response = await _apiClient.dio.get(
      '${ApiEndpoints.outgoingTransfers}/$id',
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<OutgoingTransfer> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.outgoingTransfers,
      data: _createPayload(data),
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<OutgoingTransfer> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.outgoingTransfers}/$id',
      data: _updatePayload(data),
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id, {String? cancelReason}) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.outgoingTransfers}/$id/cancel',
      data: {
        if (cancelReason != null && cancelReason.isNotEmpty)
          'cancel_reason': cancelReason,
      },
    );
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.outgoingTransfers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    throw UnsupportedError('Backend khong ho tro khoi phuc ho so chuyen di');
  }

  Map<String, dynamic> _createPayload(Map<String, dynamic> data) => {
    'student_id': int.tryParse('${data['student_id']}'),
    'school_year_id': int.tryParse('${data['school_year_id']}'),
    'destination_school': data['destination_school'],
    'transfer_date': data['transfer_date'],
    if (data['reason'] != null) 'reason': data['reason'],
    if (data['note'] != null) 'note': data['note'],
  };

  Map<String, dynamic> _updatePayload(Map<String, dynamic> data) => {
    if (data['destination_school'] != null)
      'destination_school': data['destination_school'],
    if (data['transfer_date'] != null) 'transfer_date': data['transfer_date'],
    if (data['reason'] != null) 'reason': data['reason'],
    if (data['note'] != null) 'note': data['note'],
  };
}
