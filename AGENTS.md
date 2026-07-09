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
