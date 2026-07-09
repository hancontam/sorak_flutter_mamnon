import '../../../core/providers/crud_provider.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

class AccountProvider extends CrudProvider<Account> {
  AccountProvider({required AccountRepository accountRepository})
    : super(repository: accountRepository);
}
