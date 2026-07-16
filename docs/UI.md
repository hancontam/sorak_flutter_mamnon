# Giao diện (design final)

UI hiện tại là bản chốt sau khi logic/API ổn định.

## Design system

| Token | Giá trị |
| --- | --- |
| Font | Montserrat (`google_fonts`) |
| Primary | `#C96442` |
| Primary foreground | `#FFFFFF` |
| Background / card | `#FAF9F5` |
| Foreground | `#3D3929` |
| Secondary / accent | `#E9E6DC` |
| Muted | `#EDE9DE` |
| Border | `#DAD9D4` |
| Drawer | `#F5F4EE` |
| Radius | 8px |
| Padding | 16 (base), 8–12 (compact) |

### Semantic status

- Success / active: text đậm, nền secondary
- Pending / warning: tông cam nhạt
- Error / rejected / delete: nền tối `#141413`
- Neutral / inactive: muted

## Icon

Lucide outline cho icon người dùng thấy. Material `Icons.*` chỉ dùng khi cần fallback.

## Điều hướng theo vai trò

### Ban Giám Hiệu (PRINCIPAL)

**Bottom navigation (4 tab):**

1. Năm học  
2. Học sinh  
3. Cán bộ  
4. Lớp học  

**Drawer:** tài khoản học sinh/cán bộ, chuyển lớp–trường, sức khỏe (nhập / xem), hồ sơ, cài đặt, đăng xuất.

### Giáo viên (TEACHER)

**Bottom navigation (2 tab):**

1. Học sinh  
2. Lớp học  

**Drawer:** chuyển lớp–trường, sức khỏe, hồ sơ, cài đặt, đăng xuất.

### Phụ huynh (PARENT)

- Không BottomNav  
- Màn chính: **Báo cáo của trẻ** (hồ sơ + lịch sử sức khỏe chỉ xem)  
- Drawer: hồ sơ, cài đặt, đăng xuất  

## Module Sức khỏe

- **Nhập đánh giá:** chọn lớp + ngày → roster học sinh → nhập chiều cao / cân nặng / ghi chú (bulk)  
- **Xem đánh giá:** danh sách học sinh + bản ghi mới nhất / lọc ngày + lịch sử  

## Năm học trên AppBar

Dropdown năm học active trên shell (không icon logout ngoài AppBar). Logout nằm trong Drawer.

## Ảnh demo

Xem `docs/screenshots/` và `docs/design/`.
