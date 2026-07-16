import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../modules/academic_years/providers/active_academic_year_provider.dart';
import '../../modules/accounts/providers/account_provider.dart';
import '../../modules/auth/providers/auth_provider.dart';
import '../../modules/class_transfers/providers/class_transfer_provider.dart';
import '../../modules/classes/providers/class_provider.dart';
import '../../modules/form_options/providers/form_options_provider.dart';
import '../../modules/health/providers/health_assessment_provider.dart';
import '../../modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import '../../modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import '../../modules/students/providers/student_provider.dart';

class AcademicDataRefreshService {
  const AcademicDataRefreshService._();

  static Future<void> afterEnrollmentMutation(
    BuildContext context, {
    bool refreshAccounts = false,
  }) async {
    final yearId = context.read<ActiveAcademicYearProvider>().selectedYearId;
    final role =
        context.read<AuthProvider>().currentUser?.role.toUpperCase() ??
        'TEACHER';
    final options = context.read<FormOptionsProvider>();
    final students = context.read<StudentProvider>();
    final classes = context.read<ClassProvider>();
    final classTransfers = context.read<ClassTransferProvider>();
    final incomingTransfers = context.read<IncomingTransferProvider>();
    final outgoingTransfers = context.read<OutgoingTransferProvider>();
    final health = context.read<HealthAssessmentProvider>();
    final accounts = context.read<AccountProvider>();

    await options.refreshOptions();
    if (yearId != null) {
      await options.applyGlobalAcademicYear(yearId);
    }

    final refreshes = <Future<void>>[
      if (yearId == null) ...[
        students.loadItems(),
        classes.loadItems(),
        classTransfers.loadItems(),
        incomingTransfers.loadItems(),
        outgoingTransfers.loadItems(),
        health.loadItems(),
        health.loadLatest(),
      ] else ...[
        students.loadForAcademicYear(yearId),
        classes.loadForAcademicYear(yearId),
        classTransfers.loadForAcademicYear(yearId),
        incomingTransfers.loadForAcademicYear(yearId),
        outgoingTransfers.loadForAcademicYear(yearId),
        health.loadForAcademicYear(yearId),
        health.loadLatest(schoolYearId: yearId),
      ],
      if (refreshAccounts && role == 'PRINCIPAL')
        accounts.loadAccountManagement(),
    ];
    await Future.wait(refreshes);
  }
}
