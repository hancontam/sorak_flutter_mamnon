import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/school_class.dart';

class ClassRepository implements CrudRepository<SchoolClass> {
  ClassRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<SchoolClass> _mockItems = [
    const SchoolClass(
      id: 1,
      className: 'Mam 1A',
      schoolYearId: 1,
      ageGroup: '3-4',
      room: 'A101',
      teacherName: 'Co Lan',
    ),
    const SchoolClass(
      id: 2,
      className: 'Choi 2B',
      schoolYearId: 1,
      ageGroup: '4-5',
      room: 'B202',
      teacherName: 'Co Hoa',
    ),
    const SchoolClass(
      id: 3,
      className: 'Mam 1B',
      schoolYearId: 1,
      ageGroup: '3-4',
      room: 'A102',
      teacherName: 'Co Hoa',
    ),
  ];

  @override
  Future<List<SchoolClass>> getAll({int? schoolYearId}) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      return _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                (schoolYearId == null || item.schoolYearId == schoolYearId),
          )
          .toList();
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                (schoolYearId == null || item.schoolYearId == schoolYearId) &&
                (ageGroup == null || item.ageGroup == ageGroup),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.classes}/$id');
    return SchoolClass.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<SchoolClass> create(Map<String, dynamic> data) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final item = SchoolClass(
        id: _nextId(),
        className: data['class_name'] as String,
        schoolYearId: int.tryParse('${data['school_year_id']}') ?? 0,
        ageGroup: data['age_group'] as String? ?? '',
        room: data['room'] as String? ?? '',
        teacherName: data['teacher_name'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        className: data['class_name'] as String?,
        schoolYearId: int.tryParse('${data['school_year_id']}'),
        ageGroup: data['age_group'] as String?,
        room: data['room'] as String?,
        teacherName: data['teacher_name'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

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
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.classes}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useLegacyRepositoryMocks) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.classes}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  ApiPage<SchoolClass> _mockPage(List<SchoolClass> items, ApiListQuery query) {
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
}
