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
- Mock API qua `MockApiBackend` gan vao Dio `HttpClientAdapter`; mock va live
  phai di chung repository/parser/DTO, khong tra object Dart truc tiep.
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

Nen test hien tai sau Goals 40+:

- Fixture canonical nam trong `lib/core/network/mock_api_backend.dart`.
- Repository khong duoc co `_mockItems` hoac nhanh mock rieng; mock va live
  deu phai goi Dio va dung chung parser.
- Moi fixture phai tra envelope `{success,data,meta}` hoac
  `{success:false,message,errors,traceId}`.
- ID year/teacher/class/student/transfer/account phai tach dai.
- Test role phai kiem tra ca data scope, visibility action, deep-link guard va
  API 403.
- Parent chi lay profile tre tu `/auth/me`; khong fallback mock Health/Growth
  trong live mode.
- Student create tu dong cap Parent account. Password mac dinh theo backend
  hien tai la chinh ma the duoc sinh; khong ghi ma the/password that vao repo.
- Doc `docs/test_plan_after_core_api.md` va
  `docs/functional_defect_inventory.md` truoc khi sua fixture/API.
- Parent read API chua ton tai. Dung contract de xuat trong
  `docs/backend_parent_read_api_contract.md`; khong tu doan endpoint.
- Product owner da xac nhan backend hien tai khong ho tro Parent Health/Growth.
  Day la unavailable state hop le trong pham vi hien tai, khong phai ly do dung
  release. Flutter giu UI chi doc, hien thong bao ro rang va tuyet doi khong
  fallback mock khi `USE_MOCK_API=false`.

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
Password: <nhap tu bien moi truong hoac password manager cuc bo>
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
phanthihoa@edu.vn / <khong luu password trong repo>
```

- Tai khoan teacher test da verify tren live API:

```text
gv01@sorak.local
gv03@sorak.local
gv04@sorak.local
maint@edu.vn
Password: <lay tu seed/password manager cuc bo, khong luu trong repo>
```

Goal planning rule:

- Khong tach goal qua nho chi de doi label/tab.
- Cac viec nho nhu doi `Con` -> `Trẻ` phai gom vao goal AppShell/Parent tuong ung.
- Moi goal nen la mot khoi thay doi co the test duoc, vi du: foundation, AppShell/year selector, Teachers form, Students form, Accounts web flow.

## Goal 33 Current State

- `ActiveAcademicYearProvider` is the sole selected-year state. It persists `selected_academic_year_id` with `LocalStorage`.
- Only `AppShell` presents the global year selector. Do not add another global selector inside a module screen.
- On a change, AppShell must synchronize `FormOptionsProvider`, reload the active role destination, and reset dependent class/student options.
- Live repositories and live create/bulk payloads must receive the selected year. Do not use `school_year_id: 1`, `?? 1`, or any hidden year fallback in a live flow.
- Existing year-aware providers: Class, Student, Teacher, ClassTransfer, IncomingTransfer, OutgoingTransfer, HealthAssessment, NutritionAssessment, and GrowthWho.

## Goals 34-35 API Contract State

- Use `ApiListQuery` and `ApiPage` for new paginated live list calls. The valid common keys are `page`, `pageSize`, `search`, `sortBy`, and `sortOrder`.
- Academic Years is the exception: its current backend validator accepts an empty query only. Do not send pagination or filters there.
- Core `getPage(...)` calls are implemented for Classes, Teachers, Students, and Accounts. Keep `getAll()` only as a compatibility adapter for existing screens.
- Accounts: `assign-role` and `role` use `teacher_id`; active/password/archive use `account_id`; parent active uses `student_id`.
- Class Transfer has no DELETE route. Use status actions `approve`, `reject`, `cancel`, and `revert` on `request_id` with optional `note`.
- Incoming/Outgoing Cancel uses `transfer_id` plus optional `cancel_reason`. Archive is DELETE/soft-delete. The backend has no restore endpoint for school transfers; never fake a successful restore.
- Live contract gate: `flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart`.

## Core API Integration Context (Locked)

Tu Goal 30 tro di, uu tien core API va dung vibe/polish UI cho den khi live API on dinh.

Nguon su that theo thu tu:

1. `sorak-api/src/routes` xac dinh endpoint, method va role.
2. `sorak-api/src/validators` xac dinh body/query hop le.
3. `sorak-api/src/controllers` va `services` xac dinh response va nghiep vu.
4. `sorak-web/src/shared/api/client.js` va feature tuong ung xac dinh auth lifecycle va cach FE goi API.

Khong doan endpoint, body, query parameter, status string hoac response shape. Moi repository live phai co contract doi chieu trong `docs/core_api_integration_handoff.md`.

Auth live cua backend la cookie-based:

- Login tra `sorak_access` (15 phut, path `/`) va `sorak_refresh` (7 ngay, path `/api/auth`) bang `Set-Cookie` httpOnly.
- Web dung `withCredentials: true`, khong luu JWT trong Zustand/localStorage va khong tu gan Bearer.
- Backend chi ho tro Bearer nhu fallback cho Swagger/tool; refresh van bat buoc cookie `sorak_refresh`.
- Flutter dung cookie jar chung cho login/request/refresh/logout. Khong parse access token va khong luu JWT trong SharedPreferences.
- ApiClient da co single-flight refresh, retry dung mot lan, va clear session khi refresh that bai. Khong sua flow nay ma khong cap nhat test 401.
- Khong log token, password, Cookie hoac Set-Cookie.

Academic year la global filter:

- `ActiveAcademicYearProvider` la single source of truth trong toan app.
- Load `/academic-years`, uu tien year co `status == active`, va persist selected id.
- Moi module co `school_year_id` phai doc year tu provider va gui query/body dung contract.
- Khi doi year, module dang mo phai reset filter phu thuoc (class/student), reload data, va khong dung hard-code `school_year_id: 1`.

Health layout:

- Noi dung tab Health phai nam trong `SafeArea` va co bottom scroll padding tinh theo `MediaQuery.padding.bottom` + khoang cach NavigationBar.
- Bottom sheet quick entry phai tinh ca `viewInsets.bottom` va safe-area bottom.
- Kiem tra item cuoi, nut luu va empty/error state khong bi NavigationBar/ban phim che.

Chi tiet handoff, contract va Goal 30+ nam trong:

```text
CLAUDE.md
docs/api_contract_audit.md
docs/core_api_integration_handoff.md
```

## Claude UI Enhancement Context (Locked)

Read `docs/ui_enhancement_claude_plan.md` before changing UI. Current UI work is presentation-only: do not edit API, provider, repository, model, generated files, DTO, endpoint, query/body contract, or `lib/core/network/mock_api_backend.dart`.

Allowed UI scope:

- `pubspec.yaml`
- `lib/app.dart`
- `lib/core/theme/**`
- `lib/core/widgets/**`
- `lib/core/utils/ui_labels.dart`
- `lib/modules/**/screens/**`
- UI-only widgets under `lib/modules/**/widgets/**`
- Widget/functional tests and `docs/**`

Claude light theme is mandatory:

- Font: Montserrat through `google_fonts`.
- Radius: `8px` across cards, dialogs, inputs, buttons and chips.
- Padding: base `16px`, compact `8px` or `12px`.
- Palette:
  - background/card `#FAF9F5`
  - foreground `#3D3929`
  - destructive/cardForeground `#141413`
  - primary/ring `#C96442`
  - primaryForeground `#FFFFFF`
  - secondary/accent `#E9E6DC`
  - secondaryForeground `#535146`
  - muted `#EDE9DE`
  - mutedForeground `#83827D`
  - border `#DAD9D4`
  - input `#B4B2A7`
  - popover `#FFFFFF`
  - drawer `#F5F4EE`
  - chart1 `#B05730`
  - chart2 `#9C87F5`
  - chartNeutral `#DED8C4`

Semantic colors must also use Claude tokens:

- Success/Active/Approved/Completed: text `#3D3929`, background `#E9E6DC`, border `#B4B2A7`.
- Pending/Warning: text `#B05730`, background `#DED8C4`, border `#C96442`.
- Error/Rejected/Archived/Delete: text `#FFFFFF`, background/border `#141413`.
- Neutral/Inactive: text `#535146`, background `#EDE9DE`, border `#DAD9D4`.

Navigation lock:

- Principal BottomNav has exactly 4 tabs: `Năm học`, `Học sinh`, `Cán bộ`, `Lớp học`.
- Teacher BottomNav has exactly 2 tabs: `Học sinh`, `Lớp học`.
- Parent has no BottomNav and lands on `ParentPortalScreen` as `Báo cáo của trẻ`.
- Do not fill missing role tabs with unrelated modules.
- Drawer filters items before render. Principal sees student/staff accounts, transfers, health entry/history, profile, settings, logout. Teacher sees transfers, health entry/history, profile, settings, logout. Parent sees profile, settings, logout.

Component lock:

- Use Lucide outline icons for user-visible icons. Remaining `Icons.*` must be deliberate fallback and documented.
- Drawer follows HeroUI navigation drawer reference.
- Bottom navigation follows Modern Mobile Menu / Telegram style using Material 3 `NavigationBar`.
- Toggle groups use shared `SorakToggleGroup<T>`.
- Global academic year selector uses shared `AcademicYearAccordion`.
- DiceBear pixel-art avatar seed must use stable non-PII account id, not name/email.
- Parent must not show unsupported Health/Growth API cards in live scope.
