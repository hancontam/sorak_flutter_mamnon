import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/network/api_exception.dart';
import 'package:sorak_flutter_mamnon/core/network/api_response.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('Canonical mock API', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient.memory();
      client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
    });

    test('uses live envelopes, pagination and backend error shape', () async {
      final response = await client.dio.get(
        '/classes',
        queryParameters: {'school_year_id': 101, 'page': 1, 'pageSize': 1},
      );
      final body = Map<String, dynamic>.from(response.data as Map);

      expect(body['success'], isTrue);
      expect(body['data'], hasLength(1));
      expect(body['meta'], {
        'page': 1,
        'pageSize': 1,
        'total': 2,
        'totalPages': 2,
      });

      try {
        await client.dio.post('/classes', data: {'class_name': 'Thiếu năm'});
        fail('Expected validation error');
      } on DioException catch (error) {
        final apiError = ApiException.from(error);
        expect(apiError.statusCode, 400);
        expect(apiError.message, 'Thiếu dữ liệu bắt buộc');
        expect(apiError.errors, contains('school_year_id'));
        expect(apiError.traceId, startsWith('MOCK-400-POST'));
        expect(apiError.displayMessage, contains('school_year_id'));
      }
    });

    test('all fixtures pass through repository fromJson mapping', () async {
      final years = await AcademicYearRepository(apiClient: client).getAll();
      final classes = await ClassRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);
      final students = await StudentRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);
      final teachers = await TeacherRepository(apiClient: client).getAll();
      final accounts = await AccountRepository(
        apiClient: client,
      ).getStaffAccounts();

      expect(years.map((item) => item.id), [101, 102, 103]);
      expect(classes.map((item) => item.className), ['Mầm 1A', 'Chồi 2B']);
      expect(classes.first.teacherName, 'Nguyễn Thị Lan');
      expect(students.map((item) => item.fullName), [
        'Nguyễn Minh An',
        'Trần Bảo Ngọc',
      ]);
      expect(students.first.classId, 301);
      expect(teachers.first.accountId, 1001);
      expect(accounts.any((item) => !item.hasAccount), isTrue);
    });

    test('three academic years expose distinct and empty datasets', () async {
      final classes = ClassRepository(apiClient: client);
      final students = StudentRepository(apiClient: client);

      expect(await classes.getAll(schoolYearId: 101), hasLength(2));
      expect(await students.getAll(schoolYearId: 101), hasLength(2));
      expect(
        (await classes.getAll(schoolYearId: 102)).single.className,
        'Lá cũ',
      );
      expect(
        (await students.getAll(schoolYearId: 102)).single.fullName,
        'Lê Gia Bảo',
      );
      expect(await classes.getAll(schoolYearId: 103), isEmpty);
      expect(await students.getAll(schoolYearId: 103), isEmpty);
    });

    test('teacher only receives assigned class and students', () async {
      client.configureMockSession(
        role: 'TEACHER',
        accountId: 1002,
        teacherId: 202,
      );

      final classes = await ClassRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);
      final students = await StudentRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);

      expect(classes.map((item) => item.id), [301]);
      expect(students.map((item) => item.id), [401]);
      expect(students.any((item) => item.id == 402), isFalse);
    });

    test('teacher school transfers are scoped by assigned class', () async {
      client.configureMockSession(
        role: 'TEACHER',
        accountId: 1002,
        teacherId: 202,
      );
      client.mockBackend!.outgoingTransfers.first['created_by'] = 1002;

      final incoming = await IncomingTransferRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);
      final outgoing = await OutgoingTransferRepository(
        apiClient: client,
      ).getAll(schoolYearId: 101);

      expect(incoming.map((item) => item.id), [511]);
      expect(outgoing, isEmpty);
    });

    test('ApiResponse rejects unsuccessful fixture envelope', () {
      expect(
        () => ApiResponse.object({
          'success': false,
          'message': 'Dữ liệu không hợp lệ',
          'errors': ['field'],
          'traceId': 'MOCK-400',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('validation errors use readable field messages', () {
      const error = ApiException(
        message: 'Validation failed',
        errors: [
          {'path': 'student_id', 'message': 'Học sinh không hợp lệ'},
          {'path': 'transfer_date', 'message': 'Ngày chuyển không hợp lệ'},
        ],
      );
      expect(
        error.displayMessage,
        'Học sinh không hợp lệ; Ngày chuyển không hợp lệ',
      );
    });
  });
}
