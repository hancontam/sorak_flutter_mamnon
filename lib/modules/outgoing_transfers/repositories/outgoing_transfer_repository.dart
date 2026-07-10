import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/outgoing_transfer.dart';

class OutgoingTransferRepository implements CrudRepository<OutgoingTransfer> {
  OutgoingTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<OutgoingTransfer> _mockItems = [
    const OutgoingTransfer(
      id: 1,
      studentId: 2,
      studentName: 'Tran Bao Ngoc',
      destinationSchool: 'Hoa Mai Kindergarten',
      transferDate: '2026-10-01',
      reason: 'Move house',
    ),
  ];

  @override
  Future<List<OutgoingTransfer>> getAll({int? schoolYearId}) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                (status == null || item.status == status) &&
                (studentId == null || item.studentId == studentId),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.outgoingTransfers}/$id',
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<OutgoingTransfer> create(Map<String, dynamic> data) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final item = OutgoingTransfer(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        studentName: data['student_name'] as String? ?? 'Student',
        destinationSchool: data['destination_school'] as String,
        transferDate: data['transfer_date'] as String,
        reason: data['reason'] as String? ?? '',
        note: data['note'] as String? ?? '',
        status: data['status'] as String? ?? 'Recorded',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.outgoingTransfers,
      data: _createPayload(data),
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<OutgoingTransfer> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        destinationSchool: data['destination_school'] as String?,
        transferDate: data['transfer_date'] as String?,
        reason: data['reason'] as String?,
        note: data['note'] as String?,
        status: data['status'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.outgoingTransfers}/$id',
      data: _updatePayload(data),
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id, {String? cancelReason}) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(status: 'Cancelled');
      return;
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.outgoingTransfers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }
    throw UnsupportedError('Backend khong ho tro khoi phuc ho so chuyen di');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  ApiPage<OutgoingTransfer> _mockPage(
    List<OutgoingTransfer> items,
    ApiListQuery query,
  ) {
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
