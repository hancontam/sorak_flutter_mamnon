import '../../../core/providers/crud_provider.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

class AccountProvider extends CrudProvider<Account> {
  AccountProvider({required AccountRepository accountRepository})
    : _accountRepository = accountRepository,
      super(repository: accountRepository);

  final AccountRepository _accountRepository;

  List<Account> _staffAccounts = [];
  List<Account> _parentAccounts = [];
  bool _isAccountsLoading = false;
  String? _accountsErrorMessage;

  List<Account> get staffAccounts => _staffAccounts;
  List<Account> get parentAccounts => _parentAccounts;
  bool get isAccountsLoading => _isAccountsLoading;
  String? get accountsErrorMessage => _accountsErrorMessage;

  Future<void> loadAccountManagement() async {
    _setAccountsLoading(true);
    try {
      final results = await Future.wait([
        _accountRepository.getStaffAccounts(),
        _accountRepository.getParentAccounts(),
      ]);
      _staffAccounts = results[0];
      _parentAccounts = results[1];
      _accountsErrorMessage = null;
    } catch (error) {
      _accountsErrorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _setAccountsLoading(false);
    }
  }

  Future<bool> assignStaffAccount({
    required int teacherId,
    required String role,
    required String password,
  }) async {
    return _runAccountAction(() {
      return _accountRepository.assignStaffAccount(
        teacherId: teacherId,
        role: role,
        password: password,
      );
    });
  }

  Future<bool> changeStaffRole({
    required int teacherId,
    required String role,
  }) async {
    return _runAccountAction(() {
      return _accountRepository.changeStaffRole(
        teacherId: teacherId,
        role: role,
      );
    });
  }

  Future<bool> setStaffActive({
    required int accountId,
    required bool isActive,
  }) async {
    return _runAccountAction(() {
      return _accountRepository.setStaffActive(
        accountId: accountId,
        isActive: isActive,
      );
    });
  }

  Future<bool> setParentActive({
    required int studentId,
    required bool isActive,
  }) async {
    return _runAccountAction(() {
      return _accountRepository.setParentActive(
        studentId: studentId,
        isActive: isActive,
      );
    });
  }

  Future<bool> changePassword({
    required int accountId,
    required String password,
  }) async {
    return _runAccountAction(() {
      return _accountRepository.changePassword(
        accountId: accountId,
        password: password,
      );
    });
  }

  Future<bool> _runAccountAction(Future<void> Function() action) async {
    _setAccountsLoading(true);
    try {
      await action();
      await loadAccountManagement();
      return true;
    } catch (error) {
      _accountsErrorMessage = error.toString().replaceFirst('Exception: ', '');
      _setAccountsLoading(false);
      return false;
    }
  }

  void _setAccountsLoading(bool value) {
    _isAccountsLoading = value;
    notifyListeners();
  }
}
