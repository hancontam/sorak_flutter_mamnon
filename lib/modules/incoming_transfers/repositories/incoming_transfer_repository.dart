import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/incoming_transfer.dart';

class IncomingTransferRepository implements CrudRepository<IncomingTransfer> {
  IncomingTransferRepository({required ApiClient apiClient}) : _apiClient = apiClient;

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
  Future<List<IncomingTransfer>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.incomingTransfers);
    return ApiResponse.list(response.data)
        .map((json) => IncomingTransfer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IncomingTransfer?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.incomingTransfers}/$id');
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
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.incomingTransfers, data: data);
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
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch('${ApiEndpoints.incomingTransfers}/$id', data: data);
    return IncomingTransfer.fromJson(ApiResponse.object(response.data));
  }

  Future<void> cancel(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(status: 'Cancelled');
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.incomingTransfers}/$id/cancel');
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
    }
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
