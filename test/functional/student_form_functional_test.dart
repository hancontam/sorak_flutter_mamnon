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
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Student form functional test', () {
    testWidgets('uses Vietnamese dropdowns and filters classes by grade', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildFormTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Tạo hồ sơ học sinh'), findsOneWidget);
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Ngày sinh'), findsOneWidget);
      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Khối'), findsOneWidget);
      expect(find.text('Lớp'), findsOneWidget);
      expect(find.text('Tình trạng học vụ'), findsOneWidget);

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(4));

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
