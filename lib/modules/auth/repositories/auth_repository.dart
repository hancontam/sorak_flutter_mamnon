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
      final savedUser = await getSavedUser();
      if (savedUser == null) return null;
      _apiClient.configureMockSession(
        role: savedUser.role,
        accountId: savedUser.id,
      );
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
    final response = await _apiClient.dio.get(ApiEndpoints.authMe);
    return ApiResponse.object(response.data);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.post(
      ApiEndpoints.authChangePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<AuthUser> loginStaff({
    required String email,
    required String password,
  }) async {
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

  Future<AuthUser> loginParent({
    required String studentCardNumber,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.authParentLogin,
      data: {'student_id_card_number': studentCardNumber, 'password': password},
    );
    final data = ApiResponse.object(response.data);
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    final user = AuthUser.fromJson(userJson);
    await _saveUser(user);
    _apiClient.markSessionActive();
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.authLogout);
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
