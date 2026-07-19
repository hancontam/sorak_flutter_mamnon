import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/providers/student_provider.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/screens/student_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/students/screens/student_guardian_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/students/models/student.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Student form functional test', () {
    testWidgets('uses Vietnamese dropdowns and filters classes by grade', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildFormTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Tạo hồ sơ học sinh'), findsOneWidget);
      expect(find.text('Họ tên *'), findsOneWidget);
      expect(find.text('Ngày sinh *'), findsOneWidget);
      expect(find.text('Giới tính *'), findsOneWidget);
      expect(find.text('Khối'), findsOneWidget);
      expect(find.text('Lớp (tùy chọn)'), findsOneWidget);
      expect(find.text('Tình trạng học vụ'), findsNothing);

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(3));

      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Mầm'), findsWidgets);
      expect(find.text('Chồi'), findsWidgets);

      await tester.tap(find.text('Mầm').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();

      expect(find.textContaining('Mầm 1A'), findsWidgets);
      expect(find.textContaining('Chồi 2B'), findsNothing);

      await tester.tap(find.textContaining('Mầm 1A').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chồi').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();

      expect(find.textContaining('Chồi 2B'), findsWidgets);
      expect(find.textContaining('Mầm 1A'), findsNothing);
    });

    testWidgets('guardian flow offers predefined relationship chips', (
      tester,
    ) async {
      final apiClient = ApiClient.memory();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => StudentProvider(
            studentRepository: StudentRepository(apiClient: apiClient),
          ),
          child: const MaterialApp(
            home: StudentGuardianFormScreen(
              student: Student(
                id: 401,
                fullName: 'Nguyễn Minh An',
                dateOfBirth: '2021-03-10',
                gender: 'Nam',
                contactPhone: '0900000401',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cha'), findsOneWidget);
      expect(find.text('Mẹ'), findsOneWidget);
      expect(find.text('Bà ngoại'), findsOneWidget);
      expect(find.text('Người giám hộ'), findsOneWidget);
      expect(find.text('Họ tên phụ huynh *'), findsOneWidget);
      expect(find.text('Số điện thoại *'), findsOneWidget);
      expect(find.text('Quan hệ với trẻ'), findsOneWidget);
    });

    testWidgets('guardian flow prefills and saves existing parents', (
      tester,
    ) async {
      final apiClient = ApiClient.memory();
      final provider = StudentProvider(
        studentRepository: StudentRepository(apiClient: apiClient),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: StudentGuardianFormScreen(
              student: Student(
                id: 401,
                fullName: 'Nguyễn Minh An',
                dateOfBirth: '2021-03-10',
                gender: 'Nam',
                parents: [
                  StudentParent(
                    id: 2401,
                    fullName: 'Nguyễn Văn Nam',
                    relationship: 'Cha',
                    phone: '0900000401',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nguyễn Văn Nam'), findsOneWidget);
      expect(find.text('0900000401'), findsOneWidget);
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(provider.parentsErrorMessage, isNull);
      expect(find.byType(StudentGuardianFormScreen), findsNothing);
      expect(
        provider.items
            .firstWhere((student) => student.id == 401)
            .parents
            .single
            .fullName,
        'Nguyễn Văn Nam',
      );
    });
  });
}

Future<Widget> _buildFormTestApp() async {
  final apiClient = ApiClient.memory();
  final academicYearRepository = AcademicYearRepository(apiClient: apiClient);
  final classRepository = ClassRepository(apiClient: apiClient);
  final teacherRepository = TeacherRepository(apiClient: apiClient);
  final studentRepository = StudentRepository(apiClient: apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => StudentProvider(studentRepository: studentRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => FormOptionsProvider(
          formOptionsRepository: FormOptionsRepository(
            academicYearRepository: academicYearRepository,
            classRepository: classRepository,
            teacherRepository: teacherRepository,
            studentRepository: studentRepository,
          ),
        ),
      ),
    ],
    child: const MaterialApp(home: StudentFormScreen()),
  );
}
