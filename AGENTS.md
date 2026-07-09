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
