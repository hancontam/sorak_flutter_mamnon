import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/classes/models/school_class.dart';
import 'package:sorak_flutter_mamnon/modules/classes/providers/class_provider.dart';
import 'package:sorak_flutter_mamnon/modules/classes/repositories/class_repository.dart';

class _DelayedClassRepository extends ClassRepository {
  _DelayedClassRepository({required super.apiClient});

  final requests = <int, Completer<List<SchoolClass>>>{};

  @override
  Future<List<SchoolClass>> getAll({int? schoolYearId}) {
    return (requests[schoolYearId!] ??= Completer<List<SchoolClass>>()).future;
  }
}

void main() {
  test(
    'late response from old academic year cannot overwrite new state',
    () async {
      final repository = _DelayedClassRepository(apiClient: ApiClient.memory());
      final provider = ClassProvider(classRepository: repository);

      final oldRequest = provider.loadForAcademicYear(101);
      final newRequest = provider.loadForAcademicYear(102);

      repository.requests[102]!.complete(const [
        SchoolClass(id: 303, className: 'Lá cũ', schoolYearId: 102),
      ]);
      await newRequest;
      repository.requests[101]!.complete(const [
        SchoolClass(id: 301, className: 'Mầm 1A', schoolYearId: 101),
      ]);
      await oldRequest;

      expect(provider.items.single.schoolYearId, 102);
      expect(provider.items.single.className, 'Lá cũ');
      expect(provider.isLoading, isFalse);
    },
  );
}
