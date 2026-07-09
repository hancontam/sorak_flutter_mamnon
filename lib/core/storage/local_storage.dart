import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class LocalStorage {
  const LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  Future<void> saveToken(String token) {
    return _preferences.setString(StorageKeys.token, token);
  }

  String? getToken() {
    return _preferences.getString(StorageKeys.token);
  }

  Future<void> saveUsername(String username) {
    return _preferences.setString(StorageKeys.username, username);
  }

  String? getUsername() {
    return _preferences.getString(StorageKeys.username);
  }

  Future<void> clearAuth() async {
    await _preferences.remove(StorageKeys.token);
    await _preferences.remove(StorageKeys.username);
  }
}
