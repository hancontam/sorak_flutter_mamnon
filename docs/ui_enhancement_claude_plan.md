# Sorak Flutter Claude UI Enhancement Handoff

## 1. Mục Tiêu Và Ranh Giới

Thiết kế lại toàn bộ presentation layer theo Claude light theme, Material 3 và font Montserrat. Flow API và nghiệp vụ giữ nguyên.

Được phép sửa:

- `pubspec.yaml`
- `lib/app.dart`
- `lib/core/theme/**`
- `lib/core/widgets/**`
- `lib/core/utils/ui_labels.dart`
- `lib/modules/**/screens/**`
- UI-only widgets trong `lib/modules/**/widgets/**`
- Widget/functional tests và tài liệu `docs/**`

Cấm sửa:

- `lib/core/network/**`
- `lib/core/providers/**`
- `lib/core/repositories/**`
- `lib/modules/**/providers/**`
- `lib/modules/**/repositories/**`
- `lib/modules/**/models/**`
- `lib/core/network/mock_api_backend.dart`
- File generated `.g.dart`
- Endpoint, DTO, request body, query hoặc backend enum

Sau mỗi cụm goal phải kiểm tra `git diff --name-only`. Nếu xuất hiện file cấm, dừng và hoàn tác riêng phần thay đổi đó.

## 2. Context Bắt Buộc

Ảnh tham khảo được lưu tại:

- `docs/design/claude-theme-overview.png`
- `docs/design/claude-theme-components.png`

`AGENTS.md` và `CLAUDE.md` phải ghi rõ:

- Claude light theme bắt buộc.
- Montserrat, radius `8px`, padding `16px`.
- Semantic state chỉ dùng Claude palette.
- Lucide outline toàn app.
- Role không có quyền thì bỏ tab, không thay bằng tab khác.
- Parent không có BottomNav.
- Không chỉnh API/provider/repository/model/mock.

## 3. Design System Đã Khóa

Claude tokens:

| Token | Color |
| --- | --- |
| `background/card` | `#FAF9F5` |
| `foreground` | `#3D3929` |
| `cardForeground/destructive` | `#141413` |
| `primary/ring` | `#C96442` |
| `primaryForeground` | `#FFFFFF` |
| `secondary/accent` | `#E9E6DC` |
| `secondaryForeground` | `#535146` |
| `muted` | `#EDE9DE` |
| `mutedForeground` | `#83827D` |
| `border` | `#DAD9D4` |
| `input` | `#B4B2A7` |
| `popover` | `#FFFFFF` |
| `drawer` | `#F5F4EE` |
| `chart1` | `#B05730` |
| `chart2` | `#9C87F5` |
| `chartNeutral` | `#DED8C4` |

Radius toàn app: `8px`. Không sử dụng lại xanh success, vàng warning hoặc đỏ error hiện tại.

Semantic state:

| State | Text | Background | Border |
| --- | --- | --- | --- |
| Success/Active/Approved/Completed | `#3D3929` | `#E9E6DC` | `#B4B2A7` |
| Pending/Warning | `#B05730` | `#DED8C4` | `#C96442` |
| Error/Rejected/Archived/Delete | `#FFFFFF` | `#141413` | `#141413` |
| Neutral/Inactive | `#535146` | `#EDE9DE` | `#DAD9D4` |

`AppColors.success`, `AppColors.warning`, `AppColors.error` chỉ là compatibility aliases đến Claude token, không giữ màu cũ.

Component rules:

- Font `GoogleFonts.montserratTextTheme()`.
- Card/Input/Dialog/Button radius `8px`.
- Padding chuẩn `16px`; khoảng nhỏ `8px/12px`.
- FilledButton cao tối thiểu `48px`.
- Delete/Archive button nền `#141413`.
- Card elevation `0`, border mảnh; không gradient hoặc shadow nặng.
- Lottie chỉ cho loading, empty, success.

## 4. Component Reference Mapping

Drawer bám HeroUI Drawer:

- Slide trái, scrim, header DiceBear, body cuộn.
- Item cao `48px`, Lucide `20-22px`, gap `12px`.
- Selected background `#E9E6DC`.
- Chia nhóm nghiệp vụ, cá nhân và session bằng divider.
- Đăng xuất nằm cuối với destructive foreground.

BottomNav bám Modern Mobile Menu, Telegram và Material 3:

- Dùng `NavigationBar`, flat background, top border.
- Không dùng selected pill lớn.
- Selected icon/label `#C96442`; unselected `#83827D`.
- Icon luôn outline; selected chỉ đổi màu và scale nhẹ `180ms`.
- Số tab động theo role, chia đều chiều rộng.

Toggle bám Group Toggle:

- Shared `SorakToggleGroup<T>`.
- Segment nằm trong một border chung, radius ngoài `8px`.
- Selected dùng primary hoặc accent Claude.
- Dùng cho login role, Accounts, Health và Transfer filters.

Năm học bám Accordion 2:

- Shared `AcademicYearAccordion`.
- Trigger hiển thị năm hiện tại và Lucide `ChevronDown`.
- Mở inline bằng `AnimatedSize` `200ms`.
- Row được chọn dùng accent background và Check icon.
- Chỉ gọi `ActiveAcademicYearProvider.selectYear()` hiện tại.

Material 3:

- State layer pressed/focused/disabled.
- Touch target tối thiểu `48px`.
- Tooltip và semantics cho icon-only action.
- Không tự dựng gesture thay cho component Material chuẩn.

## 5. Navigation Quyết Định Hoàn Chỉnh

Principal BottomNav:

1. Năm học -> `AcademicYearListScreen`
2. Học sinh -> `StudentListScreen`
3. Cán bộ -> `TeacherListScreen`
4. Lớp học -> `ClassListScreen`

Teacher BottomNav:

1. Học sinh -> `StudentListScreen`
2. Lớp học -> `ClassListScreen`

Teacher chỉ có hai tab trong tập tab Principal. Không thêm Chuyển lớp hoặc Sức khỏe để lấp chỗ trống.

Parent:

- Không render BottomNav.
- Body mặc định: `ParentPortalScreen` dạng “Báo cáo của trẻ”.
- AppBar và Drawer vẫn tồn tại.

Drawer Principal:

- Tài khoản học sinh -> `/student-accounts`
- Tài khoản cán bộ -> `/staff-accounts`
- Chuyển lớp -> `/class-transfers`
- Chuyển trường đến -> `/incoming-transfers`
- Chuyển trường đi -> `/outgoing-transfers`
- Đánh giá sức khỏe -> `/health`
- Xem đánh giá sức khỏe -> `/health-assessments`
- Hồ sơ -> `/profile`
- Cài đặt -> `/settings`
- Đăng xuất

Drawer Teacher:

- Chuyển lớp
- Chuyển trường đến
- Chuyển trường đi
- Đánh giá sức khỏe
- Xem đánh giá sức khỏe
- Hồ sơ
- Cài đặt
- Đăng xuất

Drawer Parent:

- Hồ sơ
- Cài đặt
- Đăng xuất

Drawer lọc item trước khi render. Không hiển thị item trái quyền rồi chờ RoleGuard chặn.

## 6. UI-only Interfaces

- `enum AccountView { student, staff }`
- `AccountListScreen(initialView: AccountView.staff)`
- `/student-accounts` và `/staff-accounts`
- Giữ `/accounts` làm alias mở staff view.
- `SorakAvatar({required Object seed, double size = 48})`
- `SorakToggleGroup<T>`
- `AcademicYearAccordion`
- `SorakStatusBadge`
- `UiLabels.role/status/gender/workStatus`

DiceBear:

```text
https://api.dicebear.com/10.x/pixel-art/svg?seed=account-{accountId}
```

Không dùng họ tên/email làm seed. SVG lỗi phải fallback sang chữ cái đầu.

## 7. Goal Thực Thi

Goal 51 - Persist Context:

- Tạo plan doc và lưu hai ảnh tham khảo.
- Cập nhật `AGENTS.md`, `CLAUDE.md`.
- Chưa sửa UI trong goal này.
- Commit: `docs: lock Claude UI enhancement context`.

Goal 52 - Dependencies & Theme Tokens:

- Thêm `lucide_icons_flutter: ^3.1.14+2`, `flutter_svg: ^2.3.0`.
- Đổi `AppColors`, `AppSpacing`, `AppTheme`.
- Chuyển Poppins sang Montserrat.
- Theme hóa Material 3 button/card/input/dialog/chip/snackbar.
- Thêm theme test kiểm tra font, màu, radius và destructive button.

Goal 53 - Shared Components:

- Tạo `SorakAvatar`, `SorakToggleGroup`, `SorakStatusBadge`.
- Tạo `AcademicYearAccordion`.
- Restyle Loading/Empty/Error/Success và confirmation dialog.
- Thêm widget test cho fallback avatar, toggle selection và accordion open/close.

Goal 54 - AppShell Bottom Navigation:

- Bỏ Home khỏi destination list nhưng không xóa `HomeScreen`.
- Principal render 4 tab; Teacher 2 tab; Parent 0 tab.
- NavigationBar flat kiểu Telegram/Modern Mobile Menu.
- Giữ key: `nav_academic_years`, `nav_students`, `nav_teachers`, `nav_classes`.
- Không gọi provider mới trong navigation.

Goal 55 - HeroUI Drawer:

- Rebuild Drawer layout theo reference.
- Header dùng DiceBear avatar, tên và `UiLabels.role`.
- Render đúng item theo role.
- Thêm stable key riêng cho mọi Drawer item.
- Test Principal/Teacher/Parent visibility và logout.

Goal 56 - Global Year Accordion:

- Bỏ `_ActiveYearDropdown` khỏi AppBar.
- Đặt accordion dưới AppBar cho Principal/Teacher.
- Parent không render selector.
- Loading, empty và selected state dùng Claude visual.
- Test chọn năm vẫn thay `selectedYearId` và reload flow cũ.

Goal 57 - Account Routes & Toggle:

- Tạo `AccountView` và initial view.
- Tạo hai route account.
- Đổi text “Tài khoản phụ huynh” thành “Tài khoản học sinh”.
- Dùng `SorakToggleGroup` cho staff/student và filters.
- Không sửa AccountProvider/Repository.

Goal 58 - Login UI:

- Restyle login theo Claude form reference.
- Toggle “Cán bộ / Phụ huynh” dùng `SorakToggleGroup`.
- Filled login button primary, radius `8px`.
- Dùng Lucide Eye/EyeOff/LogIn.
- Giữ nguyên submit/auth logic và validation.

Goal 59 - Principal Core Tabs:

- Enhance Năm học, Học sinh, Cán bộ, Lớp học.
- Khi embedded trong AppShell, màn tab không render AppBar thứ hai.
- Khi mở bằng named route, vẫn có AppBar/back button.
- Đồng bộ list card, search, filter, FAB, form và detail.
- Giữ nguyên CRUD/archive callbacks.

Goal 60 - Transfer UI:

- Enhance ba transfer module.
- Card làm rõ trẻ, nguồn, đích, ngày, trạng thái.
- Dùng Claude status scheme cho approve/pending/reject/cancel.
- Delete/Archive dùng destructive black.
- Không sửa action/status contract.

Goal 61 - Health UI:

- `/health` là quick-entry roster.
- `/health-assessments` là lịch sử đánh giá.
- Restyle segmented control bằng `SorakToggleGroup`.
- Restyle roster, preview, sticky Save và validation.
- Nutrition/Growth giữ code nhưng không tạo Drawer item riêng.
- Không sửa health provider/repository.

Goal 62 - Parent Report:

- Parent chỉ thấy “Báo cáo của trẻ”.
- Hiển thị DiceBear avatar, họ tên, mã trẻ, lớp, năm học và trạng thái từ `/auth/me`.
- Có ghi chú read-only liên hệ nhà trường.
- Không render Health/Growth/unavailable API card.
- Giữ source code unsupported để dùng lại sau này.

Goal 63 - Vietnamese Presentation Audit:

Dịch toàn bộ text còn lại:

- `Profile` -> `Hồ sơ`
- `Account` -> `Tài khoản`
- `Role` -> `Vai trò`
- `Phone` -> `Số điện thoại`
- `Gender` -> `Giới tính`
- `Status` -> `Trạng thái`
- `Reason` -> `Lý do`
- `Note` -> `Ghi chú`
- `Refresh` -> `Làm mới`
- `Previous school` -> `Trường chuyển đến từ`
- `Destination school` -> `Trường chuyển đến`
- `Transfer date` -> `Ngày chuyển trường`
- `Teacher` -> `Giáo viên phụ trách`
- `Work status` -> `Trạng thái công tác`

Raw backend values chỉ được dịch lúc render.

Goal 64 - Lucide Migration:

- Thay user-visible Material icon reference bằng Lucide outline.
- Selected navigation vẫn dùng outline.
- Kích thước chuẩn `18/20/22/24`.
- Tooltip cho refresh, edit, delete, menu, password visibility.
- Chạy audit `rg "Icons\\." lib`; mọi phần còn lại phải có ghi chú fallback.

Goal 65 - Responsive & Accessibility:

- Test `360x640`, `400x900`, text scale `1.3/2.0`.
- Teacher BottomNav hai tab phải cân đối.
- Drawer và accordion phải cuộn được.
- Không double AppBar, overflow hoặc nội dung bị BottomNav che.
- Touch target `48px`.
- Kiểm tra contrast cho bốn semantic schemes.

Goal 66 - Functional UI Regression:

- Cập nhật tests bỏ `nav_home`, `nav_transfers`, `nav_health` khỏi Principal/Teacher BottomNav cũ.
- Test Principal 4 tab, Teacher 2 tab, Parent không NavigationBar.
- Test Drawer theo role.
- Test account routes mở đúng view.
- Test Parent không thấy unsupported content.
- Test delete visual black nhưng callback archive không đổi.
- Chạy live contract test để chứng minh API contract không bị ảnh hưởng.

Goal 67 - Android Visual Verification & Commit:

- Chạy `dart run build_runner build`.
- Chạy `flutter analyze`.
- Chạy toàn bộ `flutter test`.
- Chạy live contract tests.
- Build APK debug.
- Chụp Principal, Teacher, Parent tại `360x640` và `400x900` nếu emulator/device sẵn sàng.
- Kiểm tra login, Drawer, BottomNav, accordion, form, transfer, health và Parent Report.
- Commit UI changes; tuyệt đối không stage `mcps/`.

## 8. Acceptance Criteria

- Không có diff trong forbidden paths.
- Claude palette áp dụng cho brand lẫn semantic state.
- Delete/Archive dùng `#141413`, không dùng đỏ.
- Montserrat và radius `8px` toàn app.
- Principal 4 tab, Teacher 2 tab, Parent không BottomNav.
- Không cố fill tab theo role.
- Bốn component reference được thể hiện và có widget test.
- Không còn visible English text đã liệt kê.
- Không còn user-visible Material icon ngoài fallback được ghi chú.
- Parent không thấy tính năng backend chưa hỗ trợ.
- Provider/API/repository/mock behavior giữ nguyên.
- Analyze, functional tests, live contract và debug APK đều pass.

## Reference Links

- Claude theme: <https://21st.dev/@serafim/themes/claude>
- HeroUI Drawer: <https://21st.dev/@hero_ui/components/heroui-drawer/navigation-drawer>
- Modern Mobile Menu: <https://21st.dev/@easemize/components/modern-mobile-menu>
- Group Toggle: <https://21st.dev/@micka_design/components/switch/group-toggle>
- Accordion 2: <https://21st.dev/@educalvolpz/components/accordion-2>
- Material 3 Components: <https://m3.material.io/components>
