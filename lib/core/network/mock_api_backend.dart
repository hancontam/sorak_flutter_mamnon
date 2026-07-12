import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class MockApiBackend implements HttpClientAdapter {
  MockApiBackend() {
    reset();
  }

  String _role = 'PRINCIPAL';
  int _accountId = 1001;
  int? _teacherId = 201;
  int? _studentId;

  final List<MockApiRequest> requests = [];

  late List<Map<String, dynamic>> years;
  late List<Map<String, dynamic>> teachers;
  late List<Map<String, dynamic>> classes;
  late List<Map<String, dynamic>> students;
  late List<Map<String, dynamic>> classTransfers;
  late List<Map<String, dynamic>> incomingTransfers;
  late List<Map<String, dynamic>> outgoingTransfers;
  late List<Map<String, dynamic>> healthAssessments;
  late List<Map<String, dynamic>> nutritionAssessments;

  void configureSession({
    required String role,
    required int accountId,
    int? teacherId,
    int? studentId,
  }) {
    _role = role.toUpperCase();
    final canonicalAccountId = _canonicalAccountId(_role, accountId);
    _accountId = canonicalAccountId;
    _teacherId = teacherId ?? _teacherIdForAccount(canonicalAccountId);
    _studentId = studentId ?? _studentIdForAccount(canonicalAccountId);
  }

  void reset() {
    requests.clear();
    years = [
      {
        'school_year_id': 101,
        'name': '2025-2026',
        'start_date': '2025-08-01',
        'end_date': '2026-05-31',
        'status': 'active',
        'deleted_at': null,
      },
      {
        'school_year_id': 102,
        'name': '2024-2025',
        'start_date': '2024-08-01',
        'end_date': '2025-05-31',
        'status': 'inactive',
        'deleted_at': null,
      },
      {
        'school_year_id': 103,
        'name': '2026-2027',
        'start_date': '2026-08-01',
        'end_date': '2027-05-31',
        'status': 'inactive',
        'deleted_at': null,
      },
    ];
    teachers = [
      _teacher(
        id: 201,
        accountId: 1001,
        name: 'Phan Thị Hòa',
        email: 'phanthihoa@edu.vn',
        position: 'Hiệu trưởng',
        role: 'PRINCIPAL',
      ),
      _teacher(
        id: 202,
        accountId: 1002,
        name: 'Nguyễn Thị Lan',
        email: 'gv01@sorak.local',
        position: 'Giáo viên',
        role: 'TEACHER',
      ),
      _teacher(
        id: 203,
        accountId: 1003,
        name: 'Trần Thị Hoa',
        email: 'gv03@sorak.local',
        position: 'Giáo viên',
        role: 'TEACHER',
      ),
      _teacher(
        id: 204,
        name: 'Lê Minh Anh',
        email: 'minhanh@edu.vn',
        position: 'Giáo viên',
      ),
    ];
    classes = [
      _schoolClass(
        id: 301,
        yearId: 101,
        name: 'Mầm 1A',
        ageGroup: 'Mầm',
        room: 'A101',
        teacherId: 202,
      ),
      _schoolClass(
        id: 302,
        yearId: 101,
        name: 'Chồi 2B',
        ageGroup: 'Chồi',
        room: 'B202',
        teacherId: 203,
      ),
      _schoolClass(
        id: 303,
        yearId: 102,
        name: 'Lá cũ',
        ageGroup: 'Lá',
        room: 'C301',
        teacherId: 202,
      ),
    ];
    students = [
      _student(
        id: 401,
        accountId: 1101,
        card: 'NMA2025.001',
        name: 'Nguyễn Minh An',
        gender: 'Nam',
        dateOfBirth: '2021-03-10',
        classId: 301,
        yearId: 101,
      ),
      _student(
        id: 402,
        accountId: 1102,
        card: 'TBN2025.002',
        name: 'Trần Bảo Ngọc',
        gender: 'Nữ',
        dateOfBirth: '2020-09-21',
        classId: 302,
        yearId: 101,
      ),
      _student(
        id: 403,
        accountId: 1103,
        card: 'LGB2024.003',
        name: 'Lê Gia Bảo',
        gender: 'Nam',
        dateOfBirth: '2019-12-12',
        classId: 303,
        yearId: 102,
      ),
    ];
    classTransfers = [
      _classTransfer(501, 401, 301, 302, 'Pending'),
      _classTransfer(502, 402, 302, 301, 'Approved'),
      _classTransfer(503, 403, 303, 303, 'Cancelled'),
    ];
    classTransfers.first['requested_by'] = 1002;
    classTransfers.first['requester'] = _requesterByAccountId(1002);
    incomingTransfers = [
      _schoolTransfer(
        id: 511,
        studentId: 401,
        classId: 301,
        yearId: 101,
        status: 'Recorded',
        previousSchool: 'Mầm non Hướng Dương',
      ),
    ];
    outgoingTransfers = [
      _schoolTransfer(
        id: 521,
        studentId: 402,
        classId: 302,
        yearId: 101,
        status: 'Cancelled',
        destinationSchool: 'Mầm non Hoa Mai',
      ),
    ];
    healthAssessments = [
      _health(601, 401, 301, 101, '2026-05-10', 102, 16.5),
      _health(602, 401, 301, 101, '2026-01-10', 100, 15.8),
      _health(603, 402, 302, 101, '2026-05-10', 109, 18.2),
      _health(604, 403, 303, 102, '2025-05-10', 112, 19.1),
    ];
    nutritionAssessments = [
      _nutrition(611, 401, 301, 101, 'dau_nam'),
      _nutrition(612, 402, 302, 101, 'dau_nam', isObese: true),
      _nutrition(613, 403, 303, 102, 'cuoi_nam'),
    ];
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = _normalizePath(options.uri.path);
    final method = options.method.toUpperCase();
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : <String, dynamic>{};
    requests.add(
      MockApiRequest(
        method: method,
        path: path,
        query: Map<String, String>.from(options.uri.queryParameters),
        body: Map<String, dynamic>.from(body),
      ),
    );

    try {
      final result = _dispatch(method, path, options.uri.queryParameters, body);
      return _response(result.statusCode, result.body, headers: result.headers);
    } on _MockApiFailure catch (error) {
      return _response(error.statusCode, {
        'success': false,
        'message': error.message,
        'errors': error.errors,
        'traceId': 'MOCK-${error.statusCode}-$method',
      });
    }
  }

  _MockResult _dispatch(
    String method,
    String path,
    Map<String, String> query,
    Map<String, dynamic> body,
  ) {
    if (path == '/auth/login' && method == 'POST') {
      final requestedEmail = '${body['email']}'.toLowerCase();
      final email = requestedEmail == 'admin@sorak.edu.vn'
          ? 'phanthihoa@edu.vn'
          : requestedEmail;
      final teacher = teachers.firstWhere(
        (item) => '${item['email']}'.toLowerCase() == email,
        orElse: () => <String, dynamic>{},
      );
      if (teacher.isEmpty || body['password'] != '123456') {
        throw const _MockApiFailure(401, 'Email hoặc mật khẩu không đúng');
      }
      final account = teacher['account'] as Map<String, dynamic>?;
      configureSession(
        role: '${account?['role'] ?? 'TEACHER'}',
        accountId: (account?['account_id'] as num?)?.toInt() ?? 1002,
        teacherId: (teacher['teacher_id'] as num).toInt(),
      );
      return _object({
        'user': _staffProfile(teacher),
      }, headers: _sessionHeaders);
    }
    if (path == '/auth/parent-login' && method == 'POST') {
      final requestedCard = '${body['student_id_card_number']}';
      final card = requestedCard == 'NBA2024.001'
          ? 'NMA2025.001'
          : requestedCard;
      final student = students.firstWhere(
        (item) => item['student_id_card_number'] == card,
        orElse: () => <String, dynamic>{},
      );
      if (student.isEmpty || body['password'] != '123456') {
        throw const _MockApiFailure(401, 'Mã thẻ hoặc mật khẩu không đúng');
      }
      configureSession(
        role: 'PARENT',
        accountId: (student['account_id'] as num).toInt(),
        studentId: (student['student_id'] as num).toInt(),
      );
      return _object({
        'user': {
          'account_id': _accountId,
          'student_id': _studentId,
          'student_id_card_number': student['student_id_card_number'],
          'full_name': student['full_name'],
          'email': '',
          'role': 'PARENT',
        },
      }, headers: _sessionHeaders);
    }
    if (path == '/auth/me' && method == 'GET') {
      if (_role == 'PARENT') {
        return _object(_parentProfile());
      }
      final teacher = teachers.firstWhere(
        (item) => item['teacher_id'] == _teacherId,
      );
      return _object(_staffProfile(teacher));
    }
    if (path == '/auth/refresh' && method == 'POST') {
      return _object(const {}, headers: _sessionHeaders);
    }
    if (path == '/auth/logout' && method == 'POST') {
      return _object(const {});
    }
    if (path == '/auth/change-password' && method == 'POST') {
      return _object(const {});
    }

    if (path == '/academic-years') {
      _requireStaff();
      if (method == 'GET') return _list(_active(years));
      if (method == 'POST') {
        _requirePrincipal();
        _requireFields(body, ['name', 'start_date', 'end_date']);
        final item = {
          'school_year_id': _nextId(years, 'school_year_id'),
          ...body,
          'status': 'inactive',
          'deleted_at': null,
        };
        years.add(item);
        return _object(item);
      }
    }
    final yearId = _pathId(path, '/academic-years/');
    if (yearId != null) {
      _requireStaff();
      final item = _find(years, 'school_year_id', yearId);
      if (method == 'GET') return _object(item);
      _requirePrincipal();
      if (path.endsWith('/activate') && method == 'PATCH') {
        for (final year in years) {
          year['status'] = year['school_year_id'] == yearId
              ? 'active'
              : 'inactive';
        }
        return _object(item);
      }
      if (path.endsWith('/restore') && method == 'POST') {
        item['deleted_at'] = null;
        return _object(item);
      }
      if (method == 'PATCH') {
        item.addAll(body);
        return _object(item);
      }
      if (method == 'DELETE') {
        item['deleted_at'] = '2026-07-10T00:00:00Z';
        return _object(item);
      }
    }

    if (path == '/classes' && method == 'GET') {
      _requireStaff();
      var items = _active(classes);
      final yearId = int.tryParse(query['school_year_id'] ?? '');
      if (yearId != null) {
        items = items
            .where((item) => item['school_year_id'] == yearId)
            .toList();
      }
      if (_role == 'TEACHER') {
        items = items.where(_isAssignedClass).toList();
      }
      return _paged(items, query);
    }
    if (path == '/classes' && method == 'POST') {
      _requirePrincipal();
      _rejectUnknown(body, [
        'class_name',
        'school_year_id',
        'age_group',
        'room',
      ]);
      _requireFields(body, ['class_name', 'school_year_id']);
      final item = {
        'class_id': _nextId(classes, 'class_id'),
        ...body,
        'teacher_classes': <dynamic>[],
        'deleted_at': null,
      };
      classes.add(item);
      return _object(item);
    }
    final classTeacherMatch = RegExp(
      r'^/classes/(\d+)/teachers/(\d+)$',
    ).firstMatch(path);
    if (classTeacherMatch != null && method == 'DELETE') {
      _requirePrincipal();
      final classId = int.parse(classTeacherMatch.group(1)!);
      final teacherId = int.parse(classTeacherMatch.group(2)!);
      final item = _find(classes, 'class_id', classId);
      (item['teacher_classes'] as List).removeWhere((assignment) {
        final teacher = (assignment as Map)['teacher'];
        return teacher is Map && teacher['teacher_id'] == teacherId;
      });
      return _object(item);
    }
    final classId = _pathId(path, '/classes/');
    if (classId != null) {
      _requireStaff();
      final item = _find(classes, 'class_id', classId);
      if (_role == 'TEACHER' && !_isAssignedClass(item)) {
        throw const _MockApiFailure(403, 'Không có quyền xem lớp này');
      }
      if (method == 'GET') return _object(item);
      _requirePrincipal();
      if (path.contains('/teachers') && method == 'POST') {
        final accountId = _asInt(body['account_id']);
        final teacher = teachers.firstWhere(
          (value) => value['account_id'] == accountId,
        );
        (item['teacher_classes'] as List).add({
          'teacher': _teacherSummary(teacher),
        });
        return _object(item);
      }
      if (path.endsWith('/restore') && method == 'PATCH') {
        item['deleted_at'] = null;
        return _object(item);
      }
      if (method == 'PATCH') {
        _rejectUnknown(body, [
          'class_name',
          'school_year_id',
          'age_group',
          'room',
        ]);
        item.addAll(body);
        return _object(item);
      }
      if (method == 'DELETE') {
        item['deleted_at'] = '2026-07-10T00:00:00Z';
        return _object(item);
      }
    }

    if (path == '/teachers' && method == 'GET') {
      _requireStaff();
      var items = _active(teachers);
      final workStatus = query['work_status'];
      if (workStatus != null) {
        items = items
            .where((item) => item['work_status'] == workStatus)
            .toList();
      }
      return _paged(items, query);
    }
    if (path == '/teachers' && method == 'POST') {
      _requirePrincipal();
      _requireFields(body, ['full_name', 'email', 'position']);
      final item = {
        'teacher_id': _nextId(teachers, 'teacher_id'),
        ...body,
        'work_status': body['work_status'] ?? 'Đang làm việc',
        'account_id': null,
        'account': null,
        'deleted_at': null,
      };
      teachers.add(item);
      return _object(item);
    }
    final teacherId = _pathId(path, '/teachers/');
    if (teacherId != null) {
      _requireStaff();
      final item = _find(teachers, 'teacher_id', teacherId);
      if (method == 'GET') return _object(item);
      _requirePrincipal();
      if (path.endsWith('/restore') && method == 'PATCH') {
        item['deleted_at'] = null;
      } else if (method == 'PATCH') {
        item.addAll(body);
      } else if (method == 'DELETE') {
        item['deleted_at'] = '2026-07-10T00:00:00Z';
      }
      return _object(item);
    }

    if (path == '/students' && method == 'GET') {
      _requireStaff();
      var items = _active(students);
      final yearId = int.tryParse(query['school_year_id'] ?? '');
      final classId = int.tryParse(query['class_id'] ?? '');
      if (yearId != null) {
        items = items.where((item) => _studentYear(item) == yearId).toList();
      }
      if (classId != null) {
        items = items.where((item) => _studentClass(item) == classId).toList();
      }
      if (_role == 'TEACHER') {
        final allowed = classes
            .where(_isAssignedClass)
            .map((item) => item['class_id'])
            .toSet();
        items = items
            .where((item) => allowed.contains(_studentClass(item)))
            .toList();
      }
      return _paged(items, query);
    }
    if (path == '/students' && method == 'POST') {
      _requireStaff();
      _rejectUnknown(body, [
        'full_name',
        'date_of_birth',
        'gender',
        'grade_level',
        'enrollment_date',
        'ethnicity',
        'nationality',
        'religion',
        'blood_type',
        'birth_place',
        'contact_phone',
        'permanent_province',
        'permanent_ward',
        'permanent_address_detail',
        'current_address',
        'hometown_province',
        'hometown_ward',
        'photo_url',
        'class_id',
        'parents',
      ]);
      _requireFields(body, ['full_name', 'date_of_birth', 'gender']);
      final newId = _nextId(students, 'student_id');
      final selectedClassId = _asInt(body['class_id']);
      final selectedClass = classes.firstWhere(
        (item) => item['class_id'] == selectedClassId,
        orElse: () => <String, dynamic>{},
      );
      final item = _student(
        id: newId,
        accountId: 1100 + newId,
        card: 'MOBILE$newId',
        name: '${body['full_name']}',
        gender: '${body['gender']}',
        dateOfBirth: '${body['date_of_birth']}',
        classId: selectedClassId ?? 0,
        yearId: (selectedClass['school_year_id'] as num?)?.toInt() ?? 101,
      )..addAll(body);
      students.add(item);
      return _object(item);
    }
    final studentId = _pathId(path, '/students/');
    if (studentId != null) {
      _requireStaff();
      final item = _find(students, 'student_id', studentId);
      if (method == 'GET') return _object(item);
      if (path.endsWith('/active') && method == 'PATCH') {
        _requirePrincipal();
        (item['account'] as Map<String, dynamic>)['is_active'] =
            body['is_active'];
        return _object(item);
      }
      if (path.endsWith('/restore') && method == 'PATCH') {
        _requirePrincipal();
        item['deleted_at'] = null;
        return _object(item);
      }
      if (method == 'PATCH') {
        _rejectUnknown(body, [
          'full_name',
          'student_status',
          'date_of_birth',
          'gender',
          'enrollment_date',
          'ethnicity',
          'nationality',
          'religion',
          'area_type',
          'blood_type',
          'contact_phone',
          'birth_place',
          'permanent_province',
          'permanent_ward',
          'permanent_address_detail',
          'current_address',
          'hometown_province',
          'hometown_ward',
          'photo_url',
        ]);
        item.addAll(body);
        return _object(item);
      }
      if (method == 'DELETE') {
        _requirePrincipal();
        item['deleted_at'] = '2026-07-10T00:00:00Z';
        return _object(item);
      }
    }

    if (path == '/accounts' && method == 'GET') {
      _requirePrincipal();
      final type = query['type'] ?? 'staff';
      var items = type == 'parent'
          ? _active(
              students,
            ).where((item) => item['account_id'] != null).toList()
          : _active(teachers);
      final role = query['role'];
      final active = query['is_active'];
      final workStatus = query['work_status'];
      final studentStatus = query['student_status'];
      if (role != null) {
        items = items
            .where((item) => (item['account'] as Map?)?['role'] == role)
            .toList();
      }
      if (active != null) {
        final expected = active == 'true';
        items = items
            .where(
              (item) =>
                  ((item['account'] as Map?)?['is_active'] ?? true) == expected,
            )
            .toList();
      }
      if (workStatus != null) {
        items = items
            .where((item) => item['work_status'] == workStatus)
            .toList();
      }
      if (studentStatus != null) {
        items = items
            .where((item) => item['student_status'] == studentStatus)
            .toList();
      }
      return _paged(items, query);
    }
    final accountActionId = _pathId(path, '/accounts/');
    if (accountActionId != null) {
      _requirePrincipal();
      if (path.endsWith('/assign-role') && method == 'POST') {
        final teacher = _find(teachers, 'teacher_id', accountActionId);
        final accountId = 1000 + accountActionId;
        teacher['account_id'] = accountId;
        teacher['account'] = {
          'account_id': accountId,
          'role': body['role'],
          'is_active': true,
        };
        return _object(teacher['account'] as Map<String, dynamic>);
      }
      if (path.endsWith('/role') && method == 'PATCH') {
        final teacher = _find(teachers, 'teacher_id', accountActionId);
        final account = teacher['account'] as Map<String, dynamic>?;
        if (account == null) {
          throw const _MockApiFailure(400, 'Cán bộ chưa được cấp tài khoản');
        }
        account['role'] = body['role'];
        return _object(teacher);
      }
      final owner = _accountOwner(accountActionId);
      final account = owner['account'] as Map<String, dynamic>;
      if (path.endsWith('/active') && method == 'PATCH') {
        account['is_active'] = body['is_active'];
      }
      if (path.endsWith('/password') && method == 'PATCH') {
        return _object(account);
      }
      if (path.endsWith('/restore') && method == 'PATCH') {
        owner['deleted_at'] = null;
      }
      if (method == 'DELETE') owner['deleted_at'] = '2026-07-10T00:00:00Z';
      return _object(owner);
    }

    if (path == '/class-transfers' && method == 'GET') {
      _requireStaff();
      var items = List<Map<String, dynamic>>.from(classTransfers);
      final yearId = int.tryParse(query['school_year_id'] ?? '');
      if (yearId != null) {
        items = items
            .where((item) => item['school_year_id'] == yearId)
            .toList();
      }
      if (_role == 'TEACHER') {
        items = items
            .where((item) => item['requested_by'] == _accountId)
            .toList();
      }
      return _paged(items, query);
    }
    if (path == '/class-transfers' && method == 'POST') {
      _requireStaff();
      _rejectUnknown(body, [
        'student_id',
        'to_class_id',
        'reason',
        'effective_date',
      ]);
      _requireFields(body, [
        'student_id',
        'to_class_id',
        'reason',
        'effective_date',
      ]);
      final studentId = _asInt(body['student_id'])!;
      final student = _find(students, 'student_id', studentId);
      final fromClassId = _studentClass(student);
      final item =
          _classTransfer(
            _nextId(classTransfers, 'request_id'),
            studentId,
            fromClassId,
            _asInt(body['to_class_id'])!,
            'Pending',
          )..addAll({
            'reason': body['reason'],
            'effective_date': body['effective_date'],
            'requested_by': _accountId,
            'requester': _requesterByAccountId(_accountId),
          });
      classTransfers.add(item);
      return _object(item);
    }
    final classTransferId = _pathId(path, '/class-transfers/');
    if (classTransferId != null) {
      _requireStaff();
      final item = _find(classTransfers, 'request_id', classTransferId);
      if (method == 'GET') return _object(item);
      if (path.endsWith('/status') && method == 'PATCH') {
        final action = '${body['action']}';
        if ((action == 'approve' || action == 'reject' || action == 'revert') &&
            _role != 'PRINCIPAL') {
          throw const _MockApiFailure(
            403,
            'Chỉ Ban Giám Hiệu được duyệt yêu cầu',
          );
        }
        item['status'] = {
          'approve': 'Approved',
          'reject': 'Rejected',
          'cancel': 'Cancelled',
          'revert': 'Pending',
        }[action];
        item['review_note'] = body['note'];
        if (action == 'approve' || action == 'revert') {
          final student = _find(
            students,
            'student_id',
            (item['student_id'] as num).toInt(),
          );
          final targetClassId = action == 'approve'
              ? (item['to_class_id'] as num).toInt()
              : (item['from_class_id'] as num).toInt();
          final targetClass = _find(classes, 'class_id', targetClassId);
          final enrollment = (student['enrollments'] as List).first as Map;
          enrollment['class_id'] = targetClassId;
          enrollment['school_year_id'] = targetClass['school_year_id'];
          enrollment['class'] = {
            ...targetClass,
            'school_year': {
              'name': _find(
                years,
                'school_year_id',
                (targetClass['school_year_id'] as num).toInt(),
              )['name'],
            },
          };
        }
        return _object(item);
      }
    }

    if (path == '/incoming-transfers' || path == '/outgoing-transfers') {
      _requireStaff();
      final source = path.startsWith('/incoming')
          ? incomingTransfers
          : outgoingTransfers;
      if (method == 'GET') {
        var items = _scopeSchoolTransfers(source);
        final yearId = int.tryParse(query['school_year_id'] ?? '');
        final classId = int.tryParse(query['class_id'] ?? '');
        final studentId = int.tryParse(query['student_id'] ?? '');
        final status = query['status'];
        if (yearId != null) {
          items = items
              .where((item) => item['school_year_id'] == yearId)
              .toList();
        }
        if (classId != null) {
          items = items.where((item) => item['class_id'] == classId).toList();
        }
        if (studentId != null) {
          items = items
              .where((item) => item['student_id'] == studentId)
              .toList();
        }
        if (status != null) {
          items = items.where((item) => item['status'] == status).toList();
        }
        return _paged(items, query);
      }
      _requirePrincipal();
      if (method == 'POST') {
        final allowed = path.startsWith('/incoming')
            ? [
                'student_id',
                'school_year_id',
                'previous_school',
                'transfer_date',
                'reason',
                'note',
              ]
            : [
                'student_id',
                'school_year_id',
                'destination_school',
                'transfer_date',
                'reason',
                'note',
              ];
        _rejectUnknown(body, allowed);
        final item = {
          'transfer_id': _nextId(source, 'transfer_id'),
          ...body,
          'status': 'Recorded',
          'student': _studentSummary(
            _find(students, 'student_id', _asInt(body['student_id'])!),
          ),
          'deleted_at': null,
        };
        source.add(item);
        return _object(item);
      }
    }
    final schoolTransfer = _schoolTransferRoute(method, path, body);
    if (schoolTransfer != null) return schoolTransfer;

    final healthResult = _healthRoute(method, path, query, body);
    if (healthResult != null) return healthResult;
    final nutritionResult = _nutritionRoute(method, path, query, body);
    if (nutritionResult != null) return nutritionResult;

    throw _MockApiFailure(
      404,
      'Mock endpoint chưa được khai báo: $method $path',
    );
  }

  _MockResult? _schoolTransferRoute(
    String method,
    String path,
    Map<String, dynamic> body,
  ) {
    final incoming = path.startsWith('/incoming-transfers/');
    final outgoing = path.startsWith('/outgoing-transfers/');
    if (!incoming && !outgoing) return null;
    _requireStaff();
    final source = incoming ? incomingTransfers : outgoingTransfers;
    final id = _pathId(
      path,
      incoming ? '/incoming-transfers/' : '/outgoing-transfers/',
    )!;
    final item = _find(source, 'transfer_id', id);
    if (method == 'GET') return _object(item);
    _requirePrincipal();
    if (path.endsWith('/cancel') && method == 'PATCH') {
      item['status'] = 'Cancelled';
      item['cancel_reason'] = body['cancel_reason'];
    } else if (method == 'PATCH') {
      final allowed = incoming
          ? ['previous_school', 'transfer_date', 'reason', 'note']
          : ['destination_school', 'transfer_date', 'reason', 'note'];
      _rejectUnknown(body, allowed);
      item.addAll(body);
    } else if (method == 'DELETE') {
      item['deleted_at'] = '2026-07-10T00:00:00Z';
    }
    return _object(item);
  }

  _MockResult? _healthRoute(
    String method,
    String path,
    Map<String, String> query,
    Map<String, dynamic> body,
  ) {
    if (!path.startsWith('/health-assessments')) return null;
    _requireStaff();
    if (path == '/health-assessments/by-class-date' && method == 'GET') {
      final classId = int.tryParse(query['class_id'] ?? '');
      final date = query['assessment_date'];
      if (classId == null || date == null) {
        throw const _MockApiFailure(400, 'Thiếu lớp hoặc ngày đánh giá');
      }
      return _list(
        _scopeHealth(healthAssessments)
            .where(
              (item) =>
                  item['class_id'] == classId &&
                  '${item['assessment_date']}'.startsWith(date),
            )
            .toList(),
      );
    }
    if (path == '/health-assessments/history' && method == 'GET') {
      final studentId = int.tryParse(query['student_id'] ?? '');
      if (studentId == null) throw const _MockApiFailure(400, 'Thiếu học sinh');
      final records = _scopeHealth(
        healthAssessments,
      ).where((item) => item['student_id'] == studentId).toList();
      return _object({
        'student': _studentSummary(_find(students, 'student_id', studentId)),
        'records': records,
      });
    }
    if (path == '/health-assessments/who-curves' && method == 'GET') {
      if (!['height', 'weight', 'bmi'].contains(query['indicator']) ||
          !['Nam', 'Nữ'].contains(query['gender'])) {
        throw const _MockApiFailure(400, 'Chỉ số hoặc giới tính không hợp lệ');
      }
      return _list([
        {
          'month': 24,
          'sd3neg': 78,
          'sd2neg': 81,
          'median': 86,
          'sd2': 91,
          'sd3': 94,
        },
        {
          'month': 36,
          'sd3neg': 85,
          'sd2neg': 88,
          'median': 94,
          'sd2': 100,
          'sd3': 103,
        },
        {
          'month': 48,
          'sd3neg': 90,
          'sd2neg': 94,
          'median': 101,
          'sd2': 108,
          'sd3': 111,
        },
      ]);
    }
    if (path == '/health-assessments/bulk' && method == 'POST') {
      _requireFields(body, [
        'school_year_id',
        'class_id',
        'assessment_date',
        'rows',
      ]);
      final rows = body['rows'] as List? ?? const [];
      for (final raw in rows.whereType<Map>()) {
        final row = Map<String, dynamic>.from(raw);
        final existing = healthAssessments.indexWhere(
          (item) =>
              item['student_id'] == _asInt(row['student_id']) &&
              item['assessment_date'] == body['assessment_date'],
        );
        final item = _health(
          existing < 0
              ? _nextId(healthAssessments, 'assessment_id')
              : (healthAssessments[existing]['assessment_id'] as num).toInt(),
          _asInt(row['student_id'])!,
          _asInt(body['class_id'])!,
          _asInt(body['school_year_id'])!,
          '${body['assessment_date']}',
          (row['height_cm'] as num?)?.toDouble() ?? 0,
          (row['weight_kg'] as num?)?.toDouble() ?? 0,
        )..['note'] = row['note'] ?? '';
        if (existing < 0) {
          healthAssessments.add(item);
        } else {
          healthAssessments[existing] = item;
        }
      }
      return _object({
        'created': rows.length,
        'updated': 0,
        'skipped': 0,
        'errors': [],
      });
    }
    if (path == '/health-assessments' && method == 'GET') {
      var items = _scopeHealth(healthAssessments);
      final yearId = int.tryParse(query['school_year_id'] ?? '');
      if (yearId != null) {
        items = items
            .where((item) => item['school_year_id'] == yearId)
            .toList();
      }
      if (query['latest'] == 'true') {
        final latest = <int, Map<String, dynamic>>{};
        for (final item in items) {
          final id = (item['student_id'] as num).toInt();
          if (latest[id] == null ||
              '${item['assessment_date']}'.compareTo(
                    '${latest[id]!['assessment_date']}',
                  ) >
                  0) {
            latest[id] = item;
          }
        }
        items = latest.values.toList();
      }
      return _paged(items, query);
    }
    final id = _pathId(path, '/health-assessments/');
    if (id != null) {
      final item = _find(healthAssessments, 'assessment_id', id);
      if (method == 'GET') return _object(item);
      if (method == 'PATCH') item.addAll(body);
      if (method == 'DELETE') healthAssessments.remove(item);
      return _object(item);
    }
    if (path == '/health-assessments' && method == 'POST') {
      _requireFields(body, [
        'student_id',
        'school_year_id',
        'assessment_date',
        'height_cm',
        'weight_kg',
      ]);
      final student = _find(
        students,
        'student_id',
        _asInt(body['student_id'])!,
      );
      final item = _health(
        _nextId(healthAssessments, 'assessment_id'),
        _asInt(body['student_id'])!,
        _studentClass(student),
        _asInt(body['school_year_id'])!,
        '${body['assessment_date']}',
        (body['height_cm'] as num).toDouble(),
        (body['weight_kg'] as num).toDouble(),
      );
      healthAssessments.add(item);
      return _object(item);
    }
    return null;
  }

  _MockResult? _nutritionRoute(
    String method,
    String path,
    Map<String, String> query,
    Map<String, dynamic> body,
  ) {
    if (!path.startsWith('/nutrition-assessments')) return null;
    _requireStaff();
    if ((path.endsWith('/grid') || path.endsWith('/grid-all')) &&
        method == 'GET') {
      final yearId = int.tryParse(query['school_year_id'] ?? '');
      final classId = int.tryParse(query['class_id'] ?? '');
      final period = query['period'];
      if (yearId == null ||
          period == null ||
          (path.endsWith('/grid') && classId == null)) {
        throw const _MockApiFailure(400, 'Thiếu bộ lọc lưới dinh dưỡng');
      }
      var roster = students
          .where((item) => _studentYear(item) == yearId)
          .toList();
      if (classId != null) {
        roster = roster
            .where((item) => _studentClass(item) == classId)
            .toList();
      }
      if (_role == 'TEACHER') {
        final allowed = classes
            .where(_isAssignedClass)
            .map((item) => item['class_id'])
            .toSet();
        roster = roster
            .where((item) => allowed.contains(_studentClass(item)))
            .toList();
      }
      final rows = roster.map((student) {
        final assessment = nutritionAssessments.firstWhere(
          (item) =>
              item['student_id'] == student['student_id'] &&
              item['period'] == period,
          orElse: () => <String, dynamic>{},
        );
        return {
          'student_id': student['student_id'],
          'student_name': student['full_name'],
          'student_id_card_number': student['student_id_card_number'],
          'class_name': _className(_studentClass(student)),
          ...assessment,
        };
      }).toList();
      return _list(rows);
    }
    if (path.endsWith('/bulk') && method == 'POST') {
      _requireFields(body, ['class_id', 'school_year_id', 'period', 'rows']);
      final rows = body['rows'] as List? ?? const [];
      for (final raw in rows.whereType<Map>()) {
        final row = Map<String, dynamic>.from(raw);
        final existing = nutritionAssessments.indexWhere(
          (item) =>
              item['student_id'] == _asInt(row['student_id']) &&
              item['period'] == body['period'],
        );
        final item = _nutrition(
          existing < 0
              ? _nextId(nutritionAssessments, 'nutrition_id')
              : (nutritionAssessments[existing]['nutrition_id'] as num).toInt(),
          _asInt(row['student_id'])!,
          _asInt(body['class_id'])!,
          _asInt(body['school_year_id'])!,
          '${body['period']}',
          isObese: row['is_obese'] == true,
        )..addAll(row);
        if (existing < 0) {
          nutritionAssessments.add(item);
        } else {
          nutritionAssessments[existing] = item;
        }
      }
      return _object({'saved': rows.length, 'cleared': 0, 'skipped': 0});
    }
    return null;
  }

  void _requireStaff() {
    if (_role == 'PARENT') {
      throw const _MockApiFailure(403, 'Không có quyền truy cập');
    }
  }

  void _requirePrincipal() {
    if (_role != 'PRINCIPAL') {
      throw const _MockApiFailure(403, 'Chỉ Ban Giám Hiệu được thao tác');
    }
  }

  List<Map<String, dynamic>> _scopeHealth(List<Map<String, dynamic>> source) {
    if (_role != 'TEACHER') return List.from(source);
    final allowed = classes
        .where(_isAssignedClass)
        .map((item) => item['class_id'])
        .toSet();
    return source.where((item) => allowed.contains(item['class_id'])).toList();
  }

  List<Map<String, dynamic>> _scopeSchoolTransfers(
    List<Map<String, dynamic>> source,
  ) {
    if (_role != 'TEACHER') return _active(source);
    return _active(
      source,
    ).where((item) => item['created_by'] == _accountId).toList();
  }

  bool _isAssignedClass(Map<String, dynamic> item) {
    final rows = item['teacher_classes'] as List? ?? const [];
    return rows.whereType<Map>().any((row) {
      final teacher = row['teacher'];
      return teacher is Map && teacher['teacher_id'] == _teacherId;
    });
  }

  Map<String, dynamic> _parentProfile() {
    final student = _find(students, 'student_id', _studentId ?? 401);
    return Map<String, dynamic>.from(student)..['role'] = 'PARENT';
  }

  Map<String, dynamic> _staffProfile(Map<String, dynamic> teacher) {
    final account = teacher['account'] as Map<String, dynamic>;
    return {
      'account_id': account['account_id'],
      'teacher_id': teacher['teacher_id'],
      'full_name': teacher['full_name'],
      'email': teacher['email'],
      'phone': teacher['phone'],
      'gender': teacher['gender'],
      'position': teacher['position'],
      'work_status': teacher['work_status'],
      'role': account['role'],
    };
  }

  Map<String, dynamic> _accountOwner(int accountId) {
    for (final item in [...teachers, ...students]) {
      if (item['account_id'] == accountId) return item;
    }
    throw const _MockApiFailure(404, 'Tài khoản không tồn tại');
  }

  int? _teacherIdForAccount(int accountId) {
    for (final item in teachers) {
      if (item['account_id'] == accountId) {
        return (item['teacher_id'] as num).toInt();
      }
    }
    return null;
  }

  int? _studentIdForAccount(int accountId) {
    for (final item in students) {
      if (item['account_id'] == accountId) {
        return (item['student_id'] as num).toInt();
      }
    }
    return null;
  }

  int _canonicalAccountId(String role, int accountId) {
    if (_teacherIdForAccount(accountId) != null ||
        _studentIdForAccount(accountId) != null) {
      return accountId;
    }
    return switch (role) {
      'PRINCIPAL' => 1001,
      'PARENT' => 1101,
      _ => 1002,
    };
  }

  int _studentClass(Map<String, dynamic> student) {
    final enrollments = student['enrollments'] as List;
    return (enrollments.first['class_id'] as num).toInt();
  }

  int _studentYear(Map<String, dynamic> student) {
    final enrollments = student['enrollments'] as List;
    return (enrollments.first['school_year_id'] as num).toInt();
  }

  String _className(int classId) =>
      '${_find(classes, 'class_id', classId)['class_name']}';

  Map<String, dynamic> _find(
    List<Map<String, dynamic>> source,
    String key,
    int id,
  ) {
    return source.firstWhere(
      (item) => item[key] == id,
      orElse: () => throw const _MockApiFailure(404, 'Không tìm thấy dữ liệu'),
    );
  }

  int? _pathId(String path, String prefix) {
    if (!path.startsWith(prefix)) return null;
    final raw = path.substring(prefix.length).split('/').first;
    return int.tryParse(raw);
  }

  int? _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value');

  int _nextId(List<Map<String, dynamic>> source, String key) {
    if (source.isEmpty) return 1;
    return source
            .map((item) => (item[key] as num).toInt())
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  List<Map<String, dynamic>> _active(List<Map<String, dynamic>> source) {
    return source.where((item) => item['deleted_at'] == null).toList();
  }

  void _requireFields(Map<String, dynamic> body, List<String> fields) {
    final missing = fields
        .where((field) => body[field] == null || '${body[field]}'.isEmpty)
        .toList();
    if (missing.isNotEmpty) {
      throw _MockApiFailure(400, 'Thiếu dữ liệu bắt buộc', missing);
    }
  }

  void _rejectUnknown(Map<String, dynamic> body, List<String> allowed) {
    final unknown = body.keys.where((key) => !allowed.contains(key)).toList();
    if (unknown.isNotEmpty) {
      throw _MockApiFailure(400, 'Dữ liệu không hợp lệ', unknown);
    }
  }

  _MockResult _list(List<dynamic> items) =>
      _MockResult(200, {'success': true, 'data': items});

  _MockResult _paged(
    List<Map<String, dynamic>> items,
    Map<String, String> query,
  ) {
    final search = (query['search'] ?? '').toLowerCase();
    var filtered = items;
    if (search.isNotEmpty) {
      filtered = items
          .where((item) => jsonEncode(item).toLowerCase().contains(search))
          .toList();
    }
    final page = int.tryParse(query['page'] ?? '') ?? 1;
    final pageSize = int.tryParse(query['pageSize'] ?? '') ?? 20;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length).toInt();
    final data = start >= filtered.length
        ? <Map<String, dynamic>>[]
        : filtered.sublist(start, end);
    return _MockResult(200, {
      'success': true,
      'data': data,
      'meta': {
        'page': page,
        'pageSize': pageSize,
        'total': filtered.length,
        'totalPages': filtered.isEmpty
            ? 0
            : (filtered.length / pageSize).ceil(),
      },
    });
  }

  _MockResult _object(
    Map<String, dynamic> item, {
    Map<String, List<String>>? headers,
  }) {
    return _MockResult(200, {'success': true, 'data': item}, headers: headers);
  }

  ResponseBody _response(
    int statusCode,
    Map<String, dynamic> body, {
    Map<String, List<String>>? headers,
  }) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...?headers,
      },
    );
  }

  String _normalizePath(String value) {
    if (value == '/api') return '/';
    return value.startsWith('/api/') ? value.substring(4) : value;
  }

  Map<String, List<String>> get _sessionHeaders => {
    'set-cookie': [
      'sorak_access=mock-access; Path=/; HttpOnly',
      'sorak_refresh=mock-refresh; Path=/api/auth; HttpOnly',
    ],
  };

  static Map<String, dynamic> _teacher({
    required int id,
    required String name,
    required String email,
    required String position,
    int? accountId,
    String? role,
  }) => {
    'teacher_id': id,
    'account_id': accountId,
    'full_name': name,
    'email': email,
    'position': position,
    'phone': '0900000$id',
    'gender': 'Nữ',
    'work_status': 'Đang làm việc',
    'deleted_at': null,
    'account': accountId == null
        ? null
        : {'account_id': accountId, 'role': role, 'is_active': true},
  };

  Map<String, dynamic> _schoolClass({
    required int id,
    required int yearId,
    required String name,
    required String ageGroup,
    required String room,
    required int teacherId,
  }) {
    final teacher = teachers.firstWhere(
      (item) => item['teacher_id'] == teacherId,
    );
    return {
      'class_id': id,
      'school_year_id': yearId,
      'class_name': name,
      'age_group': ageGroup,
      'room': room,
      'deleted_at': null,
      'teacher_classes': [
        {'teacher': _teacherSummary(teacher)},
      ],
    };
  }

  static Map<String, dynamic> _teacherSummary(Map<String, dynamic> teacher) => {
    'teacher_id': teacher['teacher_id'],
    'account_id': teacher['account_id'],
    'full_name': teacher['full_name'],
    'position': teacher['position'],
  };

  Map<String, dynamic> _student({
    required int id,
    required int accountId,
    required String card,
    required String name,
    required String gender,
    required String dateOfBirth,
    required int classId,
    required int yearId,
  }) => {
    'student_id': id,
    'account_id': accountId,
    'student_id_card_number': card,
    'full_name': name,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'student_status': 'Đang học',
    'contact_phone': '0910000$id',
    'grade_level': _find(classes, 'class_id', classId)['age_group'],
    'deleted_at': null,
    'account': {'account_id': accountId, 'role': 'PARENT', 'is_active': true},
    'parents': [
      {
        'parent_id': 2000 + id,
        'full_name': 'Phụ huynh $name',
        'relationship': 'Mẹ',
        'phone': '0980000$id',
      },
    ],
    'enrollments': [
      {
        'class_id': classId,
        'school_year_id': yearId,
        'left_date': null,
        'class': {
          ..._find(classes, 'class_id', classId),
          'school_year': {
            'name': _find(years, 'school_year_id', yearId)['name'],
          },
        },
      },
    ],
  };

  Map<String, dynamic> _studentSummary(Map<String, dynamic> student) => {
    'student_id': student['student_id'],
    'full_name': student['full_name'],
    'student_id_card_number': student['student_id_card_number'],
    'student_status': student['student_status'],
  };

  Map<String, dynamic> _classTransfer(
    int id,
    int studentId,
    int fromId,
    int toId,
    String status,
  ) => {
    'request_id': id,
    'student_id': studentId,
    'school_year_id': _find(classes, 'class_id', fromId)['school_year_id'],
    'from_class_id': fromId,
    'to_class_id': toId,
    'reason': 'Phù hợp nhu cầu học tập',
    'effective_date': '2026-04-15',
    'status': status,
    'requested_by': 1001,
    'student': _studentSummary(_find(students, 'student_id', studentId)),
    'from_class': {'class_id': fromId, 'class_name': _className(fromId)},
    'to_class': {'class_id': toId, 'class_name': _className(toId)},
    'requester': _requesterByAccountId(1001),
  };

  Map<String, dynamic> _requesterByAccountId(int accountId) {
    String fullName = '';
    try {
      fullName = '${_find(teachers, 'account_id', accountId)['full_name']}';
    } catch (_) {
      fullName = '';
    }
    return {
      'account_id': accountId,
      'teacher': {'full_name': fullName},
    };
  }

  Map<String, dynamic> _schoolTransfer({
    required int id,
    required int studentId,
    required int classId,
    required int yearId,
    required String status,
    String? previousSchool,
    String? destinationSchool,
  }) => {
    'transfer_id': id,
    'student_id': studentId,
    'class_id': classId,
    'school_year_id': yearId,
    'status': status,
    'previous_school': ?previousSchool,
    'destination_school': ?destinationSchool,
    'transfer_date': '2026-03-15',
    'reason': 'Chuyển nơi cư trú',
    'note': '',
    'created_by': 1001,
    'deleted_at': null,
    'student': _studentSummary(_find(students, 'student_id', studentId)),
    'class': {'class_id': classId, 'class_name': _className(classId)},
    'school_year': {
      'school_year_id': yearId,
      'name': _find(years, 'school_year_id', yearId)['name'],
    },
  };

  Map<String, dynamic> _health(
    int id,
    int studentId,
    int classId,
    int yearId,
    String date,
    double height,
    double weight,
  ) {
    final bmi = height <= 0 ? 0 : weight / ((height / 100) * (height / 100));
    return {
      'assessment_id': id,
      'student_id': studentId,
      'class_id': classId,
      'school_year_id': yearId,
      'assessment_date': date,
      'height_cm': height,
      'weight_kg': weight,
      'bmi': double.parse(bmi.toStringAsFixed(2)),
      'bmi_status': 'Bình thường',
      'height_status': 'Bình thường',
      'weight_status': 'Bình thường',
      'note': '',
      'student': _studentSummary(_find(students, 'student_id', studentId)),
      'class': {'class_id': classId, 'class_name': _className(classId)},
      'school_year': {
        'school_year_id': yearId,
        'name': _find(years, 'school_year_id', yearId)['name'],
      },
    };
  }

  Map<String, dynamic> _nutrition(
    int id,
    int studentId,
    int classId,
    int yearId,
    String period, {
    bool isObese = false,
  }) => {
    'nutrition_id': id,
    'student_id': studentId,
    'class_id': classId,
    'school_year_id': yearId,
    'period': period,
    'weight_channel': '',
    'is_stunting': false,
    'is_severe_stunting': false,
    'is_obese': isObese,
    'latest_bmi': 15.8,
    'latest_bmi_status': 'Bình thường',
    'note': '',
  };
}

class _MockResult {
  const _MockResult(this.statusCode, this.body, {this.headers});
  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, List<String>>? headers;
}

class MockApiRequest {
  const MockApiRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, dynamic> body;
}

class _MockApiFailure implements Exception {
  const _MockApiFailure(
    this.statusCode,
    this.message, [
    this.errors = const [],
  ]);
  final int statusCode;
  final String message;
  final List<dynamic> errors;
}
