import '../../../core/providers/crud_provider.dart';
import '../models/class_transfer.dart';
import '../repositories/class_transfer_repository.dart';

class ClassTransferProvider extends CrudProvider<ClassTransfer> {
  ClassTransferProvider({
    required ClassTransferRepository classTransferRepository,
  }) : _classTransferRepository = classTransferRepository,
       super(repository: classTransferRepository);

  final ClassTransferRepository _classTransferRepository;
  int? _academicYearId;

  @override
  Future<void> loadItems() {
    final academicYearId = _academicYearId;
    if (academicYearId == null) {
      return super.loadItems();
    }
    return loadItemsWith(
      () => _classTransferRepository.getAll(schoolYearId: academicYearId),
    );
  }

  Future<void> loadForAcademicYear(int yearId) {
    _academicYearId = yearId;
    return loadItemsWith(
      () => _classTransferRepository.getAll(schoolYearId: yearId),
    );
  }

  Future<void> updateStatus(int id, String action) async {
    await _classTransferRepository.updateStatus(id, action);
    await loadItems();
  }
}
