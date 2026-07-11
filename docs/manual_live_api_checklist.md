# Sorak Flutter Mobile - Manual Live API Checklist

## Muc Tieu

- Test thu cong app Flutter voi backend live API.
- Chi kiem tra muc chuc nang, khong test unit chi tiet.
- Khong goi create/update/delete/archive bang script auto tren DB that.
- Neu can test create/update/archive, chi dung record test va ghi chu ro.

## Moi Truong Test

Backend live:

```text
http://103.69.191.210:8082/api
```

Tai khoan can bo:

```text
Email: phanthihoa@edu.vn
Password: <nhap tu password manager cuc bo>
```

Chay app live API bang terminal:

```powershell
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

Neu chay bang Android Studio, them vao Additional run args:

```text
--dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

## Smoke Test API Da Chay

Ngay chay: 2026-07-09

Ket qua chi doc du lieu, khong ghi DB:

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

### Goal 38 re-smoke (2026-07-10)

Read-only HTTP smoke against live deploy (no token/cookie/password logged; status codes only):

| Step | Ket qua |
| --- | --- |
| POST /auth/login | HTTP 200, cookies present (values not logged) |
| GET /auth/me | HTTP 200 |
| POST /auth/refresh | HTTP 200 |
| GET /academic-years + select active year | HTTP 200 |
| GET /classes?school_year_id=selected | HTTP 200 |
| GET /health-assessments/by-class-date | HTTP 200 |
| GET /nutrition-assessments/grid | HTTP 200 |
| GET /health-assessments/history | HTTP 200 |
| GET /health-assessments/who-curves | HTTP 200 |
| POST /auth/logout | HTTP 200 |

Android emulator UI smoke: skipped in this environment (no device/emulator attached). Automated contract tests cover Flutter repository paths with Dio adapter.

### Goal 49 Android live smoke (2026-07-11)

Live flavor was installed on a clean Android 15/API 35 x86_64 AVD.

| Journey | Result | Evidence |
| --- | --- | --- |
| Principal login, `/me`, active year | Pass | Dashboard: 49 students, 9 classes, 21 teachers |
| Teacher login and role scope | Pass | 1 assigned class, 3 assigned students |
| Teacher Classes/Students/Transfers/Health | Pass | Health roster contains the same 3 students |
| Principal Teacher create | Pass | Created `MOBILE_TEST_TEACHER_235640`, ID 26 |
| Delete UI -> soft archive | Pass | Record hidden; detail returns `deleted_at` |
| Parent login/profile | Pass | Provisioned student ID 226; `/auth/me` matched; archived after smoke |
| Parent Health/Growth | Pass truthful fallback | Unsupported API state shown; no mock data |

No password, cookie or token value was written to the report. Screenshots are
stored under `docs/evidence/android_live_*.png`.

## Quy Tac Khi Test DB That

- Khong bam Delete/Archive tren record quan trong.
- Neu can test Delete UI, tao record test truoc roi chi archive record do.
- Ten record test nen co prefix de de tim:

```text
MOBILE_TEST_
```

- Sau khi test create/update/archive, ghi lai id/name record vao cot Note.
- Neu app bao loi live API, chup man hinh va ghi module + action + message.

## Checklist Tong Quan

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| LIVE-001 | App chay live API | Chay lenh flutter run voi dart-define live API | App mo duoc man Login | Pass | API 35 AVD |
| LIVE-002 | Login can bo | Nhap account can bo va bam Login | Vao Home, hien Welcome va Role | Pass | Principal va Teacher |
| LIVE-003 | Logout | Bam icon logout tren AppBar | Quay lai Login, session duoc xoa | Untested | |
| LIVE-004 | Mo lai app | Login xong, hot restart/reopen app | Neu session con hop le thi vao Home, neu khong thi Login | Untested | |
| LIVE-005 | Menu Home | Kiem tra navigation theo role | Principal co menu quan ly; Teacher chi co module duoc phep | Pass | Teacher scope dung 1 lop/3 tre |

## Authentication

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| AUTH-001 | Login dung | Login bang account can bo | Vao Home thanh cong | Untested | |
| AUTH-002 | Login sai password | Nhap email dung, password sai | O lai Login va hien loi | Untested | |
| AUTH-003 | Login email sai | Nhap email khong ton tai | O lai Login va hien loi | Untested | |
| AUTH-004 | Logout | Tu Home bam logout | Ve Login | Untested | |

## Academic Year Management

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| AY-001 | View list | Mo Academic Years | Hien list nam hoc tu backend | Untested | |
| AY-002 | View detail | Bam vao 1 nam hoc | Hien detail dung nam hoc | Untested | |
| AY-003 | Create test record | Tao nam hoc test neu backend cho phep | Record moi hien trong list | Untested | Chi tao neu chac la data test |
| AY-004 | Update test record | Sua record vua tao | List/detail cap nhat gia tri moi | Untested | |
| AY-005 | Activate year | Bam Activate tren record test | Status doi dung theo backend | Untested | Can can than vi co the anh huong nam hoc active |
| AY-006 | Delete UI archive | Bam Delete tren record test | Record bi archive/khong con hien tren list | Untested | Chi record test |

## Accounts Management

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| ACC-001 | View list | Mo Accounts | Hien list accounts tu backend | Untested | |
| ACC-002 | View detail | Bam vao 1 account | Hien dung ten/email/role | Untested | |
| ACC-003 | Create account test | Tao account co prefix MOBILE_TEST_ | Tao thanh cong hoac backend bao validation ro rang | Untested | |
| ACC-004 | Update account test | Sua full name/phone cua account test | Cap nhat thanh cong | Untested | |
| ACC-005 | Delete UI archive | Bam Delete account test | Goi archive/soft delete, account an khoi list | Untested | Chi account test |
| ACC-006 | Duplicate email | Tao account voi email da ton tai | Backend tra loi validation/error | Untested | |

## Classes Management

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| CLS-001 | View list | Mo Classes | Hien list lop tu backend | Untested | |
| CLS-002 | View detail | Bam vao 1 lop | Hien dung class name/room/age group | Untested | |
| CLS-003 | Create class test | Tao lop MOBILE_TEST_ neu backend cho phep | Lop moi hien trong list | Untested | |
| CLS-004 | Update class test | Sua room/teacher name/class name | Cap nhat thanh cong | Untested | |
| CLS-005 | Delete UI archive | Bam Delete lop test | Lop bi archive/khong con hien tren list | Untested | Chi lop test |

## Teachers Management

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| TCH-001 | View list | Mo Teachers | Hien list giao vien tu backend | Pass | Live Principal |
| TCH-002 | View detail | Bam vao 1 giao vien | Hien dung ten/email/position | Pass | Test record ID 26 |
| TCH-003 | Create teacher test | Tao giao vien MOBILE_TEST_ | Tao thanh cong | Pass | `MOBILE_TEST_TEACHER_235640` |
| TCH-004 | Update teacher test | Sua phone/position/name | Cap nhat thanh cong | Untested | |
| TCH-005 | Delete UI archive | Bam Delete giao vien test | Giao vien bi archive/khong con hien | Pass | ID 26 has `deleted_at` |

## Students Management

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| STD-001 | View list | Mo Students | Hien list hoc sinh tu backend | Untested | |
| STD-002 | View detail | Bam vao 1 hoc sinh | Hien dung ten/class/status | Untested | |
| STD-003 | Create student test | Tao hoc sinh MOBILE_TEST_ | Tao thanh cong | Untested | |
| STD-004 | Update student test | Sua phone/class/status/name | Cap nhat thanh cong | Untested | |
| STD-005 | Delete UI archive | Bam Delete hoc sinh test | Hoc sinh bi archive/khong con hien | Untested | Chi hoc sinh test |

## Class Transfer

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| CT-001 | View list | Mo Class Transfer | Hien list request tu backend | Untested | |
| CT-002 | View detail | Bam vao request | Hien student/from class/to class/status | Untested | |
| CT-003 | Create request test | Tao request chuyen lop cho student test | Request moi hien status Pending/tuong duong | Untested | Chi dung student test |
| CT-004 | Approve request test | Bam Approve tren request test | Status doi Approved | Untested | |
| CT-005 | Reject request test | Bam Reject tren request test | Status doi Rejected | Untested | |
| CT-006 | Cancel request test | Bam Cancel tren request test | Status doi Cancelled | Untested | |

## Outgoing School Transfer

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| OT-001 | View list | Mo Outgoing Transfer | Hien list chuyen di tu backend | Untested | |
| OT-002 | View detail | Bam vao record | Hien student/destination/status | Untested | |
| OT-003 | Create record test | Tao record chuyen di cho student test | Record moi hien trong list | Untested | |
| OT-004 | Update record test | Sua destination school/note/date | Cap nhat thanh cong | Untested | |
| OT-005 | Cancel record test | Bam Cancel neu UI co action | Status doi Cancelled | Untested | |
| OT-006 | Delete UI archive | Bam Delete record test | Record bi archive/khong con hien | Untested | Chi record test |

## Incoming School Transfer

| ID | Test case | Cach test | Expected result | Result | Note |
| --- | --- | --- | --- | --- | --- |
| IT-001 | View list | Mo Incoming Transfer | Hien list chuyen den tu backend | Untested | |
| IT-002 | View detail | Bam vao record | Hien student/previous school/status | Untested | |
| IT-003 | Create record test | Tao record chuyen den test | Record moi hien trong list | Untested | |
| IT-004 | Update record test | Sua previous school/note/date | Cap nhat thanh cong | Untested | |
| IT-005 | Cancel record test | Bam Cancel neu UI co action | Status doi Cancelled | Untested | |
| IT-006 | Delete UI archive | Bam Delete record test | Record bi archive/khong con hien | Untested | Chi record test |

## Ket Luan Manual Test

Sau khi test xong, ghi tom tat:

```text
Tester:
Device/emulator:
Ngay test:
Backend:
Tong pass:
Tong fail:
Bug/blocker:
Ghi chu:
```

## Regression Gate Sau Manual Test

Chay lai:

```powershell
flutter analyze
flutter test
```

Neu co model/generated thay doi thi chay them:

```powershell
dart run build_runner build
```
