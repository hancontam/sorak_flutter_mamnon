import '../../modules/students/models/student.dart';
import 'text_normalizer.dart';

bool isStudentCurrentlyEnrolled(Student student) {
  if (student.isDeleted ||
      student.currentEnrollmentLeftDate.trim().isNotEmpty) {
    return false;
  }

  final status = normalizeVietnamese(student.studentStatus).trim();
  const endedStatusParts = <String>[
    'da chuyen truong',
    'chuyen di',
    'thoi hoc',
    'hoan thanh chuong trinh',
  ];
  return !endedStatusParts.any(status.contains);
}
