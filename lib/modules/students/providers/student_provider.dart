import '../../../core/providers/crud_provider.dart';
import '../models/student.dart';
import '../repositories/student_repository.dart';

class StudentProvider extends CrudProvider<Student> {
  StudentProvider({required StudentRepository studentRepository})
      : super(repository: studentRepository);
}
