import '../../../core/providers/crud_provider.dart';
import '../models/teacher.dart';
import '../repositories/teacher_repository.dart';

class TeacherProvider extends CrudProvider<Teacher> {
  TeacherProvider({required TeacherRepository teacherRepository})
      : super(repository: teacherRepository);
}
