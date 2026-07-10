import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorak_flutter_mamnon/core/network/api_client.dart';

void main() {
  group('Cookie session functional test', () {
    test('login cookies are reused by authenticated API requests', () async {
      final apiClient = ApiClient.memory();
      final adapter = _CookieSessionAdapter();
      apiClient.dio.httpClientAdapter = adapter;

      await apiClient.dio.post('/auth/login');
      await apiClient.dio.get('/auth/me');
      await apiClient.dio.get('/students');

      expect(adapter.meCookieHeader, contains('sorak_access=access-token'));
      expect(adapter.meCookieHeader, contains('sorak_refresh=refresh-token'));
      expect(
        adapter.studentsCookieHeader,
        contains('sorak_access=access-token'),
      );
      expect(adapter.studentsCookieHeader, isNot(contains('sorak_refresh=')));
      final refreshCookies = await apiClient.cookieJar.loadForRequest(
        Uri.parse('http://localhost:3000/api/auth/refresh'),
      );
      expect(
        refreshCookies.map((cookie) => cookie.name),
        containsAll(['sorak_access', 'sorak_refresh']),
      );
    });

    test('clearing a session removes all cookies', () async {
      final apiClient = ApiClient.memory();
      final adapter = _CookieSessionAdapter();
      apiClient.dio.httpClientAdapter = adapter;

      await apiClient.dio.post('/auth/login');
      await apiClient.clearSessionCookies();

      final cookies = await apiClient.cookieJar.loadForRequest(
        Uri.parse('http://localhost:3000/api/auth/refresh'),
      );
      expect(cookies, isEmpty);
    });

    test('a 401 refreshes once and retries the original request', () async {
      final apiClient = ApiClient.memory();
      final adapter = _RefreshAdapter();
      apiClient.dio.httpClientAdapter = adapter;

      await apiClient.dio.post('/auth/login');
      final response = await apiClient.dio.get(
        '/students',
        queryParameters: {'page': 2},
      );

      expect(response.statusCode, 200);
      expect(adapter.refreshCalls, 1);
      expect(adapter.requestCount('/students'), 2);
      expect(adapter.lastStudentsQuery, 'page=2');
      expect(adapter.lastStudentsCookie, contains('sorak_access=fresh-access'));
    });

    test('concurrent 401 responses share one refresh request', () async {
      final apiClient = ApiClient.memory();
      final adapter = _RefreshAdapter(
        refreshDelay: const Duration(milliseconds: 20),
      );
      apiClient.dio.httpClientAdapter = adapter;

      await apiClient.dio.post('/auth/login');
      await Future.wait([
        apiClient.dio.get('/students'),
        apiClient.dio.get('/classes'),
      ]);

      expect(adapter.refreshCalls, 1);
      expect(adapter.requestCount('/students'), 2);
      expect(adapter.requestCount('/classes'), 2);
    });

    test(
      'refresh failure clears cookies and reports session expiry once',
      () async {
        final apiClient = ApiClient.memory();
        final adapter = _RefreshAdapter(refreshSucceeds: false);
        apiClient.dio.httpClientAdapter = adapter;
        var sessionExpiryCalls = 0;
        apiClient.onSessionExpired = () async {
          sessionExpiryCalls++;
        };

        await apiClient.dio.post('/auth/login');

        await expectLater(
          apiClient.dio.get('/students'),
          throwsA(isA<DioException>()),
        );

        expect(adapter.refreshCalls, 1);
        expect(sessionExpiryCalls, 1);
        expect(
          await apiClient.cookieJar.loadForRequest(
            Uri.parse('http://localhost:3000/api/auth/refresh'),
          ),
          isEmpty,
        );
      },
    );

    test('a 401 from login does not trigger refresh', () async {
      final apiClient = ApiClient.memory();
      final adapter = _RefreshAdapter(loginReturnsUnauthorized: true);
      apiClient.dio.httpClientAdapter = adapter;

      await expectLater(
        apiClient.dio.post('/auth/login'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.refreshCalls, 0);
    });
  });
}

class _CookieSessionAdapter implements HttpClientAdapter {
  String? meCookieHeader;
  String? studentsCookieHeader;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/login') {
      return ResponseBody.fromString(
        '{"success":true,"data":{"user":{}}}',
        200,
        headers: const {
          'set-cookie': [
            'sorak_access=access-token; Path=/',
            'sorak_refresh=refresh-token; Path=/api/auth',
          ],
        },
      );
    }

    if (options.path == '/auth/me') {
      meCookieHeader = options.headers['cookie'] as String?;
      return ResponseBody.fromString('{"success":true,"data":{}}', 200);
    }

    if (options.path == '/students') {
      studentsCookieHeader = options.headers['cookie'] as String?;
      return ResponseBody.fromString('{"success":true,"data":[]}', 200);
    }

    throw UnsupportedError('Unexpected request: ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

class _RefreshAdapter implements HttpClientAdapter {
  _RefreshAdapter({
    this.refreshSucceeds = true,
    this.loginReturnsUnauthorized = false,
    this.refreshDelay = Duration.zero,
  });

  final bool refreshSucceeds;
  final bool loginReturnsUnauthorized;
  final Duration refreshDelay;
  final Map<String, int> _requestCounts = {};
  int refreshCalls = 0;
  String? lastStudentsQuery;
  String? lastStudentsCookie;

  int requestCount(String path) => _requestCounts[path] ?? 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requestCounts.update(
      options.path,
      (count) => count + 1,
      ifAbsent: () => 1,
    );

    if (options.path == '/auth/login') {
      if (loginReturnsUnauthorized) {
        return ResponseBody.fromString('{"success":false}', 401);
      }
      return _loginResponse();
    }

    if (options.path == '/auth/refresh') {
      refreshCalls++;
      if (refreshDelay > Duration.zero) {
        await Future<void>.delayed(refreshDelay);
      }
      if (!refreshSucceeds) {
        return ResponseBody.fromString('{"success":false}', 401);
      }
      return ResponseBody.fromString(
        '{"success":true,"data":{"message":"Token refreshed"}}',
        200,
        headers: const {
          'set-cookie': ['sorak_access=fresh-access; Path=/'],
        },
      );
    }

    if (options.path == '/students' || options.path == '/classes') {
      final cookie = options.headers['cookie'] as String? ?? '';
      if (options.path == '/students') {
        lastStudentsCookie = cookie;
        lastStudentsQuery = options.uri.query;
      }
      if (!cookie.contains('sorak_access=fresh-access')) {
        return ResponseBody.fromString('{"success":false}', 401);
      }
      return ResponseBody.fromString('{"success":true,"data":[]}', 200);
    }

    throw UnsupportedError('Unexpected request: ${options.path}');
  }

  ResponseBody _loginResponse() {
    return ResponseBody.fromString(
      '{"success":true,"data":{"user":{}}}',
      200,
      headers: const {
        'set-cookie': [
          'sorak_access=expired-access; Path=/',
          'sorak_refresh=refresh-token; Path=/api/auth',
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
