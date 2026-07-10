import 'api_page.dart';

class ApiResponse {
  const ApiResponse._();

  static List<dynamic> list(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }

  static Map<String, dynamic> object(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return body;
    }
    return <String, dynamic>{};
  }

  static ApiPage<T> page<T>(
    dynamic body,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final root = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final rawItems = root['data'] is List ? root['data'] as List : const [];
    final meta = root['meta'] is Map<String, dynamic>
        ? root['meta'] as Map<String, dynamic>
        : <String, dynamic>{};
    final page = _readInt(meta['page'], fallback: 1);
    final pageSize = _readInt(meta['pageSize'], fallback: rawItems.length);
    final total = _readInt(meta['total'], fallback: rawItems.length);
    final totalPages = _readInt(
      meta['totalPages'],
      fallback: pageSize == 0 ? 0 : (total / pageSize).ceil(),
    );

    return ApiPage(
      items: rawItems
          .whereType<Map>()
          .map((json) => fromJson(Map<String, dynamic>.from(json)))
          .toList(),
      page: page,
      pageSize: pageSize,
      total: total,
      totalPages: totalPages,
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  }
}
