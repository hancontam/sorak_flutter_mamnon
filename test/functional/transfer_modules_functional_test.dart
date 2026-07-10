import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/models/class_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/providers/class_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/models/incoming_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/models/outgoing_transfer.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import 'package:sorak_flutter_mamnon/modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';

void main() {
  group('Transfer modules functional test', () {
    test(
      'Class Transfer supports list detail create and status actions',
      () async {
        final apiClient = await _createApiClient();
        final provider = ClassTransferProvider(
          classTransferRepository: ClassTransferRepository(
            apiClient: apiClient,
          ),
        );

        await provider.loadItems();
        expect(provider.errorMessage, isNull);
        expect(provider.items, isNotEmpty);
        final initialCount = provider.items.length;

        await provider.loadDetail(provider.items.first.id);
        expect(provider.selectedItem, isA<ClassTransfer>());

        final created = await provider.createItem({
          'student_id': 10,
          'student_name': 'CRUD Transfer Student',
          'from_class_name': 'Mam 1A',
          'to_class_id': 2,
          'to_class_name': 'Choi 2B',
          'reason': 'Family request',
          'effective_date': '2026-09-01',
        });
        expect(created, isTrue);
        expect(provider.items, hasLength(initialCount + 1));
        expect(provider.items.last.studentName, 'CRUD Transfer Student');
        expect(provider.items.last.status, 'Pending');

        final createdId = provider.items.last.id;

        await provider.updateStatus(createdId, 'approve');
        expect(_findClassTransfer(provider, createdId).status, 'Approved');

        await provider.updateStatus(createdId, 'reject');
        expect(_findClassTransfer(provider, createdId).status, 'Rejected');

        await provider.archiveItem(createdId);
        expect(_findClassTransfer(provider, createdId).status, 'Cancelled');
        expect(provider.items, hasLength(initialCount + 1));

        await provider.restoreItem(createdId);
        expect(_findClassTransfer(provider, createdId).status, 'Pending');
      },
    );

    test(
      'Outgoing Transfer supports list detail create update cancel archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = OutgoingTransferProvider(
          outgoingTransferRepository: OutgoingTransferRepository(
            apiClient: apiClient,
          ),
        );

        await provider.loadItems();
        expect(provider.errorMessage, isNull);
        expect(provider.items, isNotEmpty);
        final initialCount = provider.items.length;

        await provider.loadDetail(provider.items.first.id);
        expect(provider.selectedItem, isA<OutgoingTransfer>());

        final created = await provider.createItem({
          'student_id': 11,
          'student_name': 'Outgoing Test Student',
          'destination_school': 'New Kindergarten',
          'transfer_date': '2026-10-01',
          'reason': 'Move house',
          'note': 'Parent submitted document',
        });
        expect(created, isTrue);
        expect(provider.items, hasLength(initialCount + 1));
        expect(provider.items.last.destinationSchool, 'New Kindergarten');

        final createdId = provider.items.last.id;
        final updated = await provider.updateItem(createdId, {
          'destination_school': 'Updated Kindergarten',
          'note': 'Updated note',
        });
        expect(updated, isTrue);
        expect(
          _findOutgoingTransfer(provider, createdId).destinationSchool,
          'Updated Kindergarten',
        );

        await provider.cancelTransfer(createdId);
        expect(_findOutgoingTransfer(provider, createdId).status, 'Cancelled');

        await provider.archiveItem(createdId);
        expect(provider.items, hasLength(initialCount));
        expect(provider.items.where((item) => item.id == createdId), isEmpty);
      },
    );

    test(
      'Incoming Transfer supports list detail create update cancel archive',
      () async {
        final apiClient = await _createApiClient();
        final provider = IncomingTransferProvider(
          incomingTransferRepository: IncomingTransferRepository(
            apiClient: apiClient,
          ),
        );

        await provider.loadItems();
        expect(provider.errorMessage, isNull);
        expect(provider.items, isNotEmpty);
        final initialCount = provider.items.length;

        await provider.loadDetail(provider.items.first.id);
        expect(provider.selectedItem, isA<IncomingTransfer>());

        final created = await provider.createItem({
          'student_id': 12,
          'student_name': 'Incoming Test Student',
          'previous_school': 'Old Kindergarten',
          'transfer_date': '2026-09-15',
          'reason': 'Move to Sorak',
          'note': 'Waiting for profile',
        });
        expect(created, isTrue);
        expect(provider.items, hasLength(initialCount + 1));
        expect(provider.items.last.previousSchool, 'Old Kindergarten');

        final createdId = provider.items.last.id;
        final updated = await provider.updateItem(createdId, {
          'previous_school': 'Updated Old Kindergarten',
          'note': 'Profile completed',
        });
        expect(updated, isTrue);
        expect(
          _findIncomingTransfer(provider, createdId).previousSchool,
          'Updated Old Kindergarten',
        );

        await provider.cancelTransfer(createdId);
        expect(_findIncomingTransfer(provider, createdId).status, 'Cancelled');

        await provider.archiveItem(createdId);
        expect(provider.items, hasLength(initialCount));
        expect(provider.items.where((item) => item.id == createdId), isEmpty);
      },
    );
  });
}

Future<ApiClient> _createApiClient() async {
  return ApiClient.memory();
}

ClassTransfer _findClassTransfer(ClassTransferProvider provider, int id) {
  return provider.items.firstWhere((item) => item.id == id);
}

OutgoingTransfer _findOutgoingTransfer(
  OutgoingTransferProvider provider,
  int id,
) {
  return provider.items.firstWhere((item) => item.id == id);
}

IncomingTransfer _findIncomingTransfer(
  IncomingTransferProvider provider,
  int id,
) {
  return provider.items.firstWhere((item) => item.id == id);
}
