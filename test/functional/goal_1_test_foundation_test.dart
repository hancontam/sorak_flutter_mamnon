import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/providers/crud_provider.dart';
import 'package:sorak_flutter_mamnon/modules/academic_years/models/academic_year.dart';

import 'helpers/fake_crud_repository.dart';
import 'helpers/test_app.dart';
import 'helpers/test_data.dart';

void main() {
  group('Goal 1 functional test foundation', () {
    testWidgets('can pump Sorak app without saved user', (tester) async {
      await tester.pumpSorakApp();

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('can pump Sorak app with saved user', (tester) async {
      await tester.pumpLoggedInSorakApp();

      expect(find.text('Sorak Mam Non'), findsOneWidget);
      expect(find.text('Welcome, Principal Admin'), findsOneWidget);
      expect(find.text('Academic Years'), findsOneWidget);
    });

    test('fake CRUD repository supports provider flow', () async {
      final repository = FakeCrudRepository<AcademicYear>(
        initialItems: [testAcademicYear],
        readId: (item) => item.id,
        createItem: (data, id) => AcademicYear(
          id: id,
          name: data['name'] as String,
          startDate: data['start_date'] as String,
          endDate: data['end_date'] as String,
        ),
        updateItem: (current, data) => current.copyWith(
          name: data['name'] as String?,
          startDate: data['start_date'] as String?,
          endDate: data['end_date'] as String?,
        ),
        archiveItem: (current, isDeleted) =>
            current.copyWith(isDeleted: isDeleted),
      );
      final provider = CrudProvider<AcademicYear>(repository: repository);

      await provider.loadItems();
      expect(provider.items, hasLength(1));

      final created = await provider.createItem({
        'name': '2026-2027',
        'start_date': '2026-08-01',
        'end_date': '2027-05-31',
      });
      expect(created, isTrue);
      expect(provider.items, hasLength(2));

      final updated = await provider.updateItem(2, {
        'name': '2026-2027 Updated',
      });
      expect(updated, isTrue);
      expect(provider.items.last.name, '2026-2027 Updated');

      await provider.archiveItem(2);
      expect(repository.archiveCallCount, 1);
      expect(repository.lastArchivedId, 2);
      expect(repository.currentItems.last.isDeleted, isTrue);
    });
  });
}
