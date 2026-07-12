import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/models/teacher.dart';

void main() {
  test('Teacher maps the fields returned by the live teachers endpoint', () {
    final teacher = Teacher.fromJson({
      'teacher_id': 201,
      'full_name': 'Nguyễn Thị Lan',
      'email': 'lan.nguyen@edu.vn',
      'position': 'Giáo viên',
      'phone': '0901000203',
      'gender': 'Nữ',
      'date_of_birth': '1990-04-05T00:00:00.000Z',
      'qualification': 'Cao đẳng Sư phạm Mầm non',
      'work_start_date': '2015-09-01T00:00:00.000Z',
      'address': 'Hòn Tre, Kiên Giang',
      'work_status': 'Đang làm việc',
      'account': {'account_id': 5101},
    });

    expect(teacher.dateOfBirth, '1990-04-05T00:00:00.000Z');
    expect(teacher.qualification, 'Cao đẳng Sư phạm Mầm non');
    expect(teacher.workStartDate, '2015-09-01T00:00:00.000Z');
    expect(teacher.address, 'Hòn Tre, Kiên Giang');
    expect(teacher.accountId, 5101);
  });
}
