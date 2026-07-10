# Sorak Flutter Mobile - Regression Test Report

## Thong Tin Chung

Ngay chay: 2026-07-10 (Goals 36-49)

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

## Goals 40-49 status

| Goal | Status | Notes |
| --- | --- | --- |
| 40 Baseline/defects | Pass | Inventory SORAK-TEST-001..013, known regressions captured |
| 41 Canonical mock API | Pass | One Dio adapter, live envelopes, pagination, nested Vietnamese fixtures |
| 42 Mutation contracts | Pass automated | Exact Class/Student/Transfer DTOs; live Android mutation still pending |
| 43 Global year | Pass | Three datasets, all-tab invalidation, empty year, stale response race |
| 44 Principal journeys | Pass automated | Accounts, CRUD, transfer, health/nutrition/growth flows |
| 45 Teacher scope | Pass automated | Assigned class/student data, action visibility, deep-link and API 403 |
| 46 Parent truthful data | Pass with backend blocker | `/auth/me` profile only; Health/Growth show unavailable, never mock |
| 47 Health/Nutrition/Growth | Pass automated | Bulk save then reload, missing rows, history and WHO curves |
| 48 Cross-module integrity | Pass automated | Teacher-account grant and class transfer approve/revert |
| 49 Live/final regression | Partial | Mock Android role smoke passes; live adapter passes; live Android still pending |
| 50 UI/UX enhancement | Blocked by quality gate | Do not start while High live/backend gaps remain |

## Regression Gate Ket Qua

| Command | Ket qua | Ghi chu |
| --- | --- | --- |
| `dart run build_runner build` | Pass | Teacher and Account generated parsers updated |
| `flutter analyze` | Pass | No issues found |
| `flutter test` | Pass | 83 passed, 2 skipped (live contract skipped when mock default) |
| Live contract health/nutrition/growth | Pass | `flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart` |
| Hard-code/endpoint scan | Pass | No live year-1 fallback in health; no secret prints |
| Live HTTP smoke | Pass | login/me/refresh/year/health/nutrition/growth/logout all HTTP 200; secrets not logged |
| Android mock UI smoke | Pass | Pixel 7 Pro emulator, Android 16/API 36; Principal, Teacher, Parent and staff Health |
| Android live UI smoke | Pending | Requires explicit live run; no live mutation was performed |
| Debug APK | Pass | `build/app/outputs/flutter-apk/app-debug.apk` |

## Automated Functional Test Files

| File | Muc dich | Ket qua |
| --- | --- | --- |
| `test/widget_test.dart` | Smoke login screen | Pass |
| `test/functional/goal_1_test_foundation_test.dart` | Nen functional test, pump app, fake CRUD provider flow | Pass |
| `test/functional/auth_functional_test.dart` | Authentication: login form, login success/fail, saved session, logout | Pass |
| `test/functional/home_navigation_test.dart` | Home menu va navigation toi 8 module | Pass |
| `test/functional/crud_modules_functional_test.dart` | CRUD provider flow cho Academic Year, Accounts, Classes, Teachers, Students | Pass |
| `test/functional/transfer_modules_functional_test.dart` | Transfer provider flow cho Class, Outgoing, Incoming transfers | Pass |
| `test/functional/canonical_mock_api_functional_test.dart` | Envelope, parser, pagination, year dataset, Teacher scope | Pass |
| `test/functional/mutation_contract_functional_test.dart` | Exact mutation body and Teacher-Accounts integrity | Pass |
| `test/functional/academic_year_race_functional_test.dart` | Old request cannot overwrite selected year | Pass |
| `test/functional/role_permission_functional_test.dart` | Teacher/Parent visibility and API permission | Pass |
| `test/functional/health_data_journey_functional_test.dart` | Health/Nutrition/Growth persistence and class transfer integrity | Pass |

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

## Android Evidence

Evidence generated on Pixel 7 Pro emulator (Android 16/API 36):

- `docs/evidence/android_login.png`
- `docs/evidence/android_principal.png`
- `docs/evidence/android_principal_health.png`
- `docs/evidence/android_teacher.png`
- `docs/evidence/android_parent.png`
- `docs/evidence/android_parent_health.png`

Observed:

- No `FATAL EXCEPTION`, `E/flutter`, Dart error, or ANR in the checked logs.
- Principal has global active-year selector and whole-school dashboard.
- Teacher sees one assigned class/student and own transfer counts, not the
  whole-school teacher count.
- Parent has no staff year selector and Health displays unavailable state
  instead of fixture data.
- Staff Health content remains above the Material 3 bottom navigation.

Quy tac:

- Chi create/update/archive record test co prefix `MOBILE_TEST_`.
- Khong bam Delete tren data that quan trong.
- UI Delete phai duoc hieu la archive/soft delete.
- Ghi lai Result va Note trong checklist manual.

## Ket Luan

Trang thai automated regression: Pass (83 pass, 2 conditional skip).

Trang thai live API smoke read-only: Pass.

Trang thai Android mock UI: Pass cho Principal, Teacher va Parent.

Trang thai Android live API: Chua chay. Khong duoc ket luan live UI on dinh truoc khi lap lai read smoke theo role voi `USE_MOCK_API=false`.

Definition of Done tong the: Chua dat. Con blocker Parent Health/Growth API,
live mutation `MOBILE_TEST_` va Android live role smoke.
