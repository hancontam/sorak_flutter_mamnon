import '../../../core/providers/crud_provider.dart';
import '../models/outgoing_transfer.dart';
import '../repositories/outgoing_transfer_repository.dart';

class OutgoingTransferProvider extends CrudProvider<OutgoingTransfer> {
  OutgoingTransferProvider({
    required OutgoingTransferRepository outgoingTransferRepository,
  })  : _outgoingTransferRepository = outgoingTransferRepository,
        super(repository: outgoingTransferRepository);

  final OutgoingTransferRepository _outgoingTransferRepository;

  Future<void> cancelTransfer(int id) async {
    await _outgoingTransferRepository.cancel(id);
    await loadItems();
  }
}
