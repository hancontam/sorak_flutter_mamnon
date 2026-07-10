import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';
import 'package:sorak_flutter_mamnon/modules/class_transfers/repositories/class_transfer_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/growth_who_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/health_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/health/repositories/nutrition_assessment_repository.dart';
import 'package:sorak_flutter_mamnon/modules/students/repositories/student_repository.dart';

void main() {
  group('Health, nutrition and growth data journeys', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient.memory();
      client.configureMockSession(role: 'PRINCIPAL', accountId: 1001);
    });

    test('health roster bulk save is visible after reload', () async {
      final repository = HealthAssessmentRepository(apiClient: client);
      expect(
        await repository.getByClassDate(
          classId: 301,
          assessmentDate: '2026-06-10',
        ),
        isEmpty,
      );

      final result = await repository.bulkSave(
        schoolYearId: 101,
        classId: 301,
        assessmentDate: '2026-06-10',
        rows: [
          {
            'student_id': 401,
            'height_cm': '103.5',
            'weight_kg': '16.8',
            'note': 'MOBILE_TEST_Sức khỏe ổn định',
          },
        ],
      );
      expect(result['created'], 1);

      final reloaded = await repository.getByClassDate(
        classId: 301,
        assessmentDate: '2026-06-10',
      );
      expect(reloaded.single.studentId, 401);
      expect(reloaded.single.heightCm, 103.5);
      expect(reloaded.single.weightKg, 16.8);
      expect(reloaded.single.note, 'MOBILE_TEST_Sức khỏe ổn định');
    });

    test(
      'nutrition grid exposes missing row then persists bulk values',
      () async {
        final repository = NutritionAssessmentRepository(apiClient: client);
        final emptyPeriod = await repository.getGrid(
          classId: 301,
          schoolYearId: 101,
          period: 'giua_nam',
        );
        expect(emptyPeriod.single.studentId, 401);
        expect(emptyPeriod.single.weightChannel, isEmpty);

        final result = await repository.bulkSave(
          classId: 301,
          schoolYearId: 101,
          period: 'giua_nam',
          rows: [
            {
              'student_id': 401,
              'weight_channel': 'Bình thường',
              'is_stunting': false,
              'is_severe_stunting': false,
              'is_obese': true,
              'note': 'MOBILE_TEST_Theo dõi thêm',
            },
          ],
        );
        expect(result['saved'], 1);

        final reloaded = await repository.getGrid(
          classId: 301,
          schoolYearId: 101,
          period: 'giua_nam',
        );
        expect(reloaded.single.isObese, isTrue);
        expect(reloaded.single.weightChannel, 'Bình thường');
        expect(reloaded.single.note, 'MOBILE_TEST_Theo dõi thêm');
      },
    );

    test('growth history and WHO curves match selected student', () async {
      final repository = GrowthWhoRepository(apiClient: client);
      final latest = await repository.getLatest(
        role: 'PRINCIPAL',
        schoolYearId: 101,
      );
      final history = await repository.getHistory(
        studentId: 401,
        role: 'PRINCIPAL',
        schoolYearId: 101,
      );
      final curves = await repository.getWhoCurves(
        indicator: 'bmi',
        gender: 'Nam',
      );

      expect(latest.any((item) => item.studentId == 401), isTrue);
      expect(history.map((item) => item.studentId).toSet(), {401});
      expect(history, hasLength(2));
      expect(curves, hasLength(3));
      expect(curves.first.month, 24);
    });

    test(
      'approved class transfer changes student enrollment and revert restores it',
      () async {
        final transfers = ClassTransferRepository(apiClient: client);
        final students = StudentRepository(apiClient: client);
        final request = await transfers.create({
          'student_id': 401,
          'to_class_id': 302,
          'reason': 'MOBILE_TEST_Chuyển lớp',
          'effective_date': '2026-05-20',
        });

        await transfers.updateStatus(request.id, 'approve');
        expect((await students.getById(401))!.classId, 302);

        await transfers.updateStatus(request.id, 'revert');
        expect((await students.getById(401))!.classId, 301);
      },
    );
  });
}
