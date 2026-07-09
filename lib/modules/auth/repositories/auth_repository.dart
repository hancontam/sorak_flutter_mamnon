import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../models/auth_user.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  Future<AuthUser?> getSavedUser() async {
    final token = _localStorage.getToken();
    final username = _localStorage.getUsername();

    if (token == null || username == null) {
      return null;
    }

    return AuthUser(username: username, token: token);
  }

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    // TODO: Replace this demo login with Dio API when backend is ready.
    // Example:
    // final response = await _apiClient.dio.post('/auth/login', data: {...});
    // final token = response.data['token'] as String;
    _apiClient.dio.options.headers['Demo-Mode'] = 'true';

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (username != 'admin' || password != '123') {
      throw Exception('Incorrect username or password');
    }

    const token = 'demo-token-admin';
    await _localStorage.saveToken(token);
    await _localStorage.saveUsername(username);

    return AuthUser(username: username, token: token);
  }

  Future<void> logout() {
    return _localStorage.clearAuth();
  }
}
