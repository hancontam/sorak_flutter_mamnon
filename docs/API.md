# API

## Base

- Prefix: `/api`
- Live demo: `http://103.69.191.210:8082/api`
- Envelope thành công:

```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

- Envelope lỗi:

```json
{
  "success": false,
  "message": "...",
  "errors": {},
  "traceId": "..."
}
```

## Auth (cookie)

| Method | Path | Mô tả |
| --- | --- | --- |
| POST | `/auth/login` | Cán bộ: `email`, `password` |
| POST | `/auth/parent-login` | Phụ huynh: `student_id_card_number`, `password` |
| GET | `/auth/me` | Profile phiên hiện tại |
| POST | `/auth/refresh` | Làm mới access (cookie refresh) |
| POST | `/auth/logout` | Đăng xuất |
| POST | `/auth/change-password` | Đổi mật khẩu |

## Tài nguyên chính

| Module | Base path | Ghi chú |
| --- | --- | --- |
| Năm học | `/academic-years` | List không pagination filter phức tạp |
| Lớp | `/classes` | Filter theo `school_year_id` |
| Cán bộ | `/teachers` | Hồ sơ GV |
| Học sinh | `/students` | Theo năm / lớp |
| Tài khoản | `/accounts` | Staff + parent actions |
| Chuyển lớp | `/class-transfers` | approve / reject / cancel / revert |
| Chuyển trường đi | `/outgoing-transfers` | cancel + archive |
| Chuyển trường đến | `/incoming-transfers` | cancel + archive |
| Sức khỏe | `/health-assessments` | list, by-class-date, bulk, history, latest |
| PH lịch sử SK | `/parent/health-history` | Parent only |

## Health endpoints dùng trong app

| Method | Path | Mục đích |
| --- | --- | --- |
| GET | `/health-assessments/by-class-date` | Roster theo lớp + ngày |
| POST | `/health-assessments/bulk` | Lưu nhanh roster |
| GET | `/health-assessments?latest=true` | Đánh giá mới nhất từng học sinh |
| GET | `/health-assessments/history` | Lịch sử theo `student_id` |
| GET/POST/PATCH/DELETE | `/health-assessments` | CRUD đơn lẻ (list/detail form) |

## Query list (chung)

Khi backend hỗ trợ pagination: `page`, `pageSize`, `search`, `sortBy`, `sortOrder`.

Academic years: list theo contract backend (không bắt buộc gửi filter).

## Mock

`lib/core/network/mock_api_backend.dart` cung cấp fixture canonical:

- Year id: 101+
- Teacher: 201+
- Class: 301+
- Student: 401+
- Transfer: 501+
- Account: 1001+
- Health assessment: 601+

Mọi response mock trả envelope `{success, data, meta}` giống live.
