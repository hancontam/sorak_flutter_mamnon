# Kiểm thử

## Chiến lược

- **App mặc định live API** (`flutter run`). Test tự động **không** dùng live.
- **Automated:** `flutter test` ép **mock API** qua `test/flutter_test_config.dart` — UI flow, provider, navigation, CRUD, archive, health roster.
- **Contract adapter:** `test/functional/live_api_contract_functional_test.dart` (khi `USE_MOCK_API=false`) kiểm tra path/body repository bằng adapter, không phụ thuộc server.
- **Manual live:** `flutter run` rồi login smoke trên thiết bị/emulator.

## Chạy test mock

```powershell
flutter test
```

## Chạy contract (adapter, không phụ thuộc server)

```powershell
flutter test --dart-define=USE_MOCK_API=false test/functional/live_api_contract_functional_test.dart
```

## Fixture mock

Nguồn data: `lib/core/network/mock_api_backend.dart`

- Envelope `{success, data, meta}` thống nhất  
- ID theo dải (year 101+, teacher 201+, class 301+, student 401+, …)  
- Session mock: `ApiClient.configureMockSession(role:, accountId:)`  

Helpers test: `test/functional/helpers/` (`test_app.dart`, `test_data.dart`).

## Phạm vi functional test

- Authentication  
- Home / navigation theo role  
- CRUD modules (năm học, lớp, cán bộ, học sinh, tài khoản)  
- Transfer (lớp / đi / đến)  
- Health roster + history  
- Parent portal  
- Cookie session / refresh  

## Gate trước khi nộp / merge

```powershell
flutter analyze
flutter test
```
