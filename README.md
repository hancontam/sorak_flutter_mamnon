# Sorak Mam Non Flutter

[![Flutter CI](https://github.com/hancontam/sorak_flutter_mamnon/actions/workflows/flutter_ci.yml/badge.svg?branch=master)](https://github.com/hancontam/sorak_flutter_mamnon/actions/workflows/flutter_ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)](https://flutter.dev)
[![PRM393](https://img.shields.io/badge/FPT-PRM393-1a2845)](https://github.com/hancontam/sorak_flutter_mamnon)

Ứng dụng mobile cho hệ thống theo dõi sức khỏe và phát triển của trẻ mầm non. Dự án được xây dựng cho môn PRM393, ưu tiên code đơn giản, dễ đọc và dễ mở rộng cho team newbie.

## Tính năng

- Đăng nhập cán bộ và phụ huynh bằng session cookie.
- Dashboard theo vai trò Hiệu trưởng, Giáo viên và Phụ huynh.
- Quản lý năm học, lớp học, giáo viên, học sinh và tài khoản.
- Chuyển lớp, chuyển trường đi và chuyển trường đến.
- Đánh giá sức khỏe, dinh dưỡng và tăng trưởng WHO.
- Chọn năm học dùng chung toàn app.
- Delete trên UI tuân theo soft archive của backend.

## Công nghệ

- Flutter stable và Material 3.
- Provider + ChangeNotifier quản lý state.
- Dio, `cookie_jar` và `dio_cookie_manager` gọi API/session.
- SharedPreferences qua `LocalStorage` lưu metadata và năm học đã chọn.
- `json_serializable` + `build_runner` cho model API.
- Google Fonts Poppins, Lottie cho loading/empty/success state.

## Cài đặt

### Yêu cầu

```text
Flutter stable
Dart SDK theo Flutter
Android Studio hoặc thiết bị Android/emulator
```

### Chạy local với mock API

```powershell
git clone https://github.com/hancontam/sorak_flutter_mamnon.git
cd sorak_flutter_mamnon
flutter pub get
flutter run
```

Mock API là mặc định, phù hợp để làm UI và chạy functional test không phụ thuộc server.

### Chạy với live API

```powershell
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

Không đưa mật khẩu, token hoặc cookie vào source code, README hay commit.

## Lệnh thường dùng

```powershell
# Sinh lại file .g.dart sau khi sửa model json_serializable
dart run build_runner build

# Kiểm tra code và test UI/mock API
flutter analyze
flutter test

# Kiểm tra contract của live branch bằng adapter, không gọi server thật
flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart

# Build APK debug local
flutter build apk --debug
```

## Cấu trúc project

```text
lib/
  app.dart
  main.dart
  core/
    constants/       # AppConfig, API endpoint, storage key
    network/         # ApiClient, ApiResponse, ApiPage
    storage/         # SharedPreferences wrapper
    theme/           # Material 3 theme, color, spacing
    widgets/         # Widget dùng chung, AppShell
  modules/
    [module_name]/
      models/        # json_serializable model
      providers/     # ChangeNotifier
      repositories/  # Mock/live Dio API
      screens/       # List, form, detail
      widgets/       # Widget riêng của module
test/
  functional/        # Functional and API contract tests
```

Luồng code cho module mới:

```text
model -> dart run build_runner build -> repository -> provider -> screen -> test
```

## Design system

| Thành phần | Quy ước |
| --- | --- |
| UI | Material 3, Poppins |
| Primary | `#1a2845` |
| Accent | `#f5a623` |
| Success / Error | `#4ade80` / `#ef4444` |
| Spacing | 8, 12, 16 px |
| Card | Flat, radius 16 px |
| State | Provider + ChangeNotifier |

Mobile ưu tiên `ListTile` hoặc `Card + ListTile`. Không dùng Excel import/export trong app. Các field có giá trị cố định nên dùng dropdown, không nhập text tự do.

## Tải APK preview từ GitHub Actions

1. Push code lên nhánh `master` hoặc tạo Pull Request vào `master`.
2. Mở tab **Actions** trên GitHub và chọn workflow **Flutter CI**.
3. Mở lần chạy có dấu tick xanh.
4. Ở cuối trang, tải artifact **sorak-mam-non-debug-apk**.
5. Giải nén artifact để lấy file `app-debug.apk` và cài lên thiết bị Android test.

APK CI chỉ dùng để preview/test nội bộ. Không dùng APK debug để phát hành production.

## Contribute

1. Tạo branch từ `master`: `feature/ten-chuc-nang` hoặc `fix/ten-loi`.
2. Giữ module theo cấu trúc `models -> repositories -> providers -> screens`.
3. Nếu sửa model API, chạy `dart run build_runner build`.
4. Trước khi tạo Pull Request, chạy:

   ```powershell
   flutter analyze
   flutter test
   ```

5. Pull Request cần mô tả ngắn: màn hình/flow thay đổi, cách test và ảnh chụp nếu có UI.

## Lưu ý API

- Luôn đối chiếu backend route + validator và web flow trước khi thêm endpoint live.
- Năm học là state global, không hard-code `school_year_id`.
- Không log password, JWT, Cookie hay Set-Cookie.
- Archive là soft delete theo contract backend.
