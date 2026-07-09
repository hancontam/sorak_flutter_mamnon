import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/repositories/crud_repository.dart';
import '../models/account.dart';

class AccountRepository implements CrudRepository<Account> {
  AccountRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final List<Account> _mockItems = [
    const Account(
      id: 1,
      fullName: 'Principal Admin',
      email: 'principal@sorak.edu.vn',
      role: 'PRINCIPAL',
      phone: '0909000001',
    ),
    const Account(
      id: 2,
      fullName: 'Teacher Staff',
      email: 'teacher@sorak.edu.vn',
      role: 'TEACHER',
      phone: '0909000002',
    ),
  ];

  @override
  Future<List<Account>> getAll() async {
    if (AppConfig.useMockApi) {
      return _mockItems.where((item) => !item.isDeleted).toList();
    }

    final response = await _apiClient.dio.get(ApiEndpoints.accounts);
    return ApiResponse.list(response.data)
        .map((json) => Account.fromJson(json as Map<String, dynamic>))
        .toList();
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
        fullName: data['full_name'] as String,
        email: data['email'] as String,
        role: data['role'] as String? ?? 'TEACHER',
        phone: data['phone'] as String? ?? '',
        gender: data['gender'] as String? ?? '',
      );
      _mockItems.add(item);
      return item;
    }

    final response = await _apiClient.dio.post(ApiEndpoints.accounts, data: data);
    return Account.fromJson(ApiResponse.object(response.data));
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

    final response = await _apiClient.dio.patch('${ApiEndpoints.accounts}/$id', data: data);
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
    return _mockItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
