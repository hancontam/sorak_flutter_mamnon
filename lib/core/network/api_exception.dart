import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.traceId,
    this.errors = const [],
  });

  final String message;
  final int? statusCode;
  final String? traceId;
  final List<dynamic> errors;

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final map = Map<String, dynamic>.from(body);
        return ApiException(
          message: '${map['message'] ?? _fallbackMessage(error)}',
          statusCode: error.response?.statusCode,
          traceId: map['traceId']?.toString(),
          errors: map['errors'] is List
              ? List<dynamic>.from(map['errors'] as List)
              : const [],
        );
      }
      return ApiException(
        message: _fallbackMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(
      message: error.toString().replaceFirst('Exception: ', ''),
    );
  }

  static String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Kết nối máy chủ quá thời gian. Vui lòng thử lại.',
      DioExceptionType.connectionError =>
        'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.',
      _ => 'Có lỗi xảy ra khi xử lý yêu cầu.',
    };
  }

  String get displayMessage {
    final id = traceId;
    return id == null || id.isEmpty ? message : '$message (Mã: $id)';
  }

  @override
  String toString() => displayMessage;
}

String apiErrorMessage(Object error) => ApiException.from(error).displayMessage;
