import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_config.dart';

class ApiClient {
  ApiClient({CookieJar? cookieJar})
    : cookieJar = cookieJar ?? CookieJar(),
      dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(CookieManager(this.cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(onError: _handleUnauthorizedResponse),
    );
  }

  static const _retryKey = 'sorak_refresh_retry';
  static const _noRefreshPaths = {
    '/auth/login',
    '/auth/parent-login',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  factory ApiClient.memory() {
    return ApiClient(cookieJar: CookieJar());
  }

  static Future<ApiClient> persistent() async {
    final directory = await getApplicationSupportDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/sorak_cookies'),
    );
    return ApiClient(cookieJar: cookieJar);
  }

  final CookieJar cookieJar;
  final Dio dio;
  Future<void> Function()? onSessionExpired;

  Future<void>? _refreshing;
  Future<void>? _sessionExpiry;

  Future<void> clearSessionCookies() {
    return cookieJar.deleteAll();
  }

  void markSessionActive() {
    _sessionExpiry = null;
  }

  Future<void> _handleUnauthorizedResponse(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final shouldRefresh =
        error.response?.statusCode == 401 &&
        !request.extra.containsKey(_retryKey) &&
        !_isNoRefreshPath(request.path);

    if (!shouldRefresh) {
      handler.next(error);
      return;
    }

    request.extra[_retryKey] = true;

    try {
      _refreshing ??= _refreshAccessToken().whenComplete(() {
        _refreshing = null;
      });
      await _refreshing;

      final response = await _retryRequest(request);
      handler.resolve(response);
    } catch (_) {
      await _expireSession();
      handler.next(error);
    }
  }

  bool _isNoRefreshPath(String path) {
    return _noRefreshPaths.any(path.contains);
  }

  Future<void> _refreshAccessToken() async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    refreshDio.interceptors.add(CookieManager(cookieJar));
    refreshDio.httpClientAdapter = dio.httpClientAdapter;
    await refreshDio.post('/auth/refresh');
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions request) {
    final headers = Map<String, dynamic>.from(request.headers)
      ..remove('cookie')
      ..remove('Cookie')
      ..remove('Authorization');

    return dio.request<dynamic>(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      cancelToken: request.cancelToken,
      onReceiveProgress: request.onReceiveProgress,
      onSendProgress: request.onSendProgress,
      options: Options(
        method: request.method,
        headers: headers,
        extra: request.extra,
        contentType: request.contentType,
        responseType: request.responseType,
        followRedirects: request.followRedirects,
        receiveDataWhenStatusError: request.receiveDataWhenStatusError,
        sendTimeout: request.sendTimeout,
        receiveTimeout: request.receiveTimeout,
        validateStatus: request.validateStatus,
      ),
    );
  }

  Future<void> _expireSession() {
    return _sessionExpiry ??= _clearExpiredSession();
  }

  Future<void> _clearExpiredSession() async {
    await clearSessionCookies();
    await onSessionExpired?.call();
  }
}
