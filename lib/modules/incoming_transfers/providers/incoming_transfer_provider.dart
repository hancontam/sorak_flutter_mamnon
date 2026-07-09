import '../../../core/providers/crud_provider.dart';
import '../models/incoming_transfer.dart';
import '../repositories/incoming_transfer_repository.dart';

class IncomingTransferProvider extends CrudProvider<IncomingTransfer> {
  IncomingTransferProvider({
    required IncomingTransferRepository incomingTransferRepository,
  })  : _incomingTransferRepository = incomingTransferRepository,
        super(repository: incomingTransferRepository);

  final IncomingTransferRepository _incomingTransferRepository;

  Future<void> cancelTransfer(int id) async {
    await _incomingTransferRepository.cancel(id);
    await loadItems();
  }
}
