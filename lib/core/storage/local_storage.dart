import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class LocalStorage {
  const LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  Future<void> saveUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
  }) async {
    await _preferences.setInt(StorageKeys.userId, id);
    await _preferences.setString(StorageKeys.fullName, fullName);
    await _preferences.setString(StorageKeys.email, email);
    await _preferences.setString(StorageKeys.role, role);
  }

  int? getUserId() {
    return _preferences.getInt(StorageKeys.userId);
  }

  String? getFullName() {
    return _preferences.getString(StorageKeys.fullName);
  }

  String? getEmail() {
    return _preferences.getString(StorageKeys.email);
  }

  String? getRole() {
    return _preferences.getString(StorageKeys.role);
  }

  Future<void> saveSelectedAcademicYearId(int id) {
    return _preferences.setInt(StorageKeys.selectedAcademicYearId, id);
  }

  int? getSelectedAcademicYearId() {
    return _preferences.getInt(StorageKeys.selectedAcademicYearId);
  }

  Future<void> clearAuth() async {
    await _preferences.remove(StorageKeys.userId);
    await _preferences.remove(StorageKeys.fullName);
    await _preferences.remove(StorageKeys.email);
    await _preferences.remove(StorageKeys.role);
  }
}
