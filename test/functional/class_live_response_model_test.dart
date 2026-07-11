import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';

void main() {
  test(
    'SchoolClass maps enrollment count and assigned teachers from live data',
    () {
      final schoolClass = SchoolClass.fromJson({
        'class_id': 301,
        'class_name': 'Mầm 1A',
        'school_year_id': 101,
        'age_group': 'Mầm',
        'room': 'A101',
        '_count': {'enrollments': 24},
        'teacher_classes': [
          {
            'teacher': {
              'teacher_id': 201,
              'account_id': 5101,
              'full_name': 'Nguyễn Thị Lan',
              'position': 'Giáo viên',
            },
          },
          {
            'teacher': {
              'teacher_id': 202,
              'account_id': 5102,
              'full_name': 'Trần Minh Hương',
              'position': 'Giáo viên',
            },
          },
        ],
      });

      expect(schoolClass.studentCount, 24);
      expect(schoolClass.teacherName, 'Nguyễn Thị Lan, Trần Minh Hương');
      expect(schoolClass.assignedTeachers, hasLength(2));
      expect(schoolClass.assignedTeachers.first.id, 201);
      expect(schoolClass.assignedTeachers.first.accountId, 5101);
    },
  );
}
