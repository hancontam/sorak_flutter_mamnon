# Sorak Flutter - Claude Handoff

Core read and transfer wiring is complete through Goals 34-35. Before touching these repositories, read `docs/core_api_integration_handoff.md` and run `flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart`. In particular, Academic Years accepts no pagination query; class transfers have no DELETE route; school transfers have no restore route.

## Goal 33 complete - Global Academic Year

Read `docs/goal_33_global_academic_year.md` before changing year-scoped code. The global selector lives in `AppShell`, its state is persisted through `LocalStorage`, and live flows must never silently fall back to `school_year_id: 1`. Goal 34 is the next core task: wire read APIs only after checking backend routes and validators.

Đọc theo thứ tự:

1. `AGENTS.md` - context và rule bắt buộc của dự án.
2. `docs/api_contract_audit.md` - bảng contract đã đối chiếu và trạng thái từng repository Flutter.
3. `docs/core_api_integration_handoff.md` - auth cookie, global academic year và kế hoạch Goal 30+.
4. Code Flutter hiện tại trong `lib/core` và `lib/modules`.
5. Repo tham chiếu `toanthienla/sorak-mamnonhontre` tại commit `4263240651d4aad8223a592d34c056305e432663`.

## Trọng tâm hiện tại

Tạm dừng polish/vibe UI. Ưu tiên theo thứ tự:

1. Biến năm học thành filter chung của toàn app.
2. Sửa Health không bị NavigationBar và bàn phím che.
3. Nối live API từng module, có contract test trước khi chuyển module tiếp theo.

## Rule không được phá

- Provider + ChangeNotifier, Dio qua ApiClient, SharedPreferences cho app state/session metadata.
- Model API dùng `json_serializable`; chạy `dart run build_runner build` khi model thay đổi.
- Không hard-code `school_year_id`, class id, student id hoặc token trong live flow.
- Không đoán endpoint. Backend route/validator là nguồn contract chính; web là nguồn flow gọi API.
- Delete trên UI là archive/soft delete theo endpoint backend.
- Không làm Import/Export Excel.
- Không log password, JWT, Cookie hoặc Set-Cookie.

## Chạy live

```powershell
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

Server deploy đã được probe ngày 2026-07-10: login staff, `/auth/me` bằng cookie và `/auth/refresh` đều trả HTTP 200. Không ghi tài khoản/mật khẩu vào file mới hoặc test snapshot.

## Gate sau mỗi Goal

```powershell
dart run build_runner build
flutter analyze
flutter test
```

Goal liên quan live API phải có thêm integration test bằng `DioAdapter`/mock interceptor và manual smoke test trên Android.

## Goal 31 đã hoàn thành

- `ApiClient.persistent()` tạo `PersistCookieJar`; `main.dart` khởi tạo một lần và inject dùng chung cho app.
- `ApiClient.memory()` dùng `CookieJar` memory cho test.
- `dio_cookie_manager` tự nhận `Set-Cookie` và tự gửi cookie theo domain/path.
- SharedPreferences chỉ giữ metadata người dùng, không lưu access/refresh token.
- App khôi phục phiên live qua `GET /auth/me`; chỉ 401/403 mới xóa cookie + metadata. Lỗi mạng không xóa cookie bền vững.
- Logout luôn xóa cookie + metadata trong `finally`.
- Goal 32 đã hoàn thành: single-flight refresh, retry một lần, NO_REFRESH, clear session và điều hướng Login khi refresh thất bại.
