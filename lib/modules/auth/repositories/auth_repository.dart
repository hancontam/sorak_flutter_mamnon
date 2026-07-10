import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../models/auth_user.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  }) : _apiClient = apiClient,
       _localStorage = localStorage;

  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  Future<AuthUser?> restoreSession() async {
    if (AppConfig.useMockApi) {
      return getSavedUser();
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.authMe);
      final profile = ApiResponse.object(response.data);
      final user = _userFromProfile(profile);
      await _saveUser(user);
      _apiClient.markSessionActive();
      return user;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        await _clearSession();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser?> getSavedUser() async {
    final id = _localStorage.getUserId();
    final fullName = _localStorage.getFullName();
    final email = _localStorage.getEmail();
    final role = _localStorage.getRole();

    if (id == null || fullName == null || email == null || role == null) {
      return null;
    }

    return AuthUser(id: id, fullName: fullName, email: email, role: role);
  }

  Future<AuthUser> login({required String email, required String password}) {
    return loginStaff(email: email, password: password);
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (!AppConfig.useMockApi) {
      final response = await _apiClient.dio.get(ApiEndpoints.authMe);
      return ApiResponse.object(response.data);
    }

    final user = await getSavedUser();
    if (user == null) {
      return <String, dynamic>{};
    }

    if (user.role.toUpperCase() == 'PARENT') {
      return {
        'account_id': user.id,
        'full_name': 'Nguyen Minh An',
        'role': 'PARENT',
        'student_id': 1,
        'student_id_card_number': 'NBA2024.001',
        'student_status': 'Dang hoc',
        'enrollments': [
          {
            'class': {
              'class_name': 'Mam 1A',
              'school_year': {'name': '2025-2026'},
            },
          },
        ],
      };
    }

    return {
      'account_id': user.id,
      'full_name': user.fullName,
      'email': user.email,
      'role': user.role,
      'phone': '0900000000',
      'gender': 'Female',
      'position': user.role.toUpperCase() == 'PRINCIPAL'
          ? 'Principal'
          : 'Teacher',
      'work_status': 'Dang lam viec',
    };
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!AppConfig.useMockApi) {
      await _apiClient.dio.post(
        ApiEndpoints.authChangePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (oldPassword.trim().isEmpty) {
      throw Exception('Old password is required');
    }
  }

  Future<AuthUser> loginStaff({
    required String email,
    required String password,
  }) async {
    if (!AppConfig.useMockApi) {
      final response = await _apiClient.dio.post(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      final data = ApiResponse.object(response.data);
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      final user = AuthUser.fromJson(userJson);
      await _saveUser(user);
      _apiClient.markSessionActive();
      return user;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (email != 'admin@sorak.edu.vn' || password != '123456') {
      throw Exception('Incorrect username or password');
    }

    const user = AuthUser(
      id: 1,
      fullName: 'Principal Admin',
      email: 'admin@sorak.edu.vn',
      role: 'PRINCIPAL',
    );

    await _saveUser(user);
    _apiClient.markSessionActive();
    return user;
  }

  Future<AuthUser> loginParent({
    required String studentCardNumber,
    required String password,
  }) async {
    if (!AppConfig.useMockApi) {
      final response = await _apiClient.dio.post(
        ApiEndpoints.authParentLogin,
        data: {
          'student_id_card_number': studentCardNumber,
          'password': password,
        },
      );
      final data = ApiResponse.object(response.data);
      final userJson = data['user'] as Map<String, dynamic>? ?? data;
      final user = AuthUser.fromJson(userJson);
      await _saveUser(user);
      _apiClient.markSessionActive();
      return user;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (studentCardNumber != 'NBA2024.001' || password != '123456') {
      throw Exception('Incorrect student card or password');
    }

    const user = AuthUser(
      id: 10,
      fullName: 'Parent Demo',
      email: 'parent@sorak.edu.vn',
      role: 'PARENT',
    );

    await _saveUser(user);
    _apiClient.markSessionActive();
    return user;
  }

  Future<void> logout() async {
    try {
      if (!AppConfig.useMockApi) {
        await _apiClient.dio.post(ApiEndpoints.authLogout);
      }
    } finally {
      await _clearSession();
    }
  }

  Future<void> clearSession() {
    return _clearSession();
  }

  Future<void> _saveUser(AuthUser user) async {
    await _localStorage.saveUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
    );
  }

  AuthUser _userFromProfile(Map<String, dynamic> profile) {
    return AuthUser.fromJson({
      ...profile,
      'email': profile['email'] ?? _localStorage.getEmail() ?? '',
    });
  }

  Future<void> _clearSession() async {
    await _apiClient.clearSessionCookies();
    await _localStorage.clearAuth();
  }
}
