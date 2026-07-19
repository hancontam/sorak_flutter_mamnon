import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/network/mock_api_backend.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Mutation contracts', () {
    late ApiClient client;
    late MockApiBackend backend;

    setUp(() {
      client = ApiClient.memory();
      client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
      backend = client.mockBackend!;
    });

    test(
      'class uses DTO whitelist and a separate teacher assignment',
      () async {
        final repository = ClassRepository(apiClient: client);
        final created = await repository.create({
          'class_name': 'MOBILE_TEST_Mầm 1C',
          'school_year_id': '101',
          'age_group': 'Mầm',
          'room': 'A103',
          'teacher_account_id': '1002',
          'teacher_name': 'Không được gửi',
          'status': 'UI_ONLY',
        });

        final createRequest = backend.requests.firstWhere(
          (item) => item.method == 'POST' && item.path == '/classes',
        );
        expect(createRequest.body, {
          'class_name': 'MOBILE_TEST_Mầm 1C',
          'school_year_id': 101,
          'age_group': 'Mầm',
          'room': 'A103',
        });
        expect(
          backend.requests.any(
            (item) => item.path == '/classes/${created.id}/teachers',
          ),
          isFalse,
        );
        await repository.assignTeacher(classId: created.id, accountId: 1002);
        expect(
          backend.requests.any(
            (item) =>
                item.path == '/classes/${created.id}/teachers' &&
                item.body['account_id'] == 1002,
          ),
          isTrue,
        );

        await repository.update(created.id, {
          'class_name': 'MOBILE_TEST_Mầm 1C mới',
          'school_year_id': 103,
          'teacher_name': 'Không được gửi',
        });
        final update = backend.requests.lastWhere(
          (item) =>
              item.method == 'PATCH' && item.path == '/classes/${created.id}',
        );
        expect(update.body, {'class_name': 'MOBILE_TEST_Mầm 1C mới'});

        final afterAssignment = await repository.getById(created.id);
        final assignedTeacherId = afterAssignment!.assignedTeachers.single.id;
        await repository.removeTeacher(
          classId: created.id,
          teacherId: assignedTeacherId,
        );
        expect(
          backend.requests.any(
            (item) =>
                item.method == 'DELETE' &&
                item.path ==
                    '/classes/${created.id}/teachers/$assignedTeacherId',
          ),
          isTrue,
        );
        final afterRemoval = await repository.getById(created.id);
        expect(afterRemoval?.assignedTeachers, isEmpty);
      },
    );

    test('class provider creates without assigning a teacher', () async {
      final provider = ClassProvider(
        classRepository: ClassRepository(apiClient: client),
      );
      final success = await provider.createItem({
        'class_name': 'MOBILE_TEST_Lớp chưa phân công',
        'school_year_id': 101,
        'age_group': 'Mầm',
        'room': 'A104',
      });

      expect(success, isTrue);
      expect(
        backend.requests
            .where(
              (request) =>
                  request.method == 'POST' && request.path == '/classes',
            )
            .length,
        1,
      );
      expect(
        backend.requests.any(
          (request) =>
              request.method == 'POST' &&
              request.path.startsWith('/classes/') &&
              request.path.endsWith('/teachers'),
        ),
        isFalse,
      );
      final created = provider.items.singleWhere(
        (item) => item.className == 'MOBILE_TEST_Lớp chưa phân công',
      );
      expect(created.assignedTeachers, isEmpty);
    });

    test(
      'student create omits status and parent batch keeps parent id',
      () async {
        final repository = StudentRepository(apiClient: client);
        await repository.create({
          'full_name': 'MOBILE_TEST_Bé mới',
          'date_of_birth': '2022-01-01',
          'gender': 'Nữ',
          'class_id': 301,
          'grade_level': 'Mầm',
          'student_status': 'Đã chuyển trường',
        });
        final createRequest = backend.requests.lastWhere(
          (request) => request.method == 'POST' && request.path == '/students',
        );
        expect(createRequest.body.containsKey('student_status'), isFalse);

        await repository.updateParents(401, [
          {
            'parent_id': 2401,
            'full_name': 'Phụ huynh cập nhật',
            'relationship': 'Mẹ',
            'phone': '0987654321',
          },
        ]);
        final parentRequest = backend.requests.lastWhere(
          (request) =>
              request.method == 'PATCH' &&
              request.path == '/students/401/parents',
        );
        expect(parentRequest.body['parents'], [
          {
            'parent_id': 2401,
            'full_name': 'Phụ huynh cập nhật',
            'relationship': 'Mẹ',
            'phone': '0987654321',
          },
        ]);
      },
    );

    test('student update removes enrollment-only fields', () async {
      final repository = StudentRepository(apiClient: client);
      await repository.update(401, {
        'full_name': 'Nguyễn Minh An mới',
        'student_status': 'Đang học',
        'class_id': 302,
        'class_name': 'Chồi 2B',
        'grade_level': 'Chồi',
        'ui_only': true,
      });

      final request = backend.requests.lastWhere(
        (item) => item.method == 'PATCH' && item.path == '/students/401',
      );
      expect(request.body, {
        'full_name': 'Nguyễn Minh An mới',
        'student_status': 'Đang học',
      });
    });

    test('transfer create payloads omit display names and status', () async {
      await ClassTransferRepository(apiClient: client).create({
        'student_id': '401',
        'student_name': 'Nguyễn Minh An',
        'from_class_name': 'Mầm 1A',
        'to_class_id': '302',
        'to_class_name': 'Chồi 2B',
        'reason': 'MOBILE_TEST_Chuyển lớp',
        'effective_date': '2026-04-20',
        'status': 'Approved',
      });
      expect(
        backend.requests
            .lastWhere((item) => item.path == '/class-transfers')
            .body,
        {
          'student_id': 401,
          'to_class_id': 302,
          'reason': 'MOBILE_TEST_Chuyển lớp',
          'effective_date': '2026-04-20',
        },
      );

      await IncomingTransferRepository(apiClient: client).create({
        'student_id': '401',
        'student_name': 'UI only',
        'school_year_id': '101',
        'previous_school': 'MOBILE_TEST_Trường cũ',
        'transfer_date': '2026-04-21',
        'reason': '',
        'note': '',
        'status': 'Cancelled',
      });
      final incoming = backend.requests.lastWhere(
        (item) => item.path == '/incoming-transfers',
      );
      expect(incoming.body.containsKey('student_name'), isFalse);
      expect(incoming.body.containsKey('status'), isFalse);

      await OutgoingTransferRepository(apiClient: client).create({
        'student_id': 402,
        'school_year_id': 101,
        'destination_school': 'MOBILE_TEST_Trường mới',
        'transfer_date': '2026-04-22',
        'status': 'Cancelled',
      });
      final outgoing = backend.requests.lastWhere(
        (item) => item.path == '/outgoing-transfers',
      );
      expect(outgoing.body.containsKey('status'), isFalse);
      expect(outgoing.body['school_year_id'], 101);
    });

    test('new teacher appears unassigned then receives an account', () async {
      final teacherRepository = TeacherRepository(apiClient: client);
      final accountRepository = AccountRepository(apiClient: client);

      final teacher = await teacherRepository.create({
        'full_name': 'MOBILE_TEST_Nguyễn Thị Mai',
        'email': 'mobile_test_mai@sorak.local',
        'position': 'Giáo viên',
        'gender': 'Nữ',
        'work_status': 'Đang làm việc',
      });
      var staff = await accountRepository.getStaffAccounts();
      expect(
        staff.singleWhere((item) => item.teacherId == teacher.id).hasAccount,
        isFalse,
      );

      await accountRepository.assignStaffAccount(
        teacherId: teacher.id,
        role: 'TEACHER',
        password: 'Test@12345',
      );
      staff = await accountRepository.getStaffAccounts();
      final assigned = staff.singleWhere(
        (item) => item.teacherId == teacher.id,
      );
      expect(assigned.hasAccount, isTrue);
      expect(assigned.role, 'TEACHER');

      await accountRepository.changeStaffRole(
        teacherId: teacher.id,
        role: 'PRINCIPAL',
      );
      staff = await accountRepository.getStaffAccounts();
      expect(
        staff.singleWhere((item) => item.teacherId == teacher.id).role,
        'PRINCIPAL',
      );
    });
  });
}
