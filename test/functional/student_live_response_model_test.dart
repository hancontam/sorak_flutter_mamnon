import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/students/models/student.dart';

void main() {
  test('Student maps the fields returned by the live students endpoint', () {
    final student = Student.fromJson({
      'student_id': 401,
      'student_id_card_number': 'NMK2025.001',
      'full_name': 'Nguyễn Minh Khôi',
      'date_of_birth': '2023-03-12T00:00:00.000Z',
      'gender': 'Nam',
      'grade_level': 'Nhà trẻ',
      'enrollment_date': '2025-09-01T00:00:00.000Z',
      'student_status': 'Đang học',
      'contact_phone': '0901234567',
      'parents': [
        {
          'parent_id': 701,
          'full_name': 'Nguyễn Thị Mai',
          'relationship': 'Mẹ',
          'phone': '0987654321',
        },
      ],
      'current_address': '12 Đường Trần Phú, Kiên Giang',
      'ethnicity': 'Kinh',
      'nationality': 'Việt Nam',
      'religion': 'Không',
      'blood_type': 'O',
      'birth_place': 'Kiên Giang',
      'enrollments': [
        {
          'class_id': 301,
          'class': {'class_name': 'Nhà trẻ 1'},
        },
      ],
    });

    expect(student.studentIdCardNumber, 'NMK2025.001');
    expect(student.gradeLevel, 'Nhà trẻ');
    expect(student.className, 'Nhà trẻ 1');
    expect(student.enrollmentDate, '2025-09-01T00:00:00.000Z');
    expect(student.birthPlace, 'Kiên Giang');
    expect(student.ethnicity, 'Kinh');
    expect(student.nationality, 'Việt Nam');
    expect(student.religion, 'Không');
    expect(student.bloodType, 'O');
    expect(student.currentAddress, '12 Đường Trần Phú, Kiên Giang');
    expect(student.parents, hasLength(1));
    expect(student.parents.single.relationship, 'Mẹ');
    expect(student.parents.single.phone, '0987654321');
  });
}
