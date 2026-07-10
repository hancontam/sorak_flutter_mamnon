import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/core/providers/crud_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/models/academic_year.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/providers/academic_year_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/repositories/academic_year_repository.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/models/account.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/providers/account_provider.dart';
import 'package:sorak_flutter_mamnon/modules/accounts/repositories/account_repository.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/models/student.dart';
import 'package:sorak_flutter_mamnon/modules/students/providers/student_provider.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/models/teacher.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/providers/teacher_provider.dart';
import 'package:sorak_flutter_mamnon/modules/teachers/repositories/teacher_repository.dart';

void main() {
  group('CRUD modules functional test', () {
    test(
      'Academic Year provider supports list detail create update archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = AcademicYearProvider(
          academicYearRepository: AcademicYearRepository(apiClient: apiClient),
        );

        await _expectCrudFlow<AcademicYear>(
          provider: provider,
          createData: {
            'name': '2027-2028',
            'start_date': '2027-08-01',
            'end_date': '2028-05-31',
          },
          updateData: {'name': '2027-2028 Updated'},
          readId: (item) => item.id,
          readTitle: (item) => item.name,
          createdTitle: '2027-2028',
          updatedTitle: '2027-2028 Updated',
        );

        await provider.activateYear(2);
        expect(
          provider.items.firstWhere((item) => item.id == 2).status,
          'active',
        );
      },
    );

    test(
      'Accounts provider supports list detail create update archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = AccountProvider(
          accountRepository: AccountRepository(apiClient: apiClient),
        );

        await _expectCrudFlow<Account>(
          provider: provider,
          createData: {
            'full_name': 'CRUD Test Account',
            'email': 'crud.account@sorak.edu.vn',
            'role': 'STAFF',
            'phone': '0900000101',
            'gender': 'Female',
          },
          updateData: {'full_name': 'CRUD Test Account Updated'},
          readId: (item) => item.id,
          readTitle: (item) => item.fullName,
          createdTitle: 'CRUD Test Account',
          updatedTitle: 'CRUD Test Account Updated',
        );
      },
    );

    test(
      'Classes provider supports list detail create update archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = ClassProvider(
          classRepository: ClassRepository(apiClient: apiClient),
        );

        await _expectCrudFlow<SchoolClass>(
          provider: provider,
          createData: {
            'class_name': 'CRUD Test Class',
            'school_year_id': 1,
            'age_group': '4-5',
            'room': 'C303',
            'teacher_name': 'CRUD Test Teacher',
          },
          updateData: {'class_name': 'CRUD Test Class Updated'},
          readId: (item) => item.id,
          readTitle: (item) => item.className,
          createdTitle: 'CRUD Test Class',
          updatedTitle: 'CRUD Test Class Updated',
        );
      },
    );

    test(
      'Teachers provider supports list detail create update archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = TeacherProvider(
          teacherRepository: TeacherRepository(apiClient: apiClient),
        );

        await _expectCrudFlow<Teacher>(
          provider: provider,
          createData: {
            'full_name': 'CRUD Test Teacher',
            'email': 'crud.teacher@sorak.edu.vn',
            'position': 'Teacher',
            'phone': '0900000102',
            'gender': 'Female',
          },
          updateData: {'full_name': 'CRUD Test Teacher Updated'},
          readId: (item) => item.id,
          readTitle: (item) => item.fullName,
          createdTitle: 'CRUD Test Teacher',
          updatedTitle: 'CRUD Test Teacher Updated',
        );
      },
    );

    test(
      'Students provider supports list detail create update archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = StudentProvider(
          studentRepository: StudentRepository(apiClient: apiClient),
        );

        await _expectCrudFlow<Student>(
          provider: provider,
          createData: {
            'full_name': 'CRUD Test Student',
            'date_of_birth': '2021-02-02',
            'gender': 'Male',
            'class_id': 1,
            'class_name': 'Mam 1A',
            'contact_phone': '0900000103',
          },
          updateData: {'full_name': 'CRUD Test Student Updated'},
          readId: (item) => item.id,
          readTitle: (item) => item.fullName,
          createdTitle: 'CRUD Test Student',
          updatedTitle: 'CRUD Test Student Updated',
        );
      },
    );
  });
}

Future<ApiClient> _createApiClient() async {
  return ApiClient.memory();
}

Future<void> _expectCrudFlow<T>({
  required CrudProvider<T> provider,
  required Map<String, dynamic> createData,
  required Map<String, dynamic> updateData,
  required int Function(T item) readId,
  required String Function(T item) readTitle,
  required String createdTitle,
  required String updatedTitle,
}) async {
  await provider.loadItems();
  expect(provider.errorMessage, isNull);
  expect(provider.items, isNotEmpty);

  final initialCount = provider.items.length;
  final firstId = readId(provider.items.first);

  await provider.loadDetail(firstId);
  expect(provider.errorMessage, isNull);
  expect(provider.selectedItem, isNotNull);
  expect(readId(provider.selectedItem as T), firstId);

  final created = await provider.createItem(createData);
  expect(created, isTrue);
  expect(provider.errorMessage, isNull);
  expect(provider.items, hasLength(initialCount + 1));
  expect(readTitle(provider.items.last), createdTitle);

  final createdId = readId(provider.items.last);
  final updated = await provider.updateItem(createdId, updateData);
  expect(updated, isTrue);
  expect(provider.errorMessage, isNull);

  final updatedItem = provider.items.firstWhere(
    (item) => readId(item) == createdId,
  );
  expect(readTitle(updatedItem), updatedTitle);

  await provider.archiveItem(createdId);
  expect(provider.errorMessage, isNull);
  expect(provider.items, hasLength(initialCount));
  expect(provider.items.where((item) => readId(item) == createdId), isEmpty);
}
