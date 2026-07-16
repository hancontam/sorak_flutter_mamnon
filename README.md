# Sorak Mam Non Flutter

[![Flutter CI](https://github.com/hancontam/sorak_flutter_mamnon/actions/workflows/flutter_ci.yml/badge.svg?branch=master)](https://github.com/hancontam/sorak_flutter_mamnon/actions/workflows/flutter_ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)](https://flutter.dev)
[![PRM393](https://img.shields.io/badge/FPT-PRM393-C96442)](https://github.com/hancontam/sorak_flutter_mamnon)

Ứng dụng mobile **Sorak Mầm non** — quản lý vận hành trường mầm non trên thiết bị Android, xây dựng cho môn **PRM393**.

App hỗ trợ ba vai trò: **Ban Giám Hiệu**, **Giáo viên** và **Phụ huynh**, đồng bộ với backend Sorak qua API `/api`.

## Tính năng

- Đăng nhập cán bộ (email) và phụ huynh (mã thẻ học sinh) bằng session cookie.
- Điều hướng theo vai trò (Bottom navigation + Drawer).
- Năm học dùng chung toàn app (chọn và lưu trạng thái).
- Quản lý năm học, lớp học, cán bộ, học sinh, tài khoản.
- Chuyển lớp, chuyển trường đi / đến (duyệt, hủy, soft archive).
- Đánh giá sức khỏe theo lớp (roster) và xem lịch sử đánh giá.
- Cổng phụ huynh: hồ sơ trẻ + lịch sử khám (chỉ xem).
- Delete trên UI gọi soft archive theo contract backend.

## Công nghệ

| Thành phần | Lựa chọn |
| --- | --- |
| Framework | Flutter stable, Material 3 |
| State | Provider + `ChangeNotifier` |
| HTTP | Dio + `cookie_jar` / `dio_cookie_manager` |
| Local | SharedPreferences (`LocalStorage`) |
| Model | `json_serializable` + `build_runner` |
| UI | Montserrat (`google_fonts`), Lucide icons, Lottie (loading/empty) |

## Chạy project

### Yêu cầu

- Flutter stable
- Android Studio hoặc thiết bị / emulator Android

### Chạy app (mặc định = **Live API**)

```powershell
git clone https://github.com/hancontam/sorak_flutter_mamnon.git
cd sorak_flutter_mamnon
flutter pub get
flutter run
```

`flutter run` và Run/Debug `main.dart` mặc định nối backend live:

```text
http://103.69.191.210:8082/api
```

Không cần thêm `--dart-define` khi demo / nộp bài.

### Mock API (chỉ khi dev offline / test thủ công)

```powershell
flutter run --dart-define=USE_MOCK_API=true
```

`flutter test` luôn dùng mock (cấu hình trong `test/flutter_test_config.dart`).

Không đưa mật khẩu, token hoặc cookie vào source code hay commit.

## Build APK (live)

```powershell
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk` (cũng mặc định live API).

GitHub Actions (nhánh `master`) chạy `flutter analyze`, `flutter test` (mock) và upload artifact APK **live**.

## Cấu trúc

```text
lib/
  app.dart / main.dart
  core/           # network, theme, storage, widgets dùng chung
  modules/        # theo domain: models, repositories, providers, screens
test/
  functional/     # functional test với mock API
docs/             # kiến trúc, API, UI, test, deploy
```

Luồng module: `model` → `repository` → `provider` → `screen`.

## Design (UI final)

- Font: **Montserrat**
- Primary: `#C96442`
- Background / card: `#FAF9F5`
- Radius: **8px**
- Spacing: 8 / 12 / 16

Chi tiết: [docs/UI.md](docs/UI.md).

## Tài liệu

| Tài liệu | Nội dung |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Kiến trúc, module, auth, năm học |
| [docs/API.md](docs/API.md) | Endpoint và envelope response |
| [docs/UI.md](docs/UI.md) | Design system và điều hướng theo role |
| [docs/TESTING.md](docs/TESTING.md) | Functional test mock |
| [docs/DEPLOY.md](docs/DEPLOY.md) | Live run, build APK, CI |

## Lệnh thường dùng

```powershell
dart run build_runner build   # sau khi sửa model json_serializable
flutter analyze
flutter test
```

## Ghi chú

- Năm học là state global — không hard-code `school_year_id`.
- Archive = soft delete theo backend; không hard-delete dữ liệu từ app (trừ endpoint health DELETE nếu backend yêu cầu).
- Không log password, JWT, Cookie hay Set-Cookie.
