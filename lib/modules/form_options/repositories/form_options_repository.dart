import '../../../core/constants/app_options.dart';
import '../../academic_years/models/academic_year.dart';
import '../../academic_years/repositories/academic_year_repository.dart';
import '../../classes/models/school_class.dart';
import '../../classes/repositories/class_repository.dart';
import '../../students/models/student.dart';
import '../../students/repositories/student_repository.dart';
import '../../teachers/models/teacher.dart';
import '../../teachers/repositories/teacher_repository.dart';

class FormOptionsRepository {
  FormOptionsRepository({
    required AcademicYearRepository academicYearRepository,
    required ClassRepository classRepository,
    required TeacherRepository teacherRepository,
    required StudentRepository studentRepository,
  }) : _academicYearRepository = academicYearRepository,
       _classRepository = classRepository,
       _teacherRepository = teacherRepository,
       _studentRepository = studentRepository;

  final AcademicYearRepository _academicYearRepository;
  final ClassRepository _classRepository;
  final TeacherRepository _teacherRepository;
  final StudentRepository _studentRepository;

  Future<List<AcademicYear>> getAcademicYears() async {
    final years = await _academicYearRepository.getAll();
    final visibleYears = years.where((year) => !year.isDeleted).toList();
    visibleYears.sort((a, b) => b.name.compareTo(a.name));
    return visibleYears;
  }

  Future<List<SchoolClass>> getClassesByYear(int? schoolYearId) async {
    final classes = await _classRepository.getAll();
    final visibleClasses = classes.where((schoolClass) {
      if (schoolClass.isDeleted) {
        return false;
      }
      if (schoolYearId == null) {
        return true;
      }
      return schoolClass.schoolYearId == schoolYearId;
    }).toList();

    visibleClasses.sort((a, b) => a.className.compareTo(b.className));
    return visibleClasses;
  }

  Future<List<Teacher>> getWorkingTeachers() async {
    final teachers = await _teacherRepository.getAll();
    final visibleTeachers = teachers.where((teacher) {
      return !teacher.isDeleted && _isWorkingStatus(teacher.workStatus);
    }).toList();

    visibleTeachers.sort((a, b) => a.fullName.compareTo(b.fullName));
    return visibleTeachers;
  }

  Future<List<Student>> getStudentsByClass(int? classId) async {
    final students = await _studentRepository.getAll();
    final visibleStudents = students.where((student) {
      if (student.isDeleted || !student.isActive) {
        return false;
      }
      if (classId == null) {
        return true;
      }
      return student.classId == classId;
    }).toList();

    visibleStudents.sort((a, b) => a.fullName.compareTo(b.fullName));
    return visibleStudents;
  }

  bool _isWorkingStatus(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == TeacherWorkStatusOptions.working.toLowerCase() ||
        normalized == 'dang lam viec';
  }
}
