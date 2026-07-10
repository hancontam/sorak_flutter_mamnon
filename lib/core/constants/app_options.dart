class AppOption<T> {
  const AppOption({required this.value, required this.label});

  final T value;
  final String label;
}

class RoleOptions {
  const RoleOptions._();

  static const principal = 'PRINCIPAL';
  static const teacher = 'TEACHER';
  static const parent = 'PARENT';

  static const Map<String, String> labels = {
    principal: 'Ban Giám Hiệu',
    teacher: 'Giáo viên',
    parent: 'Phụ huynh',
  };

  static const staff = [
    AppOption(value: principal, label: 'BGH - Ban Giám Hiệu'),
    AppOption(value: teacher, label: 'GV - Giáo viên'),
  ];

  static const all = [
    AppOption(value: principal, label: 'Ban Giám Hiệu'),
    AppOption(value: teacher, label: 'Giáo viên'),
    AppOption(value: parent, label: 'Phụ huynh'),
  ];

  static String labelOf(String? value) {
    return labels[value?.toUpperCase()] ?? value ?? '';
  }
}

class GenderOptions {
  const GenderOptions._();

  static const male = 'Nam';
  static const female = 'Nữ';
  static const other = 'Khác';

  static const student = [
    AppOption(value: male, label: male),
    AppOption(value: female, label: female),
  ];

  static const teacher = [
    AppOption(value: male, label: male),
    AppOption(value: female, label: female),
    AppOption(value: other, label: other),
  ];
}

class GradeOptions {
  const GradeOptions._();

  static const nursery = 'Nhà trẻ';
  static const mam = 'Mầm';
  static const choi = 'Chồi';
  static const la = 'Lá';

  static const all = [
    AppOption(value: nursery, label: nursery),
    AppOption(value: mam, label: mam),
    AppOption(value: choi, label: choi),
    AppOption(value: la, label: la),
  ];
}

class TeacherWorkStatusOptions {
  const TeacherWorkStatusOptions._();

  static const working = 'Đang làm việc';
  static const transferredIn = 'Chuyển đến';
  static const transferredOut = 'Đã chuyển đi';
  static const reassigned = 'Đã điều động';
  static const waitingRetirement = 'Chờ nghỉ hưu';
  static const retired = 'Đã nghỉ hưu';
  static const seconded = 'Đã biệt phái';
  static const resigned = 'Thôi việc';

  static const all = [
    AppOption(value: working, label: working),
    AppOption(value: transferredIn, label: transferredIn),
    AppOption(value: transferredOut, label: transferredOut),
    AppOption(value: reassigned, label: reassigned),
    AppOption(value: waitingRetirement, label: waitingRetirement),
    AppOption(value: retired, label: retired),
    AppOption(value: seconded, label: seconded),
    AppOption(value: resigned, label: resigned),
  ];
}

class StudentStatusOptions {
  const StudentStatusOptions._();

  static const studying = 'Đang học';
  static const transferredInSemester1 = 'Chuyển đến kỳ 1';
  static const returnedSemester1 = 'Nghỉ học xin học lại kỳ 1';
  static const transferredOutSemester1 = 'Chuyển đi kỳ 1';
  static const stoppedSemester1 = 'Thôi học kỳ 1';
  static const transferredInSemester2 = 'Chuyển đến kỳ 2';
  static const returnedSemester2 = 'Nghỉ học xin học lại kỳ 2';
  static const transferredOutSemester2 = 'Chuyển đi kỳ 2';
  static const stoppedSemester2 = 'Thôi học kỳ 2';
  static const transferredInSummer = 'Chuyển đến trong hè';
  static const transferredOutSummer = 'Chuyển đi trong hè';
  static const stoppedSummer = 'Thôi học trong hè';

  static const all = [
    AppOption(value: studying, label: studying),
    AppOption(value: transferredInSemester1, label: transferredInSemester1),
    AppOption(value: returnedSemester1, label: returnedSemester1),
    AppOption(value: transferredOutSemester1, label: transferredOutSemester1),
    AppOption(value: stoppedSemester1, label: stoppedSemester1),
    AppOption(value: transferredInSemester2, label: transferredInSemester2),
    AppOption(value: returnedSemester2, label: returnedSemester2),
    AppOption(value: transferredOutSemester2, label: transferredOutSemester2),
    AppOption(value: stoppedSemester2, label: stoppedSemester2),
    AppOption(value: transferredInSummer, label: transferredInSummer),
    AppOption(value: transferredOutSummer, label: transferredOutSummer),
    AppOption(value: stoppedSummer, label: stoppedSummer),
  ];
}

class AccountStatusOptions {
  const AccountStatusOptions._();

  static const active = 'true';
  static const inactive = 'false';
  static const unassigned = 'unassigned';

  static const all = [
    AppOption(value: active, label: 'Đang hoạt động'),
    AppOption(value: inactive, label: 'Đã khóa'),
    AppOption(value: unassigned, label: 'Chưa cấp tài khoản'),
  ];
}

class TransferStatusOptions {
  const TransferStatusOptions._();

  static const pending = 'Pending';
  static const approved = 'Approved';
  static const rejected = 'Rejected';
  static const cancelled = 'Cancelled';
  static const expired = 'Expired';
  static const recorded = 'Recorded';

  static const Map<String, String> labels = {
    pending: 'Chờ duyệt',
    approved: 'Đã duyệt',
    rejected: 'Từ chối',
    cancelled: 'Đã hủy',
    expired: 'Quá hạn',
    recorded: 'Đã ghi nhận',
  };

  static const all = [
    AppOption(value: pending, label: 'Chờ duyệt'),
    AppOption(value: approved, label: 'Đã duyệt'),
    AppOption(value: rejected, label: 'Từ chối'),
    AppOption(value: cancelled, label: 'Đã hủy'),
    AppOption(value: expired, label: 'Quá hạn'),
    AppOption(value: recorded, label: 'Đã ghi nhận'),
  ];

  static String labelOf(String? value) {
    return labels[value] ?? value ?? '';
  }
}

class NutritionOptions {
  const NutritionOptions._();

  static const periodMidSemester1 = 'mid_semester_1';
  static const periodEndSemester1 = 'end_semester_1';
  static const periodMidSemester2 = 'mid_semester_2';
  static const periodEndYear = 'end_year';

  static const periods = [
    AppOption(value: periodMidSemester1, label: 'Giữa kỳ 1'),
    AppOption(value: periodEndSemester1, label: 'Cuối kỳ 1'),
    AppOption(value: periodMidSemester2, label: 'Giữa kỳ 2'),
    AppOption(value: periodEndYear, label: 'Cuối năm'),
  ];

  static const normal = 'Bình thường';
  static const malnutrition = 'Suy dinh dưỡng';
  static const overweight = 'Thừa cân';
  static const obese = 'Béo phì';

  static const finalStatuses = [
    AppOption(value: normal, label: normal),
    AppOption(value: malnutrition, label: malnutrition),
    AppOption(value: overweight, label: overweight),
    AppOption(value: obese, label: obese),
  ];

  static const weightNormal = 'none';
  static const underweight = 'Suy dinh dưỡng thể nhẹ cân';
  static const highWeightForAge = 'Cân nặng cao hơn tuổi';

  static const weightChannels = [
    AppOption(value: weightNormal, label: normal),
    AppOption(value: underweight, label: 'Kênh suy DD thể nhẹ cân'),
    AppOption(value: highWeightForAge, label: 'Cân nặng cao hơn tuổi'),
  ];
}
