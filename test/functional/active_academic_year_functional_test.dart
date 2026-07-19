import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/storage/local_storage.dart';
import 'package:sorak_flutter_mamnon/core/widgets/app_shell.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/providers/active_academic_year_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/auth/models/auth_user.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/providers/class_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/providers/form_options_provider.dart';
import 'package:sorak_flutter_mamnon/modules/form_options/repositories/form_options_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/providers/health_assessment_provider.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/students/providers/student_provider.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/providers/teacher_provider.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

import 'helpers/test_app.dart';

void main() {
  group('Active academic year functional test', () {
    test(
      'persists the selected academic year across provider recreation',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final localStorage = LocalStorage(preferences);
        final apiClient = ApiClient.memory();
        final repository = AcademicYearRepository(apiClient: apiClient);

        final firstProvider = ActiveAcademicYearProvider(
          academicYearRepository: repository,
          localStorage: localStorage,
        );
        await firstProvider.loadYears();
        await firstProvider.selectYear(102);

        final restoredProvider = ActiveAcademicYearProvider(
          academicYearRepository: repository,
          localStorage: localStorage,
        );
        await restoredProvider.loadYears();

        expect(restoredProvider.selectedYearId, 102);
        expect(localStorage.getSelectedAcademicYearId(), 102);
      },
    );

    testWidgets('changing AppShell year syncs form options and active list', (
      tester,
    ) async {
      final localStorage = await tester.pumpLoggedInSorakApp();

      final initialShellContext = tester.element(find.byType(AppShell));
      expect(initialShellContext.read<TeacherProvider>().isLoading, isFalse);
      expect(initialShellContext.read<TeacherProvider>().items, isNotEmpty);

      await tester.tap(find.byKey(const ValueKey('nav_students')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('active_year_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2026-2027').last);
      await tester.pumpAndSettle();

      final shellContext = tester.element(find.byType(AppShell));
      expect(
        shellContext.read<ActiveAcademicYearProvider>().selectedYearId,
        103,
      );
      expect(localStorage.getSelectedAcademicYearId(), 103);
      expect(
        shellContext.read<FormOptionsProvider>().selectedAcademicYearId,
        103,
      );
      expect(shellContext.read<ClassProvider>().items, isEmpty);
      expect(shellContext.read<StudentProvider>().items, isEmpty);
      expect(shellContext.read<ClassTransferProvider>().items, isEmpty);
      expect(shellContext.read<IncomingTransferProvider>().items, isEmpty);
      expect(shellContext.read<OutgoingTransferProvider>().items, isEmpty);
      expect(shellContext.read<HealthAssessmentProvider>().items, isEmpty);
    });

    testWidgets('teacher year refresh reloads scoped school transfers', (
      tester,
    ) async {
      const teacher = AuthUser(
        id: 1002,
        fullName: 'Nguyễn Thị Lan',
        email: 'gv01@sorak.local',
        role: 'TEACHER',
      );
      await tester.pumpSorakApp(savedUser: teacher);
      final shellContext = tester.element(find.byType(AppShell));
      final client = shellContext.read<ApiClient>();
      client.mockBackend!.requests.clear();

      await tester.tap(find.byKey(const ValueKey('active_year_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2024-2025').last);
      await tester.pumpAndSettle();

      for (final path in const ['/incoming-transfers', '/outgoing-transfers']) {
        expect(
          client.mockBackend!.requests.any(
            (request) =>
                request.path == path &&
                request.query['school_year_id'] == '102',
          ),
          isTrue,
        );
      }
      expect(
        client.mockBackend!.requests.any(
          (request) => request.path == '/class-transfers',
        ),
        isTrue,
      );
    });

    test('forced form refresh replaces stale class enrollment', () async {
      final client = ApiClient.memory();
      client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
      final options = FormOptionsProvider(
        formOptionsRepository: FormOptionsRepository(
          academicYearRepository: AcademicYearRepository(apiClient: client),
          classRepository: ClassRepository(apiClient: client),
          teacherRepository: TeacherRepository(apiClient: client),
          studentRepository: StudentRepository(apiClient: client),
        ),
      );

      await options.refreshForAcademicYear(101);
      expect(
        options.allStudents.firstWhere((student) => student.id == 401).classId,
        301,
      );

      await ClassTransferRepository(
        apiClient: client,
      ).updateStatus(501, 'approve');
      expect(
        options.allStudents.firstWhere((student) => student.id == 401).classId,
        301,
      );

      await options.refreshForAcademicYear(101);
      expect(
        options.allStudents.firstWhere((student) => student.id == 401).classId,
        302,
      );
    });
  });
}
