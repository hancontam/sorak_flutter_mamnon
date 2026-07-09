import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AuthUser? _user;
  Map<String, dynamic> _profile = const {};
  bool _isLoading = false;
  bool _isSavingPassword = false;
  String? _errorMessage;

  AuthUser? get user => _user;
  AuthUser? get currentUser => _user;
  Map<String, dynamic> get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSavingPassword => _isSavingPassword;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authRepository.getSavedUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return loginStaff(email: email, password: password);
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _authRepository.getProfile();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isSavingPassword = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSavingPassword = false;
      notifyListeners();
    }
  }

  Future<bool> loginStaff({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.loginStaff(
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginParent({
    required String studentCardNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.loginParent(
        studentCardNumber: studentCardNumber,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _profile = const {};
    notifyListeners();
  }
}
