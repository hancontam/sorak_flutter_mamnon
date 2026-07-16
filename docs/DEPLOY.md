# Deploy và chạy live

## Live API (mặc định app)

```text
http://103.69.191.210:8082/api
```

`AppConfig` mặc định `USE_MOCK_API=false` và `API_BASE_URL` trỏ server trên.  
Tài khoản demo lấy từ seed backend / password manager cục bộ — **không** commit mật khẩu.

## Chạy trên thiết bị (live)

```powershell
flutter pub get
flutter run
```

IDE: run configuration `main.dart` (live mặc định theo `AppConfig`).

Chỉ bật mock khi cần offline:

```powershell
flutter run --dart-define=USE_MOCK_API=true
```

## Build APK (debug preview, live)

```powershell
flutter build apk --debug
```

File: `build/app/outputs/flutter-apk/app-debug.apk`

> APK debug chỉ dùng demo/nộp nội bộ, không phát hành production.

## GitHub Actions

Workflow: `.github/workflows/flutter_ci.yml`

1. `flutter pub get`  
2. `flutter analyze`  
3. `flutter test` (mock qua test bootstrap)  
4. Build APK debug (mặc định live)  
5. Upload artifact: `sorak-flutter-live-debug-apk`  

Cách tải: tab **Actions** → workflow **Flutter CI** → artifact cuối job.

## Checklist smoke live (ngắn)

1. Login staff  
2. Chọn năm học  
3. Mở list học sinh / lớp  
4. Mở Sức khỏe → chọn lớp → xem roster  
5. (Principal) mở tài khoản / chuyển lớp  
6. Login parent → xem báo cáo trẻ  
