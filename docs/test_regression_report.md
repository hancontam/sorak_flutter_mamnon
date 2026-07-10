# Sorak Flutter Mobile - Regression Test Report

## Thong Tin Chung

Ngay chay: 2026-07-10 (Goals 36-39)

Pham vi:

- Functional test bang `flutter test` voi mock API.
- Live contract test (`USE_MOCK_API=false`) cho Health/Nutrition/Growth.
- Regression gate cho generated code, static analysis, automated tests.
- Smoke test live API chi doc du lieu, khong ghi DB that.
- Manual live API checklist duoc tach rieng tai `docs/manual_live_api_checklist.md`.

Backend live:

```text
http://103.69.191.210:8082/api
```

Tai khoan smoke test:

```text
phanthihoa@edu.vn
```

## Goals 36-39 status

| Goal | Status | Notes |
| --- | --- | --- |
| 36 Health/Nutrition/Growth API wiring | Pass | by-class-date, bulk, grid, bulk, history, who-curves; contract tests green |
| 37 Health layout regression | Pass | SafeArea, dynamic bottom padding, no fixed 720; small-viewport test |
| 38 Live smoke + hardening | Pass (HTTP) / Android UI skip | Login/me/refresh/logout/year + Health/Nutrition/Growth reads HTTP 200; no secrets logged |
| 39 Final regression + commit | Pass | analyze clean, full test 66 pass / 2 skip (live contract needs USE_MOCK_API=false), debug APK attempted |

## Regression Gate Ket Qua

| Command | Ket qua | Ghi chu |
| --- | --- | --- |
| `dart run build_runner build` | N/A | WhoCurvePoint is hand-written; no json_serializable model change |
| `flutter analyze` | Pass | No issues found |
| `flutter test` | Pass | 66 passed, 2 skipped (live contract skipped when mock default) |
| Live contract health/nutrition/growth | Pass | `flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart` |
| Hard-code/endpoint scan | Pass | No live year-1 fallback in health; no secret prints |
| Live HTTP smoke | Pass | login/me/refresh/year/health/nutrition/growth/logout all HTTP 200; secrets not logged |

## Automated Functional Test Files

| File | Muc dich | Ket qua |
| --- | --- | --- |
| `test/widget_test.dart` | Smoke login screen | Pass |
| `test/functional/goal_1_test_foundation_test.dart` | Nen functional test, pump app, fake CRUD provider flow | Pass |
| `test/functional/auth_functional_test.dart` | Authentication: login form, login success/fail, saved session, logout | Pass |
| `test/functional/home_navigation_test.dart` | Home menu va navigation toi 8 module | Pass |
| `test/functional/crud_modules_functional_test.dart` | CRUD provider flow cho Academic Year, Accounts, Classes, Teachers, Students | Pass |
| `test/functional/transfer_modules_functional_test.dart` | Transfer provider flow cho Class, Outgoing, Incoming transfers | Pass |

## Automated Test Coverage Theo Module

| Module | Automated coverage hien co |
| --- | --- |
| Authentication | Login form, success, fail state, saved session, logout |
| Home | User info, role, 8 menu module, route toi list screens |
| Academic Year | List, detail, create, update, archive, activate |
| Accounts | List, detail, create, update, archive |
| Classes | List, detail, create, update, archive |
| Teachers | List, detail, create, update, archive |
| Students | List, detail, create, update, archive |
| Class Transfer | List, detail, create, approve, reject, cancel/archive, restore |
| Outgoing Transfer | List, detail, create, update, cancel, archive |
| Incoming Transfer | List, detail, create, update, cancel, archive |

## Live API Smoke Test

Chi test doc du lieu, khong create/update/delete/archive.

| API | Ket qua | So record |
| --- | --- | --- |
| Login | OK | - |
| GET /academic-years | OK | 2 |
| GET /classes | OK | 17 |
| GET /teachers | OK | 20 |
| GET /students | OK | 20 |
| GET /accounts | OK | 20 |
| GET /class-transfers | OK | 3 |
| GET /outgoing-transfers | OK | 3 |
| GET /incoming-transfers | OK | 3 |

## Manual Test Con Lai

Can mo app that tren emulator/device va check theo file:

```text
docs/manual_live_api_checklist.md
```

Lenh chay live API:

```powershell
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

Quy tac:

- Chi create/update/archive record test co prefix `MOBILE_TEST_`.
- Khong bam Delete tren data that quan trong.
- UI Delete phai duoc hieu la archive/soft delete.
- Ghi lai Result va Note trong checklist manual.

## Ket Luan

Trang thai automated regression: Pass.

Trang thai live API smoke read-only: Pass.

Trang thai manual UI live API: Chua chay tren emulator/device trong Goal 7, can tester thuc hien theo checklist.
