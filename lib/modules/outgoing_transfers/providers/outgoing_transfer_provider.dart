import '../../../core/providers/crud_provider.dart';
import '../models/outgoing_transfer.dart';
import '../repositories/outgoing_transfer_repository.dart';

class OutgoingTransferProvider extends CrudProvider<OutgoingTransfer> {
  OutgoingTransferProvider({
    required OutgoingTransferRepository outgoingTransferRepository,
  }) : _outgoingTransferRepository = outgoingTransferRepository,
       super(repository: outgoingTransferRepository);

  final OutgoingTransferRepository _outgoingTransferRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _outgoingTransferRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(
      () => _outgoingTransferRepository.getAll(schoolYearId: yearId),
    );
  }

  Future<void> cancelTransfer(int id) async {
    await _outgoingTransferRepository.cancel(id);
    await loadItems();
  }
}
