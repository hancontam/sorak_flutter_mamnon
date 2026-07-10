import 'package:sorak_flutter_mamnon/modules/academic_years/models/academic_year.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/models/account.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/models/class_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/models/incoming_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/models/outgoing_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/students/models/student.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/models/teacher.dart';

const testAuthUser = AuthUser(
  id: 1001,
  fullName: 'Phan Thị Hòa',
  email: 'phanthihoa@edu.vn',
  role: 'PRINCIPAL',
);

const testAcademicYear = AcademicYear(
  id: 1,
  name: '2025-2026',
  startDate: '2025-08-01',
  endDate: '2026-05-31',
  status: 'active',
);

const testAccount = Account(
  id: 1,
  fullName: 'Nguyen Van Account',
  email: 'account@sorak.edu.vn',
  role: 'STAFF',
  phone: '0900000001',
  gender: 'Male',
);

const testClass = SchoolClass(
  id: 1,
  className: 'Mam 1',
  schoolYearId: 1,
  ageGroup: '3-4',
  room: 'A101',
  teacherName: 'Nguyen Van Teacher',
);

const testTeacher = Teacher(
  id: 1,
  fullName: 'Nguyen Van Teacher',
  email: 'teacher@sorak.edu.vn',
  position: 'Teacher',
  phone: '0900000002',
  gender: 'Male',
);

const testStudent = Student(
  id: 1,
  fullName: 'Nguyen Van Student',
  dateOfBirth: '2021-01-01',
  gender: 'Male',
  classId: 1,
  className: 'Mam 1',
  contactPhone: '0900000003',
);

const testClassTransfer = ClassTransfer(
  id: 1,
  studentId: 1,
  studentName: 'Nguyen Van Student',
  fromClassName: 'Mam 1',
  toClassId: 2,
  toClassName: 'Mam 2',
  reason: 'Family request',
  effectiveDate: '2026-08-01',
);

const testOutgoingTransfer = OutgoingTransfer(
  id: 1,
  studentId: 1,
  studentName: 'Nguyen Van Student',
  destinationSchool: 'Sorak Branch 2',
  transferDate: '2026-08-01',
  reason: 'Move school',
);

const testIncomingTransfer = IncomingTransfer(
  id: 1,
  studentId: 1,
  studentName: 'Nguyen Van Student',
  previousSchool: 'Old Kindergarten',
  transferDate: '2026-08-01',
  reason: 'Move to Sorak',
);
