import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/utils/class_sort.dart';
import 'package:sorak_flutter_mamnon/core/utils/student_enrollment.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/health_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/parent/repositories/parent_health_history_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/models/student.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/transfers/widgets/school_transfer_card.dart';

void main() {
  group('Enrollment consistency', () {
    test('sorts every class selector by nursery, Mầm, Chồi, Lá', () {
      const classes = [
        SchoolClass(id: 4, className: 'Lá 1', schoolYearId: 1, ageGroup: 'Lá'),
        SchoolClass(
          id: 2,
          className: 'Mầm 1',
          schoolYearId: 1,
          ageGroup: 'Mầm',
        ),
        SchoolClass(
          id: 1,
          className: 'Nhà trẻ 1',
          schoolYearId: 1,
          ageGroup: 'Nhà trẻ',
        ),
        SchoolClass(
          id: 3,
          className: 'Chồi 1',
          schoolYearId: 1,
          ageGroup: 'Chồi',
        ),
      ];

      expect(sortedClassesByGrade(classes).map((item) => item.ageGroup), [
        'Nhà trẻ',
        'Mầm',
        'Chồi',
        'Lá',
      ]);
    });

    test('current roster excludes ended enrollment statuses and left date', () {
      const current = Student(
        id: 1,
        fullName: 'Đang học',
        dateOfBirth: '2020-01-01',
        gender: 'Nam',
      );
      final transferred = current.copyWith(studentStatus: 'Đã chuyển trường');
      final leftClass = current.copyWith(
        currentEnrollmentLeftDate: '2026-07-14',
      );

      expect(isStudentCurrentlyEnrolled(current), isTrue);
      expect(isStudentCurrentlyEnrolled(transferred), isFalse);
      expect(isStudentCurrentlyEnrolled(leftClass), isFalse);
    });

    test(
      'outgoing transfer immediately returns a non-current student',
      () async {
        final client = ApiClient.memory();
        client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final transfers = OutgoingTransferRepository(apiClient: client);
        final students = StudentRepository(apiClient: client);
        final transfer = await transfers.create({
          'student_id': 401,
          'school_year_id': 101,
          'destination_school': 'Mầm non mới',
          'transfer_date': today,
          'reason': 'Test đồng bộ',
          'note': '',
        });

        final reloadedStudent = await students.getById(401);
        expect(transfer.className, 'Mầm 1A');
        expect(reloadedStudent, isNotNull);
        expect(reloadedStudent!.studentStatus, 'Đã chuyển trường');
        expect(isStudentCurrentlyEnrolled(reloadedStudent), isFalse);

        await transfers.cancel(transfer.id, cancelReason: 'Khôi phục');
        expect(
          isStudentCurrentlyEnrolled((await students.getById(401))!),
          isTrue,
        );
      },
    );

    testWidgets('future recorded transfer uses pending date style', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SchoolTransferCard(
              studentId: 1,
              studentName: 'Học sinh A',
              cardNumber: 'HS001',
              className: 'Mầm 1',
              schoolYearName: '2026-2027',
              schoolLabel: 'Trường chuyển đến',
              schoolValue: 'Trường mới',
              transferDate: '2099-01-01',
              status: 'Recorded',
            ),
          ),
        ),
      );

      expect(find.text('Chưa tới ngày (01/01/2099)'), findsOneWidget);
      final text = tester.widget<Text>(find.text('Chưa tới ngày (01/01/2099)'));
      expect(text.style?.fontStyle, FontStyle.italic);
    });
  });

  group('Parent health history contract', () {
    test(
      'uses owned parent endpoint without student_id and newest first',
      () async {
        final client = ApiClient.memory();
        client.configureMockSession(
          role: 'PARENT',
          accountId: 1101,
          studentId: 401,
        );

        final history = await ParentHealthHistoryRepository(
          apiClient: client,
        ).getHealthHistory();
        final request = client.mockBackend!.requests.last;

        expect(request.method, 'GET');
        expect(request.path, '/parent/health-history');
        expect(request.query, isEmpty);
        expect(history.student.id, 401);
        expect(history.records.map((record) => record.studentId).toSet(), {
          401,
        });
        expect(history.records.first.assessmentDate, '2026-05-10');
      },
    );

    test('rejects staff role and never accepts another student id', () async {
      final client = ApiClient.memory();
      client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);

      await expectLater(
        ParentHealthHistoryRepository(apiClient: client).getHealthHistory(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('Health date filter contract', () {
    test(
      'loads an older exact-date record instead of latest-only data',
      () async {
        final client = ApiClient.memory();
        client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
        final repository = HealthAssessmentRepository(apiClient: client);

        final latest = await repository.getLatest(schoolYearId: 101);
        final exactDate = await repository.getForDate(
          assessmentDate: '2026-01-10',
          schoolYearId: 101,
          classId: 301,
        );

        expect(
          latest.firstWhere((item) => item.studentId == 401).assessmentDate,
          '2026-05-10',
        );
        expect(exactDate.single.assessmentDate, '2026-01-10');
        expect(exactDate.single.studentId, 401);
      },
    );
  });
}
