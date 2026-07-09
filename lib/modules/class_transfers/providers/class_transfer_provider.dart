import '../../../core/providers/crud_provider.dart';
import '../models/class_transfer.dart';
import '../repositories/class_transfer_repository.dart';

class ClassTransferProvider extends CrudProvider<ClassTransfer> {
  ClassTransferProvider({
    required ClassTransferRepository classTransferRepository,
  }) : _classTransferRepository = classTransferRepository,
       super(repository: classTransferRepository);

  final ClassTransferRepository _classTransferRepository;

  Future<void> updateStatus(int id, String action) async {
    await _classTransferRepository.updateStatus(id, action);
    await loadItems();
  }
}
