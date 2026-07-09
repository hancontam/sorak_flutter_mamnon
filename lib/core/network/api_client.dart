import 'package:dio/dio.dart';

import '../constants/app_config.dart';
import '../storage/local_storage.dart';

class ApiClient {
  ApiClient({LocalStorage? localStorage})
      : _localStorage = localStorage,
        dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _localStorage?.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final LocalStorage? _localStorage;
  final Dio dio;
}
