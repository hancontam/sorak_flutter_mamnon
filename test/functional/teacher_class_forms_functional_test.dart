import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/screens/class_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/providers/teacher_provider.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/screens/teacher_form_screen.dart';

void main() {
  group('Teacher and class forms functional test', () {
    testWidgets('teacher form uses Vietnamese dropdown fields', (tester) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const TeacherFormScreen()),
      );

      expect(find.text('Tạo giáo viên'), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Trạng thái làm việc'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      expect(find.text('Nam'), findsWidgets);
      expect(find.text('Nữ'), findsWidgets);

      await tester.tap(find.text('Nữ').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();

      expect(find.text('Đang làm việc'), findsWidgets);
    });

    testWidgets('class form uses year grade and teacher dropdowns', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const ClassFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo lớp'), findsOneWidget);
      expect(find.text('Tên lớp'), findsOneWidget);
      expect(find.text('Năm học'), findsOneWidget);
      expect(find.text('Khối'), findsOneWidget);
      expect(find.text('Giáo viên'), findsOneWidget);

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(3));

      await tester.tap(dropdowns.at(0));
      await tester.pumpAndSettle();

      expect(find.text('2025-2026'), findsWidgets);

      await tester.tap(find.text('2025-2026').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Nhà trẻ'), findsWidgets);
      expect(find.text('Mầm'), findsWidgets);
      expect(find.text('Chồi'), findsWidgets);
      expect(find.text('Lá'), findsWidgets);

      await tester.tap(find.text('Mầm').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nguyễn Thị Lan'), findsWidgets);
    });
  });
}

Future<Widget> _buildFormTestApp({required Widget home}) async {
  final apiClient = ApiClient.memory();
  final academicYearRepository = AcademicYearRepository(apiClient: apiClient);
  final classRepository = ClassRepository(apiClient: apiClient);
  final teacherRepository = TeacherRepository(apiClient: apiClient);
  final studentRepository = StudentRepository(apiClient: apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => TeacherProvider(teacherRepository: teacherRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => ClassProvider(classRepository: classRepository),
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
    child: MaterialApp(home: home),
  );
}
