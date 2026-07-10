# CONTEXT DU AN SORAK FLUTTER

## Project Style

- Bam sat PRM393: code don gian, de doc, de giai thich cho newbie.
- Bam sat boilerplate va cach chia folder trong repo thay `voldedore/su26-se1816-prm393`.
- Uu tien code ro rang hon code ngan gon/phuc tap.
- Khong them abstraction neu module hien tai chua can.

## State, API, Storage

- State management: `Provider` + `ChangeNotifier`.
- API: dung `Dio` thong qua `ApiClient`.
- Local storage: dung `SharedPreferences` thong qua `LocalStorage`.
- Mock API truoc trong repository, sau do moi noi endpoint that tu backend.
- Model JSON phai dung `json_serializable` + generated file `.g.dart`.
- Khong viet `fromJson` / `toJson` thu cong cho model API.
- Sau khi tao/sua model co generated code, chay:

```powershell
dart run build_runner build
```

## Folder Structure

Moi module nam trong:

```text
lib/modules/[module_name]/
  models/
  providers/
  repositories/
  screens/
  widgets/
```

Core dung chung nam trong:

```text
lib/core/
  constants/
  network/
  storage/
  widgets/
```

## Module Coding Flow

Moi module nen lam theo thu tu:

```text
model -> repository -> provider -> screen
```

Cu the:

1. Tao model bang `json_annotation`, `part '[file_name].g.dart'`, va generated `fromJson` / `toJson`.
2. Chay `dart run build_runner build`.
3. Tao repository, ban dau dung mock data.
4. Tao provider ke thua `ChangeNotifier`.
5. Tao list screen truoc.
6. Them form create/update.
7. Them detail screen neu can.
8. Them Delete UI nhung goi archive/soft delete.
9. Doi repository tu mock sang Dio API that.
10. Chay `flutter analyze` va `flutter test`.

## Archive Rule

- Tren UI hien thi nut/text `Delete`.
- Trong code dat method nghiep vu la `archive` neu phu hop.
- Khi noi backend, thao tac Delete UI phai goi endpoint archive/soft delete cua backend, thuong la:

```text
DELETE /api/[resource]/:id
```

- Khong hard delete data o Flutter.

## API Context

- Backend: `https://github.com/toanthienla/sorak-mamnonhontre`.
- API prefix: `/api`.
- Response shape:

```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

## Reference Rule

Neu khong ro luong nghiep vu, field, status, role, hoac endpoint cua feature nao, phai tham khao repo backend/web truoc khi code:

- API/backend: `sorak-api/src/routes`, `sorak-api/src/controllers`, `sorak-api/src/services`, `sorak-api/src/validators`.
- Web UI/reference flow: `sorak-web/src/features`, `sorak-web/src/shared/api`, `sorak-web/src/shared/stores`.
- Uu tien doc route va validator de biet endpoint + request body.
- Uu tien doc web feature tuong ung de hieu man hinh, action, filter, status, va luong nguoi dung.
- Khong doan endpoint neu co the kiem tra trong repo.

## Modules Scope

Can lam cac module:

- Authentication
- Accounts Management
- Academic Year Management
- Classes Management
- Teachers Management
- Students Management
- Class Transfer
- Outgoing School Transfer
- Incoming School Transfer

## Not In Scope

- Khong lam Excel import/export trong Flutter app nay.

## Functional Test Context

- Test theo muc chuc nang, khong viet unit test qua chi tiet cho tung ham nho.
- Uu tien automated test bang `flutter test` voi mock API de test UI flow, provider state, navigation, CRUD co ban, va archive behavior.
- Live API/DB that chi dung cho manual smoke test vi phu thuoc backend, session, role, va du lieu that.
- Backend live hien tai:

```text
http://103.69.191.210:8082/api
```

- Tai khoan test can bo:

```text
Email: phanthihoa@edu.vn
Password: Hoa@12345
```

- Cac module can co functional test:
  - Authentication
  - Home navigation
  - Accounts Management
  - Academic Year Management
  - Classes Management
  - Teachers Management
  - Students Management
  - Class Transfer
  - Outgoing School Transfer
  - Incoming School Transfer
- Test Archive rule: UI hien thi Delete, nhung code/backend flow phai la archive/soft delete.
- Manual test quan trong: login live API, list/detail/create/update/archive tung module, va transfer flow tren du lieu test.
- Lenh regression gate sau khi them/sua test:

```powershell
dart run build_runner build
flutter analyze
flutter test
```

- Nen thuc hien test theo tung goal nho:
  1. Tao nen automated functional test.
  2. Test Authentication.
  3. Test Home va Navigation.
  4. Test CRUD module co ban.
  5. Test Transfer module.
  6. Manual Live API checklist.
  7. Regression gate va ghi nhan ket qua.

## UI Design System Context

Design system Sorak Mam Non Flutter da lock:

- Material 3.
- Font toan app: `Poppins` bang `google_fonts`.
- Primary: `#1a2845`.
- Accent: `#f5a623`.
- Background: `#ffffff`.
- Text dark: `#111827`.
- Text gray: `#64748b`.
- Success: `#4ade80`.
- Error: `#ef4444`.
- Card radius: `16`.
- Padding chung: `16`.
- Padding nho ben trong: `8` hoac `12`.
- Button chinh: `FilledButton`.
- Button phu: `OutlinedButton` hoac `TextButton`.
- Card: flat, elevation `0` hoac rat nhe.
- List don gian: `ListTile`.
- Nhom noi dung: `ListTile` nam trong `Card`.
- Khong lam UI loe loet; uu tien sach se, than thien, de bam tren mobile.

Nen tao shared theme/widgets:

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_theme.dart
lib/core/widgets/app_shell.dart
lib/core/widgets/app_search_bar.dart
lib/core/widgets/filter_chip_row.dart
lib/core/widgets/status_chip.dart
lib/core/widgets/module_list_card.dart
lib/core/widgets/loading_state.dart
lib/core/widgets/empty_state.dart
lib/core/widgets/error_state.dart
lib/core/widgets/confirm_archive_dialog.dart
```

## Navigation And Screen Flow Context

App shell sau login dung:

- `NavigationBar` Material 3 o bottom, toi da 5 tab.
- `NavigationDrawer` Material 3 cho menu phu/admin.
- Bottom navigation chi chua cac viec dung hang ngay.
- Drawer chua cac muc phu/admin, settings, profile, logout.
- Navigation phai role-based theo web `sorak-web`:
  - `PRINCIPAL`: web co Dashboard, Accounts, Teachers, Classes, Students, Transfers, Health, Growth. Mobile uu tien tab hay dung, dua muc admin/phu vao Drawer.
  - `TEACHER`: web co Dashboard, Classes, Students, Transfers, Health, Growth; khong co Accounts/Teachers management.
  - `PARENT`: web di vao `/portal` rieng, view-only thong tin hoc sinh/phu huynh. Mobile dung portal gon, view-only, tap trung Child, Growth, Health.
- `Manual Tests` khong duoc hien trong Drawer nguoi dung.

Bottom `NavigationBar` role-based da chot:

Principal/Admin:

1. `Home`
2. `Students`
3. `Classes`
4. `Transfers`
5. `Health`

Teacher:

1. `Home`
2. `Classes`
3. `Students`
4. `Transfers`
5. `Health`

Parent:

1. `Child`
2. `Growth`
3. `Health`

Drawer role-based da chot:

- Header: avatar chu cai dau, full name, role.
- Principal/Admin: `Academic Years`, `Accounts`, `Teachers`, `Growth`, `Profile`, `Settings`, `Logout`.
- Teacher: `Growth`, `Profile`, `Settings`, `Logout`.
- Parent: `Profile`, `Settings`, `Logout`.
- Khong hien `Manual Tests`.

Flow tong quat:

```text
Splash / Session Check
 -> Login
 -> AppShell
    -> PRINCIPAL: Home, Students, Classes, Transfers, Health
       -> Drawer: Academic Years, Accounts, Teachers, Growth, Profile, Settings, Logout
    -> TEACHER: Home, Classes, Students, Transfers, Health
       -> Drawer: Growth, Profile, Settings, Logout
    -> PARENT: Child, Growth, Health
       -> Drawer: Profile, Settings, Logout
```

Module screen flow:

```text
AcademicYearListScreen
 -> AcademicYearDetailScreen
 -> AcademicYearFormScreen(create/update)
 -> Confirm Delete -> archive
 -> Activate action

StudentListScreen
 -> StudentDetailScreen
 -> StudentFormScreen(create/update)
 -> Confirm Delete -> archive

TeacherListScreen
 -> TeacherDetailScreen
 -> TeacherFormScreen(create/update)
 -> Confirm Delete -> archive

ClassListScreen
 -> ClassDetailScreen
 -> ClassFormScreen(create/update)
 -> Confirm Delete -> archive

AccountListScreen
 -> AccountDetailScreen
 -> AccountFormScreen(create/update)
 -> Confirm Delete -> archive

TransfersScreen
 -> SegmentedButton or TabBar: Class / Outgoing / Incoming
 -> ClassTransferListScreen
 -> OutgoingTransferListScreen
 -> IncomingTransferListScreen

HealthScreen
 -> SegmentedButton or TabBar: Health / Nutrition / Growth
 -> Health quick entry / list
 -> Nutrition quick entry / list
 -> Growth WHO summary/chart placeholder until module is implemented

ParentPortalScreen
 -> Child overview
 -> Health status
 -> Growth WHO view-only
```

Transfer flow:

```text
ClassTransferListScreen
 -> ClassTransferDetailScreen
 -> ClassTransferFormScreen(create/update)
 -> Approve / Reject / Cancel

OutgoingTransferListScreen
 -> OutgoingTransferDetailScreen
 -> OutgoingTransferFormScreen(create/update)
 -> Cancel / Delete archive

IncomingTransferListScreen
 -> IncomingTransferDetailScreen
 -> IncomingTransferFormScreen(create/update)
 -> Cancel / Delete archive
```

## List, State, And Animation UX Context

List UI tren mobile:

- Mac dinh dung `Card + ListTile`.
- Moi item co title, subtitle 1-2 dong, status chip/trailing action.
- Khong dung `DataTable` cho mobile nho neu khong that su can.
- Chi dung `DataTable` cho tablet/web/landscape hoac khi admin can so sanh nhieu cot.

Moi list screen nen co:

- `SearchBar` hoac search field o dau list.
- `FilterChip` row cho status/role/class/academic year neu phu hop.
- `FloatingActionButton` icon add de tao moi.
- `Refresh` action tren AppBar neu can.
- Empty state ro rang va CTA tao moi neu co quyen.
- Loading state ro rang.
- Error state co nut Retry.

UX buttons:

- Save/Create: `FilledButton`.
- Cancel/Back: `OutlinedButton`.
- Delete tren UI: nut/icon Delete, nhung goi archive/soft delete.
- Destructive confirm dung mau error `#ef4444`.
- Success sau create/update/archive: uu tien `SnackBar`.

Lottie:

- Chi dung Lottie cho loading, success, empty state.
- Khong dung Lottie cho moi transition man hinh.
- Asset goi y:

```text
assets/lottie/loading.json
assets/lottie/empty.json
assets/lottie/success.json
```

- Them dependency `lottie`.
- Khi can tai animation mien phi, dung LottieFiles free animation va giu style nhe nhang.
- Khong loe loet, khong animation qua lon; kich thuoc khoang 120-160px la du.

## Project Goal

Hoan thanh Sorak Mam Non Flutter Mobile theo context trong file nay.

Thu tu milestone:

1. Core Foundation.
2. Authentication hoan thien.
3. Academic Year Management.
4. Classes Management.
5. Teachers Management.
6. Students Management.
7. Accounts Management.
8. Class Transfer.
9. Outgoing School Transfer.
10. Incoming School Transfer.
11. Noi API that tu backend `https://github.com/toanthienla/sorak-mamnonhontre`.
12. Polish UI, cleanup, test.

Sau moi milestone:

- Chay `dart run build_runner build` neu co model/generated thay doi.
- Chay `flutter analyze`.
- Chay `flutter test`.
- Sua loi cho den khi pass.

Definition of Done:

- Project chay duoc bang `flutter run`.
- Cac module co list screen, provider, repository, model generated, va UI thao tac co ban.
- Mock data hoat dong truoc khi noi API that.
- Cac thao tac Delete tren UI goi archive/soft delete theo backend.
- Khong co loi `flutter analyze`.
- `flutter test` pass.

## Web Parity Fix Context

Can bam sat web repo `toanthienla/sorak-mamnonhontre`, dac biet:

```text
sorak-web/src/app/layouts/AppLayout.jsx
sorak-web/src/features/auth/LoginPage.jsx
sorak-web/src/features/accounts
sorak-web/src/features/teachers/TeachersPage.jsx
sorak-web/src/features/classes/ClassesPage.jsx
sorak-web/src/features/students/StudentsPage.jsx
sorak-web/src/features/transfers
sorak-web/src/features/health
sorak-web/src/features/growth
sorak-web/src/shared/components/year-selector.jsx
```

Quy tac wording UI:

- Toan bo text hien thi tren Flutter phai dung tieng Viet co dau nhu web.
- Module parent/child tren mobile dung tu `Trẻ`, khong dung `Con`.
- Parent bottom tab chot: `Trẻ`, `Sức khỏe`, `Tăng trưởng`.
- Drawer/Profile role label:
  - `PRINCIPAL` -> `Ban Giám Hiệu`
  - `TEACHER` -> `Giáo viên`
  - `PARENT` -> `Phụ huynh`
- App label/module label nen dung:
  - `Trang chủ`
  - `Học sinh`
  - `Lớp học`
  - `Chuyển lớp / trường`
  - `Sức khỏe`
  - `Tăng trưởng WHO`
  - `Năm học`
  - `Tài khoản`
  - `Cán bộ`
  - `Hồ sơ`
  - `Cài đặt`
  - `Đăng xuất`

Quy tac form input theo web:

- Khong de nguoi dung nhap string tu do cho field co tap gia tri co dinh.
- Dung `DropdownButtonFormField` hoac `DropdownMenu` cho:
  - role
  - status
  - gender
  - academic year
  - class
  - grade/age group
  - teacher
  - student
  - transfer status
  - nutrition period
  - nutrition status/channel
- Option lay tu Provider/repository. Mock truoc, sau noi API that.
- Neu option phu thuoc nhau thi load theo thu tu:
  - chon nam hoc -> load lop cua nam hoc
  - chon khoi -> filter lop theo khoi
  - chon lop -> load hoc sinh cua lop
  - chon lop hien tai -> filter lop dich cung khoi/cung nam hoc

Option co dinh can dung dung tieng Viet:

```text
Gender student: Nam, Nữ
Gender teacher: Nam, Nữ, Khác
Grade/Age group: Nhà trẻ, Mầm, Chồi, Lá
Teacher work status:
  Đang làm việc
  Chuyển đến
  Đã chuyển đi
  Đã điều động
  Chờ nghỉ hưu
  Đã nghỉ hưu
  Đã biệt phái
  Thôi việc
Student status:
  Đang học
  Chuyển đến kỳ 1
  Nghỉ học xin học lại kỳ 1
  Chuyển đi kỳ 1
  Thôi học kỳ 1
  Chuyển đến kỳ 2
  Nghỉ học xin học lại kỳ 2
  Chuyển đi kỳ 2
  Thôi học kỳ 2
  Chuyển đến trong hè
  Chuyển đi trong hè
  Thôi học trong hè
Staff account role:
  PRINCIPAL -> BGH — Ban Giám Hiệu
  TEACHER -> GV — Giáo viên
Transfer status:
  Pending -> Chờ duyệt
  Approved -> Đã duyệt
  Rejected -> Từ chối
  Cancelled -> Đã hủy
  Expired -> Quá hạn
  Recorded -> Đã ghi nhận
```

Accounts va Teachers phai tach dung nhu web:

- `Teachers` la CRUD ho so can bo/giao vien.
- Tao giao vien trong `Teachers` khong mac dinh tao account dang nhap.
- Giao vien moi tao se hien trong `Accounts` tab can bo voi trang thai `Chưa cấp tài khoản`.
- `Accounts` phai co 2 tab:
  - `Tài khoản cán bộ`
  - `Tài khoản phụ huynh`
- `Tài khoản cán bộ` hien danh sach teacher-centric:
  - teacher co `account == null` -> `Chưa cấp tài khoản`
  - teacher co account -> hien role, active/inactive
  - action: `Cấp tài khoản`, `Đổi vai trò`, `Khóa tài khoản`, `Mở khóa tài khoản`, `Đổi mật khẩu`
- `Tài khoản phụ huynh` hien student-centric:
  - ma the hoc sinh
  - ho ten hoc sinh
  - trang thai hoc sinh
  - trang thai tai khoan phu huynh
  - action: `Khóa/Mở khóa`, `Đổi mật khẩu PH`
- Khong bien Accounts thanh CRUD account don gian nua neu muon giong web.

Academic year selector:

- Web dat `YearSelector` o duoi sidebar, canh user menu/logout.
- Mobile chot dat dropdown nam hoc active tren AppBar/action area, thay vi icon logout ngoai.
- Logout giu trong Drawer/Profile menu, khong dat icon power ngoai AppBar.
- Khi app load, neu chua chon nam hoc thi auto chon nam hoc `active`.
- Cac list/form co lien quan phai doc selected academic year tu provider chung.

Health/Nutrition/Growth flow theo web:

- Health tab khong nen chi la list CRUD roi bam child khong ro luong.
- Staff flow:
  - chon lop
  - chon ngay danh gia hoac giai doan
  - hien roster hoc sinh cua lop
  - nhap nhanh chieu cao/can nang/dinh duong it cham
  - tap hoc sinh de xem preview/history
- Nutrition flow:
  - chon lop
  - chon giai doan
  - tap hoc sinh mo preview tang truong WHO va danh gia dinh duong
- Growth WHO:
  - Principal/Teacher loc theo lop/hoc sinh
  - Parent chi view-only tre cua minh
  - Drawer mo Growth nhu route rieng phai co back button nhu cac screen khac

Live API notes:

- Flutter mac dinh dang chay mock vi `AppConfig.useMockApi` default la `true`.
- Muon chay live API thi dung:

```powershell
flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://103.69.191.210:8082/api
```

- Tai khoan principal test:

```text
phanthihoa@edu.vn / Hoa@12345
```

- Tai khoan teacher test da verify tren live API:

```text
gv01@sorak.local / changeme@123
gv03@sorak.local / changeme@123
gv04@sorak.local / changeme@123
maint@edu.vn / changeme@123
```

Goal planning rule:

- Khong tach goal qua nho chi de doi label/tab.
- Cac viec nho nhu doi `Con` -> `Trẻ` phai gom vao goal AppShell/Parent tuong ung.
- Moi goal nen la mot khoi thay doi co the test duoc, vi du: foundation, AppShell/year selector, Teachers form, Students form, Accounts web flow.
