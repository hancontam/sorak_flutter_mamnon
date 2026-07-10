# Core API Integration Handoff

Ngày phân tích: 2026-07-10  
Web/API reference commit: `4263240651d4aad8223a592d34c056305e432663`  
Backend deploy: `http://103.69.191.210:8082/api`

Contract theo repository, method, role, ID, query, body, response và trạng thái hiện tại nằm trong [api_contract_audit.md](api_contract_audit.md). File này là đầu vào bắt buộc trước khi sửa live branch của repository.

## 1. Kết luận quan trọng

Flutter session lifecycle hiện đã bám flow web: cookie jar giữ `sorak_access` và `sorak_refresh`, `ApiClient` refresh single-flight sau 401 rồi retry request đúng một lần. SharedPreferences chỉ giữ metadata user, không giữ JWT.

Ngoài ra, global academic year mới chỉ được hiển thị trong AppBar. Nhiều repository/screen chưa lắng nghe selected year, một số flow Health/Growth còn hard-code `school_year_id: 1`. Vì vậy dropdown có thể đổi nhãn nhưng dữ liệu không đổi theo.

Health đang dùng `ListView` bên trong `AppShell`, chưa có bottom content padding rõ ràng. Bottom sheet đã cộng `viewInsets.bottom` nhưng cần cộng thêm safe-area bottom và kiểm tra nút cuối khi bàn phím mở.

## 2. Auth contract từ web sang backend

### Login

| Flow | Method và path | Body |
|---|---|---|
| Cán bộ | `POST /auth/login` | `{ "email": string, "password": string }` |
| Phụ huynh | `POST /auth/parent-login` | `{ "student_id_card_number": string, "password": string }` |

Response JSON chỉ chứa `user` trong envelope. Token không nằm trong JSON:

```json
{
  "success": true,
  "data": {
    "user": {}
  }
}
```

Backend phát cookie:

| Cookie | TTL | Path | Mục đích |
|---|---:|---|---|
| `sorak_access` | 15 phút | `/` | Xác thực request thường |
| `sorak_refresh` | 7 ngày | `/api/auth` | Chỉ gửi tới refresh/logout auth path phù hợp |

### Request thường

Web tạo Axios với `withCredentials: true`. Browser tự gửi cookie. Không có request interceptor gắn Authorization và Zustand chỉ persist `user`.

Backend middleware đọc theo thứ tự:

1. Cookie `sorak_access`.
2. Header `Authorization: Bearer <token>` làm fallback cho Swagger/tool.

Bearer không giải quyết refresh vì refresh controller chỉ đọc `req.cookies.sorak_refresh`.

### Refresh và retry

Khi response là 401, web:

1. Bỏ qua refresh cho login, parent-login, refresh, forgot-password, reset-password.
2. Đánh dấu request gốc đã retry.
3. Dùng một shared promise để nhiều request 401 chỉ tạo một `POST /auth/refresh`.
4. Backend đọc refresh cookie và phát access cookie mới.
5. Retry request gốc đúng một lần.
6. Nếu refresh thất bại: clear user và về login.

### Thiết kế Flutter cần triển khai

- Thêm `cookie_jar` + `dio_cookie_manager`; dùng một cookie jar cho ApiClient và auth lifecycle.
- Dùng persistent cookie jar để giữ phiên qua app restart. SharedPreferences vẫn giữ user metadata và selected academic year; không tự parse JWT bằng string split.
- Request interceptor không log/ghi đè `Cookie`, `Set-Cookie`, `Authorization`.
- Response interceptor có danh sách `NO_REFRESH`, cờ retry và single-flight refresh.
- Refresh dùng Dio riêng nhưng cùng cookie jar để tránh interceptor tự gọi lặp.
- Sau refresh, retry bằng ApiClient chính với nguyên method/path/query/body/header an toàn.
- Refresh fail: clear cookie jar + SharedPreferences auth, phát sự kiện session expired cho `AuthProvider`, điều hướng login một lần.
- Logout: gọi `POST /auth/logout` khi còn session, sau đó luôn clear local cookie/user trong `finally`.
- Startup: nếu có user metadata, gọi `GET /auth/me`; interceptor được phép refresh. Chỉ vào AppShell khi `/me` thành công.

## 3. Global academic year contract

Web dùng một Zustand store `selectedYearId`, persist trong localStorage. `YearSelector` gọi `GET /academic-years`, tự chọn bản ghi `status == active` khi chưa có selection.

Flutter cần một nguồn duy nhất là `ActiveAcademicYearProvider`:

- Persist `selectedYearId` trong SharedPreferences.
- Nếu persisted id không còn tồn tại, chọn active year; nếu không có active thì chọn phần tử đầu.
- Selector nằm ở header chung của `AppShell`, không nằm riêng trong Health hay list module.
- `selectYear()` phải trigger reload dữ liệu màn đang hoạt động.
- Khi đổi year, reset class/student phụ thuộc trước khi fetch lại.
- Principal, Teacher và Parent dùng cùng year state; API/role vẫn quyết định dữ liệu họ được xem.

Các module phải truyền `school_year_id`:

| Module | Request chính cần year |
|---|---|
| Classes | `GET /classes?school_year_id=...` |
| Students | `GET /students?school_year_id=...`; class options cùng year |
| Teachers | `GET /teachers?school_year_id=...` theo flow web |
| Class transfers | list query có `school_year_id`; form load class/student theo year |
| Incoming/Outgoing | list query và create body khi có `school_year_id` |
| Health | list/history/bulk theo year; roster class theo year |
| Nutrition | `grid`/`bulk` bắt buộc `school_year_id` |
| Growth | history bắt buộc dùng selected year trong Flutter flow |

Các hard-code cần xóa trước khi live:

- `health_roster_dashboard.dart`: create Health/Nutrition đang gửi `'school_year_id': '1'`.
- `growth_who_repository.dart`: history đang query `school_year_id: 1`.
- Các form Health/Nutrition default `'1'` phải lấy provider.
- Repository mock có thể dùng id mẫu nội bộ, nhưng live branch không được fallback âm thầm về year 1.

## 4. API contract ưu tiên

Contract đầy đủ phải được chép từ backend route + validator vào test trước khi nối từng repository. Bảng dưới là phần core đã xác nhận từ web và API.

| Module | Read/list | Create/update/action |
|---|---|---|
| Auth | `GET /auth/me` | login, parent-login, refresh, logout, change-password |
| Academic years | `GET /academic-years`, `GET /academic-years/archived` | `POST /academic-years`, `PATCH /:id`, `PATCH /:id/activate`, `POST /:id/promote`, `DELETE /:id`, `POST /:id/restore` |
| Classes | `GET /classes` với `school_year_id`, `age_group`, pagination/search | CRUD; teacher assignment dùng `POST /classes/:id/teachers` và `DELETE /classes/:id/teachers/:teacherId` |
| Teachers | `GET /teachers` với year/role/work status | CRUD, archive, restore |
| Students | `GET /students` với year/class/status | create có thể nhận `class_id`; update không nhận `class_id`; chuyển lớp phải qua Class Transfer |
| Accounts | `GET /accounts` với `type=staff|parent`, role/status filters | assign-role, role, active, password; parent active dùng `PATCH /students/:id/active` |
| Class transfer | `GET /class-transfers` với year/class/student/status | `POST /class-transfers`; `PATCH /:id/status` body `{action,note}` |
| School transfer | `GET /incoming-transfers` hoặc `/outgoing-transfers` | create/update, `PATCH /:id/cancel`, `DELETE /:id` soft delete |
| Health | `GET /health-assessments/by-class-date?class_id&assessment_date`; history | `POST /health-assessments/bulk` cho roster; single create/update/delete cho history |
| Nutrition | `GET /nutrition-assessments/grid?class_id&school_year_id&period` | `POST /nutrition-assessments/bulk` |
| Growth | `GET /health-assessments/history?student_id&school_year_id`; WHO curves | curves query `{indicator: height|weight|bmi, gender: Nam|Nữ}` |

Không triển khai endpoint Excel dù web có gọi.

### Sai lệch live đã thấy trong Flutter hiện tại

Các điểm dưới đây phải được xử lý trong Goal 30-36, không được xem mock chạy được là contract đúng:

- Nền auth cookie/refresh đã hoàn thành ở Goal 31-32. Không quay lại Bearer hoặc tự parse `Set-Cookie`.
- `ClassRepository.getAll()` không gửi selected year. Form gửi `teacher_name` trong payload create/update, trong khi validator lớp không nhận field này; phân công giáo viên phải gọi endpoint `/classes/:id/teachers` riêng. Update lớp cũng không nhận `school_year_id`.
- `TeacherRepository` và `StudentRepository` list chưa truyền global year.
- Update Student không được gửi `class_id` hoặc `grade_level`; chuyển lớp phải qua `/class-transfers`.
- Accounts có hai loại id: `teacher_id` cho `assign-role` va `role`; `account_id` cho active/password/delete/restore. Provider/UI phải truyền đúng id theo action.
- Health roster hiện load list chung rồi lọc client-side; web dùng `/health-assessments/by-class-date` và lưu roster bằng `/health-assessments/bulk`.
- Nutrition repository hard-code year/period. Backend Nutrition không có delete/archive route; không được giả Delete bằng cách bulk ghi các cờ false/null. UI action phải bám đúng nghiệp vụ backend hoặc bỏ action đó.
- Growth history đang hard-code year 1 và có chỗ gọi list health chung thay vì `/history`.
- `ApiResponse` cần test cả list envelope có pagination/meta và object envelope; không tự thêm fallback shape nếu backend không trả shape đó.

### Android transport preflight

Backend deploy hiện dùng HTTP. Trước manual live test cần kiểm tra:

- Debug APK có quyền Internet và cho phép cleartext tới host test.
- Release manifest không được vô tình thiếu Internet permission.
- Chỉ bật cleartext cho môi trường test; hướng production là HTTPS.
- Base URL phải kết thúc ở `/api` đúng một lần và Android emulator không dùng `localhost` để trỏ VPS.

### Health bulk body

```json
{
  "school_year_id": 1,
  "class_id": 1,
  "assessment_date": "2026-07-10",
  "rows": [
    {
      "student_id": 1,
      "height_cm": 100.5,
      "weight_kg": 16.2,
      "note": ""
    }
  ]
}
```

### Nutrition grid và bulk

Grid query bắt buộc: `class_id`, `school_year_id`, `period`.

Bulk body:

```json
{
  "class_id": 1,
  "school_year_id": 1,
  "period": "dau_nam",
  "rows": [
    {
      "student_id": 1,
      "weight_channel": "",
      "is_stunting": false,
      "is_severe_stunting": false,
      "is_obese": false,
      "note": ""
    }
  ]
}
```

## 5. Health layout fix

Mục tiêu là item cuối và nút lưu luôn cuộn lên được phía trên NavigationBar/bàn phím.

- `AppShell.body` giữ một content area rõ ràng; không bọc nhiều Scaffold lồng nhau.
- `HealthScreen` dùng `SafeArea(top: false)` và `ListView` có bottom padding động.
- Bottom padding tối thiểu: `AppSpacing.md + MediaQuery.padding.bottom`; nếu NavigationBar overlay thì cộng chiều cao nav thực tế.
- Không dùng fixed height `720` cho Growth nằm trong Health; dùng widget có constraint theo viewport hoặc route riêng.
- Bottom sheet quick entry dùng `viewInsets.bottom + padding.bottom + AppSpacing.md`.
- Widget test ở màn 360x640: scroll tới học sinh cuối, mở sheet, focus input và thấy nút Lưu.

## 6. Test strategy

Automated, không gọi server thật:

- Login lưu đủ cookie access + refresh trong cookie jar.
- Request sau login gửi cookie và `/auth/me` thành công qua mock adapter.
- 401 -> một refresh -> retry request -> success.
- Hai request 401 đồng thời chỉ gọi refresh một lần.
- 401 từ login/refresh không tạo loop.
- Refresh fail clear session và phát session-expired đúng một lần.
- Đổi academic year làm request kế tiếp mang đúng `school_year_id`, reset class/student filter.
- Health small viewport không che item cuối/nút save.

Manual live smoke:

1. Login cán bộ, gọi `/auth/me`, mở Classes/Students/Health.
2. Đổi năm học và xác nhận request/data của mọi tab đổi theo.
3. Giả lập access hết hạn hoặc chờ expiry; request phải tự refresh, không đá về login.
4. Kill/reopen app; session được phục hồi nếu refresh cookie còn hạn.
5. Logout; mở lại app không được vào AppShell.

## 7. Goal mới

### Goal 30 - API Contract Audit

- Đối chiếu toàn bộ Flutter repository với web feature, API route và validator.
- Tạo contract matrix cho endpoint, method, role, query, body, response và archive behavior.
- Đánh dấu từng repository: mock-only, live-correct, live-wrong hoặc chưa nối.
- Chốt rõ id semantics (`teacher_id`, `account_id`, `student_id`, `class_id`) và field bị validator từ chối.
- Không sửa UI ngoài lỗi build cần thiết.

### Goal 31 - Cookie Session Foundation

- Thêm cookie jar dùng chung cho Dio.
- Refactor AuthRepository bỏ parse riêng access cookie.
- Lưu user metadata, khôi phục phiên bằng `/auth/me`, logout clear local trong `finally`.
- Kiểm tra Android Internet/HTTP test transport và base URL trước khi kết luận lỗi auth.
- Thêm test login staff/parent và persistence.

Trạng thái: hoàn thành. `ApiClient.persistent()` dùng `PersistCookieJar`, còn widget test dùng `ApiClient.memory()`. `AuthRepository.restoreSession()` gọi `/auth/me`; lỗi 401/403 clear session, lỗi mạng giữ cookie để lần sau thử lại.

### Goal 32 - 401 Refresh Interceptor

- Thêm NO_REFRESH, retry một lần, single-flight refresh và session-expired callback.
- Bảo toàn method/path/query/body khi retry.
- Thêm test success, concurrent 401, refresh fail và no-loop.

Trạng thái: hoàn thành. `ApiClient` giữ một refresh future dùng chung, bỏ qua login/parent-login/refresh/forgot/reset, retry method/path/query/body đúng một lần sau refresh. Refresh fail chỉ phát session-expired một lần; `AuthProvider` clear metadata và `navigatorKey` quay app về Login. Test adapter kiểm tra retry, concurrent requests, failure clear và no-loop.

### Goal 33 - Global Academic Year State

- Persist selected year; fallback active year hợp lệ.
- Giữ selector ở AppShell header chung cho mọi role/tab.
- Tạo cơ chế module reload và reset filter phụ thuộc khi year đổi.
- Xóa toàn bộ hard-code year trong live flow.

## Goal 33 Implementation Status

Status: complete (2026-07-10).

- `ActiveAcademicYearProvider` persists the selected id in SharedPreferences through `LocalStorage`; stale ids fall back to active year, then the first available year.
- The AppShell selector is the only global selector. Its listener synchronizes `FormOptionsProvider`, reloads the visible destination, and remounts the screen after the reload.
- Year-scoped reload is implemented for Classes, Students, Teachers, Class Transfers, Incoming Transfers, Outgoing Transfers, Health, Nutrition, and Growth.
- Form options reset class/student dependencies when the year changes. Health and Nutrition forms plus roster bulk save read the selected provider value.
- Live calls no longer contain an implicit `school_year_id: 1` fallback. Static mock fixtures may still use sample id `1`.
- Automated coverage is in `test/functional/active_academic_year_functional_test.dart`; persistence and AppShell/provider synchronization pass.

### Goal 34 - Core Read API Wiring

- Nối list/read theo contract cho Years, Classes, Teachers, Students và Accounts.
- Mọi list truyền pagination/search/filter/year đúng kiểu dữ liệu.
- Chuẩn hóa unwrap response + API error tiếng Việt.

### Goal 35 - Transfers API Wiring

- Nối Class/Incoming/Outgoing transfers theo route + validator.
- Phân biệt status action, cancel và soft delete.
- Form options lấy class/student của selected year.

## Goal 34 and Goal 35 Implementation Status

Status: complete (2026-07-10).

### Core reads

- `ApiListQuery` and `ApiPage` provide the backend pagination contract: `page`, `pageSize`, `search`, `sortBy`, and `sortOrder`.
- Classes, Teachers, Students, and Accounts expose typed `getPage(...)` calls for their supported filters. `getAll()` remains the adapter used by current list screens and requests a bounded page.
- Academic Years deliberately sends no pagination query because its backend validator accepts an empty query only.
- Accounts calls `type=staff` or `type=parent`. Staff filters are role/work status/position/account active state; parent filters are student status/account active state. Parent account rows are normalized to `accountType: parent`.

### Transfers

- Class Transfer list supports page/search/year/status/class/student filters. Status mutation is only `PATCH /class-transfers/:request_id/status` with `{ action, note? }`; there is no DELETE route. Its archive adapter maps to `cancel`, and restore maps to `revert`.
- Incoming and Outgoing lists support page/search/year/status/class/student filters; Incoming also supports `previous_school`.
- Incoming and Outgoing Cancel is `PATCH /:transfer_id/cancel` with optional `{ cancel_reason }`. Delete UI calls `DELETE /:transfer_id`, the backend soft archive route. Their backend has no restore route, so the live repository explicitly reports unsupported restore rather than pretending it worked.
- Account ID rule verified against backend service: `assign-role` and `role` receive `teacher_id`; account active/password/archive receive `account_id`; parent active receives `student_id`.

### Contract test

Run this test when changing a live repository:

```powershell
flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart
```

The adapter validates paths, pagination/filter query names, request bodies, and ID semantics without calling the deploy.

### Goal 36 - Health, Nutrition, Growth API Wiring

Status: complete (2026-07-10).

- Health roster: `getByClassDate` + `bulkSave`; roster sheet saves via bulk with selected year.
- Nutrition: `getGrid` + `bulkSave`; live archive throws (no DELETE route); list hides Delete.
- Growth: history with selected year; `getWhoCurves`; Parent stays view-only mock (staff endpoints only).
- Contract tests in `live_api_contract_functional_test.dart`.

### Goal 37 - Health Layout Regression

Status: complete (2026-07-10).

- HealthScreen: SafeArea, dynamic bottom padding (safe inset + NavigationBar).
- Bottom sheet: viewInsets.bottom + padding.bottom.
- Removed fixed Growth height 720; embedded GrowthWhoScreen.
- `health_layout_functional_test.dart` at 360x640.

### Goal 38 - Live API Smoke and Hardening

Status: complete (2026-07-10).

- HTTP smoke: login/me/refresh/year change data path + health by-class-date, nutrition grid, growth history/who-curves, logout all 200.
- Android emulator UI smoke skipped (no device); secrets never logged.
- Checklist + regression report updated.

### Goal 39 - Final Regression and Commit

Status: complete (2026-07-10).

- `flutter analyze` clean; full `flutter test` pass; live contract pass with USE_MOCK_API=false.
- Hard-code scan clean for health live year fallbacks.
- Debug APK build attempted; clean commit of Goals 36-39.
