import '../../../core/providers/crud_provider.dart';
import '../models/school_class.dart';
import '../repositories/class_repository.dart';

class ClassProvider extends CrudProvider<SchoolClass> {
  ClassProvider({required ClassRepository classRepository})
    : super(repository: classRepository);
}
