import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/constants/app_config.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/network/api_page.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/health_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/parent/repositories/parent_health_history_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

/// Only execute when the process is started with
/// `--dart-define=USE_MOCK_API=false`. Default app config is live, but the
/// shared test bootstrap forces mock — so we clear the override here.
const bool _runLiveContract =
    bool.hasEnvironment('USE_MOCK_API') &&
    !bool.fromEnvironment('USE_MOCK_API');

void main() {
  setUpAll(() {
    if (_runLiveContract) {
      AppConfig.clearUseMockApiOverride();
    }
  });
  tearDownAll(AppConfig.forceMockApiForTests);

  group('Live API contract functional test', () {
    test(
      'core and transfer repositories use backend paths, query names, and ids',
      () async {
        final apiClient = ApiClient.memory();
        final adapter = _ContractAdapter();
        apiClient.dio.httpClientAdapter = adapter;

        final query = const ApiListQuery(
          page: 2,
          pageSize: 10,
          search: 'An',
          sortBy: 'full_name',
          sortOrder: 'asc',
        );

        final academicYears = AcademicYearRepository(apiClient: apiClient);
        await academicYears.getPage(query: query);
        final promotion = await academicYears.promoteStudents(2);
        expect(promotion['promoted'], 3);

        final classes = ClassRepository(apiClient: apiClient);
        await classes.getPage(query: query, schoolYearId: 2, ageGroup: '4-5');
        final classProvider = ClassProvider(classRepository: classes);
        final classUpdated = await classProvider.updateClassSetup(
          classId: 5,
          room: 'A102',
          teacherAccountIdsToAdd: const [81],
          teacherIdsToRemove: const [91],
        );
        expect(classUpdated, isTrue);
        await TeacherRepository(apiClient: apiClient).getPage(
          query: query,
          schoolYearId: 2,
          isActive: true,
          position: 'Giáo viên',
          role: 'TEACHER',
          workStatus: 'Đang làm việc',
        );
        await StudentRepository(apiClient: apiClient).getPage(
          query: query,
          schoolYearId: 2,
          classId: 5,
          gradeLevel: '4-5',
          isActive: true,
          studentStatus: 'Đang học',
        );

        final accounts = AccountRepository(apiClient: apiClient);
        await accounts.getStaffPage(
          query: query,
          role: 'none',
          isActive: false,
          workStatus: 'Đang làm việc',
        );
        final parentPage = await accounts.getParentPage(
          query: query,
          isActive: true,
          studentStatus: 'Đang học',
        );
        expect(parentPage.items.single.accountType, 'parent');

        final classTransfers = ClassTransferRepository(apiClient: apiClient);
        await classTransfers.getPage(
          query: query,
          schoolYearId: 2,
          status: 'Pending',
          classId: 5,
          studentId: 9,
        );
        await classTransfers.updateStatus(12, 'approve', note: 'Đủ điều kiện');

        final incoming = IncomingTransferRepository(apiClient: apiClient);
        await incoming.getPage(
          query: query,
          schoolYearId: 2,
          status: 'Recorded',
          classId: 5,
          studentId: 9,
          previousSchool: 'Mầm non A',
        );
        await incoming.cancel(13, cancelReason: 'Sai hồ sơ');
        await incoming.archive(13);

        final outgoing = OutgoingTransferRepository(apiClient: apiClient);
        await outgoing.getPage(
          query: query,
          schoolYearId: 2,
          status: 'Recorded',
          classId: 5,
          studentId: 9,
        );
        await outgoing.cancel(14, cancelReason: 'Phụ huynh đổi ý');
        await outgoing.archive(14);

        await accounts.assignStaffAccount(
          teacherId: 71,
          role: 'TEACHER',
          password: 'password123',
        );
        await accounts.changeStaffRole(teacherId: 71, role: 'PRINCIPAL');
        await accounts.setStaffActive(accountId: 31, isActive: false);
        await accounts.setParentActive(studentId: 44, isActive: false);
        await accounts.changePassword(accountId: 31, password: 'password456');

        expect(adapter.query('/academic-years'), isEmpty);
        expect(
          adapter.request('POST', '/academic-years/2/promote').body,
          isNull,
        );
        expect(adapter.request('PATCH', '/classes/5').body, {'room': 'A102'});
        expect(
          adapter.requestIndex('POST', '/classes/5/teachers'),
          lessThan(adapter.requestIndex('DELETE', '/classes/5/teachers/91')),
        );
        expect(adapter.query('/classes'), {
          'page': '2',
          'pageSize': '10',
          'search': 'An',
          'sortBy': 'full_name',
          'sortOrder': 'asc',
          'school_year_id': '2',
          'age_group': '4-5',
        });
        expect(adapter.query('/teachers')['school_year_id'], '2');
        expect(adapter.query('/students')['class_id'], '5');
        expect(adapter.query('/accounts', occurrence: 0)['type'], 'staff');
        expect(adapter.query('/accounts', occurrence: 1)['type'], 'parent');
        expect(adapter.query('/class-transfers')['status'], 'Pending');
        expect(
          adapter.query('/incoming-transfers')['previous_school'],
          'Mầm non A',
        );
        expect(adapter.query('/outgoing-transfers')['student_id'], '9');

        expect(adapter.request('PATCH', '/class-transfers/12/status').body, {
          'action': 'approve',
          'note': 'Đủ điều kiện',
        });
        expect(adapter.request('PATCH', '/incoming-transfers/13/cancel').body, {
          'cancel_reason': 'Sai hồ sơ',
        });
        expect(
          adapter.request('DELETE', '/incoming-transfers/13').body,
          isNull,
        );
        expect(adapter.request('PATCH', '/outgoing-transfers/14/cancel').body, {
          'cancel_reason': 'Phụ huynh đổi ý',
        });
        expect(
          adapter.request('DELETE', '/outgoing-transfers/14').body,
          isNull,
        );
        expect(adapter.request('POST', '/accounts/71/assign-role').body, {
          'role': 'TEACHER',
          'password': 'password123',
        });
        expect(adapter.request('PATCH', '/accounts/71/role').body, {
          'role': 'PRINCIPAL',
        });
        expect(adapter.request('PATCH', '/accounts/31/active').body, {
          'is_active': false,
        });
        expect(adapter.request('PATCH', '/students/44/active').body, {
          'is_active': false,
        });
        expect(adapter.request('PATCH', '/accounts/31/password').body, {
          'password': 'password456',
        });
      },
      skip: _runLiveContract
          ? false
          : 'Run with --dart-define=USE_MOCK_API=false.',
    );

    test(
      'health repositories use by-class-date bulk history and latest',
      () async {
        final apiClient = ApiClient.memory();
        final adapter = _ContractAdapter();
        apiClient.dio.httpClientAdapter = adapter;

        final health = HealthAssessmentRepository(apiClient: apiClient);
        await health.getByClassDate(classId: 5, assessmentDate: '2026-07-10');
        await health.bulkSave(
          schoolYearId: 2,
          classId: 5,
          assessmentDate: '2026-07-10',
          rows: [
            {
              'student_id': 9,
              'height_cm': 100.5,
              'weight_kg': 16.2,
              'note': 'ok',
            },
          ],
        );
        await health.getHistory(studentId: 9, schoolYearId: 2);
        await health.getLatest(schoolYearId: 2);
        final parentHistory = await ParentHealthHistoryRepository(
          apiClient: apiClient,
        ).getHealthHistory();
        expect(parentHistory.student.id, 9);

        expect(adapter.query('/health-assessments/by-class-date'), {
          'class_id': '5',
          'assessment_date': '2026-07-10',
        });
        expect(adapter.request('POST', '/health-assessments/bulk').body, {
          'school_year_id': 2,
          'class_id': 5,
          'assessment_date': '2026-07-10',
          'rows': [
            {
              'student_id': 9,
              'height_cm': 100.5,
              'weight_kg': 16.2,
              'note': 'ok',
            },
          ],
        });
        expect(adapter.query('/health-assessments/history'), {
          'student_id': '9',
          'school_year_id': '2',
        });
        expect(adapter.query('/health-assessments')['latest'], 'true');
        expect(adapter.query('/health-assessments')['school_year_id'], '2');
        expect(adapter.query('/parent/health-history'), isEmpty);
      },
      skip: _runLiveContract
          ? false
          : 'Run with --dart-define=USE_MOCK_API=false.',
    );
  });
}

class _ContractAdapter implements HttpClientAdapter {
  final List<_RecordedRequest> _requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requests.add(
      _RecordedRequest(
        method: options.method,
        path: options.path,
        query: options.uri.queryParameters,
        body: options.data,
      ),
    );
    return ResponseBody.fromString(
      jsonEncode(_responseFor(options.path, options.method)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Map<String, String> query(String path, {int occurrence = 0}) {
    return _requests
        .where((request) => request.path == path)
        .elementAt(occurrence)
        .query;
  }

  _RecordedRequest request(String method, String path) {
    return _requests.firstWhere(
      (request) => request.method == method && request.path == path,
    );
  }

  int requestIndex(String method, String path) {
    return _requests.indexWhere(
      (request) => request.method == method && request.path == path,
    );
  }

  bool hasDeleteFor(String pathFragment) {
    return _requests.any(
      (request) =>
          request.method == 'DELETE' && request.path.contains(pathFragment),
    );
  }

  Map<String, dynamic> _responseFor(String path, String method) {
    if (path == '/academic-years/2/promote' && method == 'POST') {
      return {
        'success': true,
        'data': {'promoted': 3, 'graduated': 1, 'skipped': 2, 'inactivated': 0},
      };
    }
    if (path == '/health-assessments/by-class-date') {
      return {
        'success': true,
        'data': [
          {
            'assessment_id': 1,
            'student_id': 9,
            'school_year_id': 2,
            'assessment_date': '2026-07-10',
            'height_cm': 100.5,
            'weight_kg': 16.2,
          },
        ],
      };
    }
    if (path == '/health-assessments/bulk' && method == 'POST') {
      return {
        'success': true,
        'data': {
          'created': 1,
          'updated': 0,
          'skipped': 0,
          'errors': <dynamic>[],
        },
      };
    }
    if (path == '/health-assessments/history') {
      return {
        'success': true,
        'data': {
          'student': {'student_id': 9, 'full_name': 'Bé An', 'gender': 'Nam'},
          'records': [
            {
              'assessment_id': 1,
              'student_id': 9,
              'school_year_id': 2,
              'assessment_date': '2026-07-10',
              'height_cm': 100.5,
              'weight_kg': 16.2,
              'bmi': 16.0,
            },
          ],
        },
      };
    }
    if (path == '/parent/health-history') {
      return {
        'success': true,
        'data': {
          'student': {
            'student_id': 9,
            'full_name': 'Bé An',
            'date_of_birth': '2021-01-01',
            'gender': 'Nam',
          },
          'records': [
            {
              'assessment_id': 1,
              'student_id': 9,
              'school_year_id': 2,
              'assessment_date': '2026-07-10',
              'height_cm': 100.5,
              'weight_kg': 16.2,
              'bmi': 16.0,
            },
          ],
        },
      };
    }
    if (path == '/health-assessments') {
      return {
        'success': true,
        'data': [
          {
            'assessment_id': 1,
            'student_id': 9,
            'school_year_id': 2,
            'assessment_date': '2026-07-10',
            'height_cm': 100.5,
            'weight_kg': 16.2,
            'bmi': 16.0,
            'student': {'full_name': 'Bé An'},
          },
        ],
        'meta': {'page': 1, 'pageSize': 20, 'total': 1, 'totalPages': 1},
      };
    }

    final collectionPath = switch (path) {
      final value when value.contains('class-transfers') => '/class-transfers',
      final value when value.contains('incoming-transfers') =>
        '/incoming-transfers',
      final value when value.contains('outgoing-transfers') =>
        '/outgoing-transfers',
      final value when value.contains('accounts') => '/accounts',
      final value when value.contains('students') => '/students',
      final value when value.startsWith('/classes/') => '/classes',
      final value when value.startsWith('/academic-years/') =>
        '/academic-years',
      _ => path,
    };
    final item = switch (collectionPath) {
      '/academic-years' => {
        'school_year_id': 2,
        'name': '2026-2027',
        'start_date': '2026-08-01',
        'end_date': '2027-05-31',
      },
      '/classes' => {
        'class_id': 5,
        'class_name': 'Lớp Lá 1',
        'school_year_id': 2,
      },
      '/teachers' => {
        'teacher_id': 6,
        'full_name': 'Cô Lan',
        'email': 'lan@example.com',
        'position': 'Giáo viên',
      },
      '/students' => {
        'student_id': 9,
        'full_name': 'Bé An',
        'date_of_birth': '2021-01-01',
        'gender': 'Nam',
      },
      '/accounts' => {
        'teacher_id': 71,
        'full_name': 'Cô Lan',
        'email': 'lan@example.com',
        'account': {'account_id': 31, 'role': 'TEACHER', 'is_active': true},
      },
      '/class-transfers' => {
        'request_id': 12,
        'student_id': 9,
        'student': {'full_name': 'Bé An'},
        'to_class_id': 6,
        'to_class': {'class_name': 'Lớp Lá 2'},
        'reason': 'Đủ điều kiện',
        'effective_date': '2026-09-01',
      },
      '/incoming-transfers' => {
        'transfer_id': 13,
        'student_id': 9,
        'student': {'full_name': 'Bé An'},
        'previous_school': 'Mầm non A',
        'transfer_date': '2026-09-01',
      },
      '/outgoing-transfers' => {
        'transfer_id': 14,
        'student_id': 9,
        'student': {'full_name': 'Bé An'},
        'destination_school': 'Mầm non B',
        'transfer_date': '2026-09-01',
      },
      _ => <String, dynamic>{},
    };
    if (method != 'GET') {
      return {'success': true, 'data': item};
    }
    return {
      'success': true,
      'data': [item],
      'meta': {'page': 2, 'pageSize': 10, 'total': 21, 'totalPages': 3},
    };
  }
}

class _RecordedRequest {
  const _RecordedRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final dynamic body;
}
