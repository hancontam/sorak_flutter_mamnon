import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/repositories/auth_repository.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/home/screens/home_screen.dart';

class SorakApp extends StatelessWidget {
  const SorakApp({
    super.key,
    required this.localStorage,
  });

  final LocalStorage localStorage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: localStorage),
        Provider<ApiClient>(create: (_) => ApiClient()),
        ProxyProvider2<ApiClient, LocalStorage, AuthRepository>(
          update: (_, apiClient, localStorage, previous) {
            return AuthRepository(
              apiClient: apiClient,
              localStorage: localStorage,
            );
          },
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
          )..loadCurrentUser(),
        ),
      ],
      child: MaterialApp(
        title: 'Sorak Mam Non',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (authProvider.isLoggedIn) {
              return const HomeScreen();
            }

            return const LoginScreen();
          },
        ),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
