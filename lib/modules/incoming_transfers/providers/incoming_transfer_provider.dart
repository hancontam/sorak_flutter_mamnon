import '../../../core/providers/crud_provider.dart';
import '../models/incoming_transfer.dart';
import '../repositories/incoming_transfer_repository.dart';

class IncomingTransferProvider extends CrudProvider<IncomingTransfer> {
  IncomingTransferProvider({
    required IncomingTransferRepository incomingTransferRepository,
  }) : _incomingTransferRepository = incomingTransferRepository,
       super(repository: incomingTransferRepository);

  final IncomingTransferRepository _incomingTransferRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _incomingTransferRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(
      () => _incomingTransferRepository.getAll(schoolYearId: yearId),
    );
  }

  Future<void> cancelTransfer(int id) async {
    await _incomingTransferRepository.cancel(id);
    await loadItems();
  }
}
