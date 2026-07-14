import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/role_guard.dart';
import 'modules/academic_years/providers/academic_year_provider.dart';
import 'modules/academic_years/providers/active_academic_year_provider.dart';
import 'modules/academic_years/repositories/academic_year_repository.dart';
import 'modules/academic_years/screens/academic_year_list_screen.dart';
import 'modules/accounts/providers/account_provider.dart';
import 'modules/accounts/repositories/account_repository.dart';
import 'modules/accounts/screens/account_list_screen.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/repositories/auth_repository.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/class_transfers/providers/class_transfer_provider.dart';
import 'modules/class_transfers/repositories/class_transfer_repository.dart';
import 'modules/class_transfers/screens/class_transfer_list_screen.dart';
import 'modules/classes/providers/class_provider.dart';
import 'modules/classes/repositories/class_repository.dart';
import 'modules/classes/screens/class_list_screen.dart';
import 'modules/form_options/providers/form_options_provider.dart';
import 'modules/form_options/repositories/form_options_repository.dart';
import 'modules/health/providers/growth_who_provider.dart';
import 'modules/health/screens/health_screen.dart';
import 'modules/health/providers/health_assessment_provider.dart';
import 'modules/health/providers/nutrition_assessment_provider.dart';
import 'modules/health/repositories/growth_who_repository.dart';
import 'modules/health/repositories/health_assessment_repository.dart';
import 'modules/health/repositories/nutrition_assessment_repository.dart';
import 'modules/health/screens/growth_who_screen.dart';
import 'modules/health/screens/health_assessment_list_screen.dart';
import 'modules/health/screens/nutrition_assessment_list_screen.dart';
import 'modules/incoming_transfers/providers/incoming_transfer_provider.dart';
import 'modules/incoming_transfers/repositories/incoming_transfer_repository.dart';
import 'modules/incoming_transfers/screens/incoming_transfer_list_screen.dart';
import 'modules/outgoing_transfers/providers/outgoing_transfer_provider.dart';
import 'modules/outgoing_transfers/repositories/outgoing_transfer_repository.dart';
import 'modules/outgoing_transfers/screens/outgoing_transfer_list_screen.dart';
import 'modules/parent/screens/parent_portal_screen.dart';
import 'modules/parent/providers/parent_health_history_provider.dart';
import 'modules/parent/repositories/parent_health_history_repository.dart';
import 'modules/profile/screens/profile_screen.dart';
import 'modules/profile/screens/settings_screen.dart';
import 'modules/students/providers/student_provider.dart';
import 'modules/students/repositories/student_repository.dart';
import 'modules/students/screens/student_list_screen.dart';
import 'modules/teachers/providers/teacher_provider.dart';
import 'modules/teachers/repositories/teacher_repository.dart';
import 'modules/teachers/screens/teacher_list_screen.dart';
import 'modules/transfers/screens/transfers_screen.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class SorakApp extends StatelessWidget {
  const SorakApp({super.key, required this.localStorage, this.apiClient});

  final LocalStorage localStorage;
  final ApiClient? apiClient;
  static const Set<String> _allRoles = {'PRINCIPAL', 'TEACHER', 'PARENT'};
  static const Set<String> _staffRoles = {'PRINCIPAL', 'TEACHER'};
  static const Set<String> _principalOnly = {'PRINCIPAL'};
  static const Set<String> _parentOnly = {'PARENT'};

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: localStorage),
        Provider<ApiClient>(create: (_) => apiClient ?? ApiClient.memory()),
        ProxyProvider2<ApiClient, LocalStorage, AuthRepository>(
          update: (_, apiClient, localStorage, previous) {
            return AuthRepository(
              apiClient: apiClient,
              localStorage: localStorage,
            );
          },
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final authProvider = AuthProvider(
              authRepository: context.read<AuthRepository>(),
            );
            context.read<ApiClient>().onSessionExpired = () async {
              await authProvider.handleSessionExpired();
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (_) => false,
              );
            };
            authProvider.loadCurrentUser();
            return authProvider;
          },
        ),
        ChangeNotifierProvider<AcademicYearProvider>(
          create: (context) => AcademicYearProvider(
            academicYearRepository: AcademicYearRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<ActiveAcademicYearProvider>(
          create: (context) => ActiveAcademicYearProvider(
            academicYearRepository: AcademicYearRepository(
              apiClient: context.read<ApiClient>(),
            ),
            localStorage: context.read<LocalStorage>(),
          ),
        ),
        ChangeNotifierProvider<ClassProvider>(
          create: (context) => ClassProvider(
            classRepository: ClassRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<TeacherProvider>(
          create: (context) => TeacherProvider(
            teacherRepository: TeacherRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (context) => StudentProvider(
            studentRepository: StudentRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<FormOptionsProvider>(
          create: (context) => FormOptionsProvider(
            formOptionsRepository: FormOptionsRepository(
              academicYearRepository: AcademicYearRepository(
                apiClient: context.read<ApiClient>(),
              ),
              classRepository: ClassRepository(
                apiClient: context.read<ApiClient>(),
              ),
              teacherRepository: TeacherRepository(
                apiClient: context.read<ApiClient>(),
              ),
              studentRepository: StudentRepository(
                apiClient: context.read<ApiClient>(),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(
            accountRepository: AccountRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<ClassTransferProvider>(
          create: (context) => ClassTransferProvider(
            classTransferRepository: ClassTransferRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<OutgoingTransferProvider>(
          create: (context) => OutgoingTransferProvider(
            outgoingTransferRepository: OutgoingTransferRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<IncomingTransferProvider>(
          create: (context) => IncomingTransferProvider(
            incomingTransferRepository: IncomingTransferRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<HealthAssessmentProvider>(
          create: (context) => HealthAssessmentProvider(
            healthAssessmentRepository: HealthAssessmentRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<NutritionAssessmentProvider>(
          create: (context) => NutritionAssessmentProvider(
            nutritionAssessmentRepository: NutritionAssessmentRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<GrowthWhoProvider>(
          create: (context) => GrowthWhoProvider(
            growthWhoRepository: GrowthWhoRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
        ChangeNotifierProvider<ParentHealthHistoryProvider>(
          create: (context) => ParentHealthHistoryProvider(
            repository: ParentHealthHistoryRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Sorak Mam Non',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (authProvider.isLoggedIn) {
              return const AppShell();
            }

            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) =>
              const RoleGuard(allowedRoles: _allRoles, child: AppShell()),
          '/academic-years': (_) => const RoleGuard(
            allowedRoles: _principalOnly,
            child: AcademicYearListScreen(),
          ),
          '/classes': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: ClassListScreen(),
          ),
          '/teachers': (_) => const RoleGuard(
            allowedRoles: _principalOnly,
            child: TeacherListScreen(),
          ),
          '/students': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: StudentListScreen(),
          ),
          '/accounts': (_) => const RoleGuard(
            allowedRoles: _principalOnly,
            child: AccountListScreen(),
          ),
          '/student-accounts': (_) => const RoleGuard(
            allowedRoles: _principalOnly,
            child: AccountListScreen(initialView: AccountView.student),
          ),
          '/staff-accounts': (_) => const RoleGuard(
            allowedRoles: _principalOnly,
            child: AccountListScreen(initialView: AccountView.staff),
          ),
          '/transfers': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: TransfersScreen(),
          ),
          '/health': (_) =>
              const RoleGuard(allowedRoles: _staffRoles, child: HealthScreen()),
          '/health-assessments': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: HealthAssessmentListScreen(),
          ),
          '/nutrition': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: NutritionAssessmentListScreen(),
          ),
          '/growth': (_) => RoleGuard(
            allowedRoles: _allRoles,
            child: Scaffold(
              appBar: AppBar(title: Text('Tăng trưởng WHO')),
              body: const Padding(
                padding: EdgeInsets.all(16),
                child: GrowthWhoScreen(),
              ),
            ),
          ),
          '/parent-portal': (_) => const RoleGuard(
            allowedRoles: _parentOnly,
            child: ParentPortalScreen(),
          ),
          '/profile': (_) =>
              const RoleGuard(allowedRoles: _allRoles, child: ProfileScreen()),
          '/settings': (_) =>
              const RoleGuard(allowedRoles: _allRoles, child: SettingsScreen()),
          '/class-transfers': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: ClassTransferListScreen(),
          ),
          '/outgoing-transfers': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: OutgoingTransferListScreen(),
          ),
          '/incoming-transfers': (_) => const RoleGuard(
            allowedRoles: _staffRoles,
            child: IncomingTransferListScreen(),
          ),
        },
      ),
    );
  }
}
