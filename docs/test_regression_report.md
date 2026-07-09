# Sorak Flutter Mobile - Regression Test Report

## Thong Tin Chung

Ngay chay: 2026-07-09

Pham vi:

- Functional test bang `flutter test` voi mock API.
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

## Regression Gate Ket Qua

| Command | Ket qua | Ghi chu |
| --- | --- | --- |
| `dart run build_runner build` | Pass | Built with build_runner; wrote generated outputs |
| `flutter analyze` | Pass | No issues found |
| `flutter test` | Pass | All tests passed, tong 26 tests |

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
