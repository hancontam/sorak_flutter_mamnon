import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
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
  Future<List<OutgoingTransfer>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.outgoingTransfers);
    return ApiResponse.list(response.data)
        .map((json) => OutgoingTransfer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OutgoingTransfer?> getById(int id) async {
    if (AppConfig.useMockApi) {
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
    if (AppConfig.useMockApi) {
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
      data: data,
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<OutgoingTransfer> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
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
      data: data,
    );
    return OutgoingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(status: 'Cancelled');
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.outgoingTransfers}/$id/cancel');
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.outgoingTransfers}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
    }
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }
}
