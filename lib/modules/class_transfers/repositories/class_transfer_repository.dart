import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/class_transfer.dart';

class ClassTransferRepository implements CrudRepository<ClassTransfer> {
  ClassTransferRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<ClassTransfer> _mockItems = [
    const ClassTransfer(
      id: 1,
      studentId: 1,
      studentName: 'Nguyen Minh An',
      fromClassName: 'Mam 1A',
      toClassId: 2,
      toClassName: 'Choi 2B',
      reason: 'Family request',
      effectiveDate: '2026-09-01',
    ),
  ];

  @override
  Future<List<ClassTransfer>> getAll() async {
    if (AppConfig.useMockApi) {
      return List.of(_mockItems);
    }

    final response = await _apiClient.dio.get(ApiEndpoints.classTransfers);
    return ApiResponse.list(response.data)
        .map((json) => ClassTransfer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ClassTransfer?> getById(int id) async {
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.classTransfers}/$id');
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<ClassTransfer> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = ClassTransfer(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        studentName: data['student_name'] as String? ?? 'Student',
        fromClassName: data['from_class_name'] as String? ?? '',
        toClassId: int.tryParse('${data['to_class_id']}') ?? 0,
        toClassName: data['to_class_name'] as String? ?? '',
        reason: data['reason'] as String,
        effectiveDate: data['effective_date'] as String,
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.classTransfers, data: data);
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<ClassTransfer> update(int id, Map<String, dynamic> data) async {
    return updateStatus(id, data['action'] as String? ?? 'cancel');
  }

  Future<ClassTransfer> updateStatus(int id, String action) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(status: _statusFromAction(action));
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.classTransfers}/$id/status',
      data: {'action': action},
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

  String _statusFromAction(String action) {
    switch (action) {
      case 'approve':
        return 'Approved';
      case 'reject':
        return 'Rejected';
      case 'revert':
        return 'Pending';
      default:
        return 'Cancelled';
    }
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
