import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/theme/app_colors.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_readonly_field.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/screens/class_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';
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

      expect(find.text('Tạo cán bộ'), findsWidgets);
      expect(find.text('Họ và tên *'), findsOneWidget);
      expect(find.text('Chức vụ *'), findsOneWidget);
      expect(find.text('Email *'), findsOneWidget);
      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Trạng thái làm việc'), findsOneWidget);

      final genderDropdown = find.byKey(const ValueKey('teacher_gender_'));
      await tester.ensureVisible(genderDropdown);
      await tester.pumpAndSettle();
      await tester.tap(genderDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Nam'), findsWidgets);
      expect(find.text('Nữ'), findsWidgets);

      await tester.tap(find.text('Nữ').last);
      await tester.pumpAndSettle();

      final workStatusDropdown = find.byKey(
        const ValueKey('teacher_status_Đang làm việc'),
      );
      await tester.ensureVisible(workStatusDropdown);
      await tester.pumpAndSettle();
      await tester.tap(workStatusDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Đang làm việc'), findsWidgets);
    });

    testWidgets('class create defers teacher assignment until update', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const ClassFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo lớp'), findsOneWidget);
      expect(find.text('Tên lớp *'), findsOneWidget);
      expect(find.text('Năm học *'), findsOneWidget);
      expect(find.text('Khối'), findsOneWidget);
      expect(find.text('Giáo viên phụ trách'), findsNothing);
      expect(find.byKey(const ValueKey('class_teacher_')), findsNothing);
      expect(
        find.text('Phân công giáo viên sau khi tạo lớp xong.'),
        findsOneWidget,
      );

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(2));

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
    });

    testWidgets('editing a class locks its name and grade', (tester) async {
      await tester.pumpWidget(
        await _buildFormTestApp(
          home: const ClassFormScreen(
            schoolClass: SchoolClass(
              id: 301,
              className: 'Mầm 1A',
              schoolYearId: 101,
              ageGroup: 'Mầm',
              room: 'A101',
              assignedTeachers: [
                ClassTeacher(
                  id: 201,
                  accountId: 1002,
                  fullName: 'Nguyễn Thị Lan',
                  position: 'Giáo viên',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppReadonlyField), findsNWidgets(3));
      final readonlyTextFields = tester.widgetList<TextFormField>(
        find.descendant(
          of: find.byType(AppReadonlyField),
          matching: find.byType(TextFormField),
        ),
      );
      for (final field in readonlyTextFields) {
        expect(field.enabled, isFalse);
      }
      final readonlyDecorators = tester.widgetList<InputDecorator>(
        find.descendant(
          of: find.byType(AppReadonlyField),
          matching: find.byType(InputDecorator),
        ),
      );
      for (final decorator in readonlyDecorators) {
        expect(decorator.decoration.fillColor, AppColors.muted);
        expect(decorator.decoration.suffixIcon, isNull);
      }
      expect(find.text('Tên lớp'), findsOneWidget);
      expect(find.text('Năm học'), findsOneWidget);
      expect(find.text('Khối'), findsOneWidget);
      expect(find.byKey(const ValueKey('class_year_101')), findsNothing);
      final teacherDropdown = find.byKey(const ValueKey('class_teacher_'));
      await tester.scrollUntilVisible(
        teacherDropdown,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(teacherDropdown, findsOneWidget);
      expect(find.text('Nguyễn Thị Lan'), findsOneWidget);
      expect(find.byTooltip('Hủy phân công giáo viên'), findsOneWidget);
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
