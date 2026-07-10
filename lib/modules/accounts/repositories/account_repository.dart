import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/account.dart';

class AccountRepository implements CrudRepository<Account> {
  AccountRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Account>> getAll() async {
    return (await getStaffPage(query: const ApiListQuery(pageSize: 500))).items;
  }

  Future<List<Account>> getStaffAccounts({
    ApiListQuery query = const ApiListQuery(pageSize: 200),
    String? role,
    bool? isActive,
    String? workStatus,
    String? position,
  }) async {
    return (await getStaffPage(
      query: query,
      role: role,
      isActive: isActive,
      workStatus: workStatus,
      position: position,
    )).items;
  }

  Future<ApiPage<Account>> getStaffPage({
    ApiListQuery query = const ApiListQuery(),
    String? role,
    bool? isActive,
    String? workStatus,
    String? position,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.accounts,
      queryParameters: query.toQueryParameters(
        filters: {
          'type': 'staff',
          if (role != null && role.isNotEmpty) 'role': role,
          if (isActive != null) 'is_active': '$isActive',
          if (workStatus != null && workStatus.isNotEmpty)
            'work_status': workStatus,
          if (position != null && position.isNotEmpty) 'position': position,
        },
      ),
    );
    return ApiResponse.page(response.data, Account.fromJson);
  }

  Future<List<Account>> getParentAccounts({
    ApiListQuery query = const ApiListQuery(pageSize: 200),
    bool? isActive,
    String? studentStatus,
  }) async {
    return (await getParentPage(
      query: query,
      isActive: isActive,
      studentStatus: studentStatus,
    )).items;
  }

  Future<ApiPage<Account>> getParentPage({
    ApiListQuery query = const ApiListQuery(),
    bool? isActive,
    String? studentStatus,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.accounts,
      queryParameters: query.toQueryParameters(
        filters: {
          'type': 'parent',
          if (isActive != null) 'is_active': '$isActive',
          if (studentStatus != null && studentStatus.isNotEmpty)
            'student_status': studentStatus,
        },
      ),
    );
    final page = ApiResponse.page(response.data, Account.fromJson);
    return ApiPage(
      items: page.items
          .map((account) => account.copyWith(accountType: 'parent'))
          .toList(),
      page: page.page,
      pageSize: page.pageSize,
      total: page.total,
      totalPages: page.totalPages,
    );
  }

  @override
  Future<Account?> getById(int id) async {
    final response = await _apiClient.dio.get('${ApiEndpoints.accounts}/$id');
    return Account.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Account> create(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.accounts,
      data: data,
    );
    return Account.fromJson(ApiResponse.object(response.data));
  }

  Future<void> assignStaffAccount({
    required int teacherId,
    required String role,
    required String password,
  }) async {
    await _apiClient.dio.post(
      '${ApiEndpoints.accounts}/$teacherId/assign-role',
      data: {'role': role, 'password': password.isEmpty ? null : password},
    );
  }

  Future<void> changeStaffRole({
    required int teacherId,
    required String role,
  }) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$teacherId/role',
      data: {'role': role},
    );
  }

  Future<void> setStaffActive({
    required int accountId,
    required bool isActive,
  }) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$accountId/active',
      data: {'is_active': isActive},
    );
  }

  Future<void> setParentActive({
    required int studentId,
    required bool isActive,
  }) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.students}/$studentId/active',
      data: {'is_active': isActive},
    );
  }

  Future<void> changePassword({
    required int accountId,
    required String password,
  }) async {
    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$accountId/password',
      data: {'password': password},
    );
  }

  @override
  Future<Account> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$id',
      data: data,
    );
    return Account.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    await _apiClient.dio.delete('${ApiEndpoints.accounts}/$id');
  }

  @override
  Future<void> restore(int id) async {
    await _apiClient.dio.patch('${ApiEndpoints.accounts}/$id/restore');
  }
}
