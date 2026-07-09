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
}
