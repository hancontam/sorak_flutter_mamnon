# Kiến trúc ứng dụng

## Tổng quan

Sorak Flutter là client mobile cho hệ thống quản lý mầm non. App tách **core** (dùng chung) và **modules** (theo nghiệp vụ).

## Stack

- **UI:** Flutter Material 3
- **State:** `Provider` + `ChangeNotifier`
- **HTTP:** Dio qua `ApiClient`
- **Session:** cookie jar (`sorak_access` / `sorak_refresh`), không lưu JWT trong SharedPreferences
- **Local:** `LocalStorage` (metadata user, năm học đã chọn)
- **Model API:** `json_serializable` (file `.g.dart` generate)

## Cấu trúc thư mục

```text
lib/
  core/
    constants/     # AppConfig, endpoints, options
    network/       # ApiClient, ApiResponse, MockApiBackend
    storage/       # LocalStorage
    theme/         # màu, spacing, ThemeData
    widgets/       # AppShell, form fields, empty/error/loading
    providers/     # CrudProvider base
    repositories/  # CrudRepository interface
  modules/
    [tên_module]/
      models/
      repositories/
      providers/
      screens/
      widgets/     # (nếu cần)
```

## Luồng một module

1. Model JSON + `part '*.g.dart'`
2. `dart run build_runner build`
3. Repository gọi Dio (mock và live cùng parser)
4. Provider kế thừa `ChangeNotifier` / `CrudProvider`
5. Screen list → form create/update → detail (nếu cần)

## Auth

- Login staff: `POST /auth/login`
- Login parent: `POST /auth/parent-login`
- Khôi phục phiên: `GET /auth/me` (cookie)
- 401: refresh một lần (`POST /auth/refresh`), thất bại thì clear session và về Login
- Logout: `POST /auth/logout` + xóa cookie và metadata

## Năm học global

`ActiveAcademicYearProvider` là nguồn chọn năm học duy nhất:

- Load danh sách năm, ưu tiên `status == active`
- Lưu `selected_academic_year_id` qua `LocalStorage`
- Đổi năm → reload module phụ thuộc (lớp, học sinh, transfer, health…)
- Không hard-code `school_year_id` trong live flow

## Soft delete

- UI hiển thị **Delete**
- Code/API gọi archive / soft delete (`DELETE /api/[resource]/:id` theo backend)
- Không hard-delete dữ liệu nghiệp vụ từ app khi backend chỉ hỗ trợ soft delete

## Mock vs Live

| Chế độ | Cách bật |
| --- | --- |
| Live | **mặc định** — `flutter run` / Run-Debug / build APK |
| Mock | `--dart-define=USE_MOCK_API=true` hoặc `flutter test` (force mock) |

Repository **không** có nhánh mock riêng; mock và live dùng chung DTO/parser.

## Vai trò

| Role | Ghi chú |
| --- | --- |
| `PRINCIPAL` | Ban Giám Hiệu — full admin |
| `TEACHER` | Giáo viên — lớp/học sinh được phân công |
| `PARENT` | Phụ huynh — portal chỉ xem |

Chi tiết UI theo role: [UI.md](UI.md).
