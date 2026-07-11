class UiLabels {
  const UiLabels._();

  static String role(String? value) {
    switch (_normalize(value)) {
      case 'PRINCIPAL':
        return 'Ban Giám hiệu';
      case 'TEACHER':
        return 'Giáo viên';
      case 'PARENT':
        return 'Phụ huynh';
      case 'STAFF':
        return 'Cán bộ';
      default:
        return _fallback(value);
    }
  }

  static String status(String? value) {
    final normalized = _normalize(value);
    switch (normalized) {
      case 'ACTIVE':
      case 'RECORDED':
        return 'Đang hoạt động';
      case 'INACTIVE':
        return 'Ngừng hoạt động';
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'CANCELLED':
      case 'CANCELED':
        return 'Đã hủy';
      case 'ARCHIVED':
        return 'Đã lưu trữ';
      case 'COMPLETED':
        return 'Hoàn tất';
      case 'ĐANG HỌC':
      case 'DANG HOC':
        return 'Đang học';
      case 'ĐANG LÀM VIỆC':
      case 'DANG LAM VIEC':
        return 'Đang làm việc';
      default:
        return _fallback(value);
    }
  }

  static String gender(String? value) {
    switch (_normalize(value)) {
      case 'MALE':
      case 'NAM':
        return 'Nam';
      case 'FEMALE':
      case 'NỮ':
      case 'NU':
        return 'Nữ';
      case 'OTHER':
      case 'KHÁC':
      case 'KHAC':
        return 'Khác';
      default:
        return _fallback(value);
    }
  }

  static String workStatus(String? value) {
    final text = status(value);
    return text == '-' ? _fallback(value) : text;
  }

  static String accountView(String value) {
    switch (value) {
      case 'student':
        return 'Tài khoản học sinh';
      case 'staff':
        return 'Tài khoản cán bộ';
      default:
        return value;
    }
  }

  static String _normalize(String? value) => (value ?? '').trim().toUpperCase();

  static String _fallback(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
  }
}
