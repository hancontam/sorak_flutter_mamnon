import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/incoming_transfer.dart';

class IncomingTransferRepository implements CrudRepository<IncomingTransfer> {
  IncomingTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<IncomingTransfer> _mockItems = [
    const IncomingTransfer(
      id: 1,
      studentId: 3,
      studentName: 'Le Gia Bao',
      previousSchool: 'Sen Hong Kindergarten',
      transferDate: '2026-09-15',
      reason: 'New enrollment',
    ),
  ];

  @override
  Future<List<IncomingTransfer>> getAll({int? schoolYearId}) async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

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
    if (AppConfig.useMockApi) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                (status == null || item.status == status) &&
                (studentId == null || item.studentId == studentId) &&
                (previousSchool == null ||
                    item.previousSchool.contains(previousSchool)),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.incomingTransfers}/$id',
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<IncomingTransfer> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = IncomingTransfer(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        studentName: data['student_name'] as String? ?? 'Student',
        previousSchool: data['previous_school'] as String,
        transferDate: data['transfer_date'] as String,
        reason: data['reason'] as String? ?? '',
        note: data['note'] as String? ?? '',
        status: data['status'] as String? ?? 'Recorded',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.incomingTransfers,
      data: data,
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<IncomingTransfer> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        previousSchool: data['previous_school'] as String?,
        transferDate: data['transfer_date'] as String?,
        reason: data['reason'] as String?,
        note: data['note'] as String?,
        status: data['status'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.incomingTransfers}/$id',
      data: data,
    );
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id, {String? cancelReason}) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(status: 'Cancelled');
      return;
    }

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
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.incomingTransfers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }
    throw UnsupportedError('Backend khong ho tro khoi phuc ho so chuyen den');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  ApiPage<IncomingTransfer> _mockPage(
    List<IncomingTransfer> items,
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
}
