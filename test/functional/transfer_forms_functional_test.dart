import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/providers/class_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/screens/class_transfer_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/screens/incoming_transfer_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/screens/outgoing_transfer_form_screen.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Transfer forms functional test', () {
    testWidgets('class transfer filters students and target classes', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const ClassTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tạo yêu cầu chuyển lớp'), findsOneWidget);
      expect(find.text('Lớp hiện tại *'), findsOneWidget);
      expect(find.text('Học sinh *'), findsOneWidget);
      expect(find.text('Lớp chuyển đến *'), findsOneWidget);
      expect(find.text('Trạng thái'), findsOneWidget);

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(4));

      await tester.tap(dropdowns.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Mầm 1A').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nguyễn Minh An'), findsWidgets);
      expect(find.textContaining('Trần Bảo Ngọc'), findsNothing);

      await tester.tap(find.textContaining('Nguyễn Minh An').last);
      await tester.pumpAndSettle();

      expect(
        find.text('Hiện tại không có lớp cùng khối phù hợp.'),
        findsOneWidget,
      );
    });

    testWidgets('outgoing transfer uses class student and status dropdowns', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const OutgoingTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ghi nhận chuyển trường đi'), findsOneWidget);
      expect(find.text('Trường chuyển đến'), findsOneWidget);

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(2));

      await tester.tap(dropdowns.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Chồi 2B').last);
      await tester.pumpAndSettle();

      await tester.tap(dropdowns.at(1));
      await tester.pumpAndSettle();

      expect(find.textContaining('Trần Bảo Ngọc'), findsWidgets);
      expect(find.textContaining('Nguyễn Minh An'), findsNothing);

      await tester.tap(find.textContaining('Trần Bảo Ngọc').last);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Trạng thái'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final statusDropdown = find.byType(DropdownButtonFormField<String>).last;
      await tester.tap(statusDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Đã ghi nhận'), findsWidgets);
      expect(find.text('Đã hủy'), findsWidgets);
    });

    testWidgets('incoming transfer shows previous school and status dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildFormTestApp(home: const IncomingTransferFormScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ghi nhận chuyển trường đến'), findsOneWidget);
      expect(find.text('Trường chuyển từ'), findsOneWidget);
      expect(find.text('Ngày chuyển'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Trạng thái'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Trạng thái'), findsOneWidget);
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
        create: (_) => ClassTransferProvider(
          classTransferRepository: ClassTransferRepository(
            apiClient: apiClient,
          ),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => OutgoingTransferProvider(
          outgoingTransferRepository: OutgoingTransferRepository(
            apiClient: apiClient,
          ),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => IncomingTransferProvider(
          incomingTransferRepository: IncomingTransferRepository(
            apiClient: apiClient,
          ),
        ),
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
