import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_page.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/account.dart';

class AccountRepository implements CrudRepository<Account> {
  AccountRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  int _nextAccountId = 20;

  final List<Account> _mockItems = [
    const Account(
      id: 1,
      accountId: 1,
      teacherId: 1,
      fullName: 'Principal Admin',
      email: 'principal@sorak.edu.vn',
      role: 'PRINCIPAL',
      phone: '0909000001',
      position: 'Hiệu trưởng',
      workStatus: 'Đang làm việc',
      accountType: 'staff',
    ),
    const Account(
      id: 2,
      accountId: 2,
      teacherId: 2,
      fullName: 'Nguyen Thi Lan',
      email: 'lan@sorak.edu.vn',
      role: 'TEACHER',
      phone: '0909000002',
      position: 'Giáo viên',
      workStatus: 'Đang làm việc',
      accountType: 'staff',
    ),
    const Account(
      id: 3,
      teacherId: 3,
      fullName: 'Tran Thi Hoa',
      email: 'hoa@sorak.edu.vn',
      role: 'none',
      phone: '0909000003',
      position: 'Giáo viên',
      workStatus: 'Đang làm việc',
      accountType: 'staff',
      isActive: false,
    ),
    const Account(
      id: 101,
      accountId: 11,
      studentId: 1,
      fullName: 'Nguyen Minh An',
      role: 'PARENT',
      phone: '0912000001',
      studentStatus: 'Đang học',
      className: 'Mam 1A',
      cardNumber: 'MN0001',
      accountType: 'parent',
    ),
    const Account(
      id: 102,
      accountId: 12,
      studentId: 2,
      fullName: 'Tran Bao Ngoc',
      role: 'PARENT',
      phone: '0912000002',
      studentStatus: 'Đang học',
      className: 'Choi 2B',
      cardNumber: 'MN0002',
      accountType: 'parent',
    ),
  ];

  @override
  Future<List<Account>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems
          .where((item) => !item.isDeleted && item.accountType == 'staff')
          .toList();
    }

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
    if (AppConfig.useMockApi) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                item.accountType == 'staff' &&
                (role == null || item.role == role) &&
                (isActive == null || item.isActive == isActive) &&
                (workStatus == null || item.workStatus == workStatus) &&
                (position == null || item.position == position),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useMockApi) {
      final items = _mockItems
          .where(
            (item) =>
                !item.isDeleted &&
                item.accountType == 'parent' &&
                (isActive == null || item.isActive == isActive) &&
                (studentStatus == null || item.studentStatus == studentStatus),
          )
          .toList();
      return _mockPage(items, query);
    }

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
    if (AppConfig.useMockApi) {
      final matches = _mockItems.where((item) => item.id == id);
      return matches.isEmpty ? null : matches.first;
    }

    final response = await _apiClient.dio.get('${ApiEndpoints.accounts}/$id');
    return Account.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<Account> create(Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final item = Account(
        id: _nextId(),
        accountId: _nextAccountId++,
        teacherId: _nextId(),
        fullName: data['full_name'] as String,
        email: data['email'] as String,
        role: data['role'] as String? ?? 'TEACHER',
        phone: data['phone'] as String? ?? '',
        gender: data['gender'] as String? ?? '',
        accountType: 'staff',
        isActive: true,
      );
      _mockItems.add(item);
      return item;
    }

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
    if (AppConfig.useMockApi) {
      final index = _findStaffIndex(teacherId);
      final current = _mockItems[index];
      _mockItems[index] = current.copyWith(
        accountId: current.accountId == 0
            ? _nextAccountId++
            : current.accountId,
        role: role,
        isActive: true,
      );
      return;
    }

    await _apiClient.dio.post(
      '${ApiEndpoints.accounts}/$teacherId/assign-role',
      data: {'role': role, 'password': password.isEmpty ? null : password},
    );
  }

  Future<void> changeStaffRole({
    required int teacherId,
    required String role,
  }) async {
    if (AppConfig.useMockApi) {
      final index = _findStaffIndex(teacherId);
      _mockItems[index] = _mockItems[index].copyWith(role: role);
      return;
    }

    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$teacherId/role',
      data: {'role': role},
    );
  }

  Future<void> setStaffActive({
    required int accountId,
    required bool isActive,
  }) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere(
        (item) => item.accountId == accountId,
      );
      _mockItems[index] = _mockItems[index].copyWith(isActive: isActive);
      return;
    }

    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$accountId/active',
      data: {'is_active': isActive},
    );
  }

  Future<void> setParentActive({
    required int studentId,
    required bool isActive,
  }) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere(
        (item) => item.studentId == studentId,
      );
      _mockItems[index] = _mockItems[index].copyWith(isActive: isActive);
      return;
    }

    await _apiClient.dio.patch(
      '${ApiEndpoints.students}/$studentId/active',
      data: {'is_active': isActive},
    );
  }

  Future<void> changePassword({
    required int accountId,
    required String password,
  }) async {
    if (AppConfig.useMockApi) {
      return;
    }

    await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$accountId/password',
      data: {'password': password},
    );
  }

  @override
  Future<Account> update(int id, Map<String, dynamic> data) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      final current = _mockItems[index];
      final item = current.copyWith(
        fullName: data['full_name'] as String?,
        email: data['email'] as String?,
        role: data['role'] as String?,
        phone: data['phone'] as String?,
        gender: data['gender'] as String?,
      );
      _mockItems[index] = item;
      return item;
    }

    final response = await _apiClient.dio.patch(
      '${ApiEndpoints.accounts}/$id',
      data: data,
    );
    return Account.fromJson(ApiResponse.object(response.data));
  }

  @override
  Future<void> archive(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: true);
      return;
    }

    await _apiClient.dio.delete('${ApiEndpoints.accounts}/$id');
  }

  @override
  Future<void> restore(int id) async {
    if (AppConfig.useMockApi) {
      final index = _mockItems.indexWhere((item) => item.id == id);
      _mockItems[index] = _mockItems[index].copyWith(isDeleted: false);
      return;
    }

    await _apiClient.dio.patch('${ApiEndpoints.accounts}/$id/restore');
  }

  int _nextId() {
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  int _findStaffIndex(int teacherId) {
    return _mockItems.indexWhere((item) {
      return item.teacherId == teacherId || item.id == teacherId;
    });
  }

  ApiPage<Account> _mockPage(List<Account> items, ApiListQuery query) {
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
