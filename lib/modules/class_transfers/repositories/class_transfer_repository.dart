import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/class_transfer.dart';

class ClassTransferRepository implements CrudRepository<ClassTransfer> {
  ClassTransferRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

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
  Future<List<ClassTransfer>> getAll({int? schoolYearId}) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      return List.of(_mockItems);
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final items = _mockItems
          .where(
            (item) =>
                (status == null || item.status == status) &&
                (studentId == null || item.studentId == studentId),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get(
      '${ApiEndpoints.classTransfers}/$id',
    );
    return ClassTransfer.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<ClassTransfer> create(Map<String, dynamic> data) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final item = ClassTransfer(
        id: _nextId(),
        studentId: int.tryParse('${data['student_id']}') ?? 0,
        studentName: data['student_name'] as String? ?? 'Student',
        fromClassName: data['from_class_name'] as String? ?? '',
        toClassId: int.tryParse('${data['to_class_id']}') ?? 0,
        toClassName: data['to_class_name'] as String? ?? '',
        reason: data['reason'] as String,
        effectiveDate: data['effective_date'] as String,
        status: data['status'] as String? ?? 'Pending',
      );
      _mockItems.add(item);
      return item;
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(status: _statusFromAction(action));
      _mockItems[index] = item;
      return item;
    }

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
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  ApiPage<ClassTransfer> _mockPage(
    List<ClassTransfer> items,
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
