# API Contract Audit - Goal 30

Ngày audit: 2026-07-10  
Flutter audit target: thư mục `lib/modules/*/repositories` hiện tại  
Web/API reference commit: `4263240651d4aad8223a592d34c056305e432663`

## Phạm vi và nguồn sự thật

Audit này bao phủ mọi repository Flutter có nhánh live API: Auth, Academic Years, Accounts, Classes, Teachers, Students, Form Options, Class Transfers, Incoming Transfers, Outgoing Transfers, Health Assessments, Nutrition Assessments và Growth WHO.

Thứ tự ưu tiên khi có mâu thuẫn:

1. Backend `sorak-api/src/routes/*.routes.js`: path, method và role.
2. Backend `sorak-api/src/validators/*.schema.js`: query/body hợp lệ.
3. Backend controller/service: nghĩa của ID, response thực tế và business rule.
4. Web feature/API client: flow FE đang được dùng.
5. Flutter hiện tại: chỉ là đối tượng audit, không phải nguồn contract.

Web/API source chính:

- [Web ApiClient](https://github.com/toanthienla/sorak-mamnonhontre/blob/main/sorak-web/src/shared/api/client.js)
- [Backend routes](https://github.com/toanthienla/sorak-mamnonhontre/tree/main/sorak-api/src/routes)
- [Backend validators](https://github.com/toanthienla/sorak-mamnonhontre/tree/main/sorak-api/src/validators)
- [Backend response wrapper](https://github.com/toanthienla/sorak-mamnonhontre/blob/main/sorak-api/src/middlewares/response-wrapper.js)

## Response và pagination chung

`res.success(data)`:

```json
{ "success": true, "data": {} }
```

`res.paginated(result)`:

```json
{
  "success": true,
  "data": [],
  "meta": { "page": 1, "pageSize": 20, "total": 0 }
}
```

List endpoint có pagination phải đọc `data` là list và giữ `meta`; object endpoint đọc `data` là object. Không tự bịa thêm `items`, `rows` hay `data.data` để che mismatch model. Ngoại lệ contract rõ ràng: Health history trả `{ student, records }`, Health bulk trả counters, Nutrition grid trả roster array và Nutrition bulk trả counters.

Query pagination chung: `page`, `pageSize` (1-500), `search`, `sortBy`, `sortOrder` khi schema module cho phép.

## Live read-only verification

Đã kiểm tra trên deploy ngày 2026-07-10 bằng session cán bộ, chỉ đọc status và envelope shape; không ghi token, cookie hoặc dữ liệu cá nhân.

| Endpoint | HTTP | `data` | `meta` |
|---|---:|---|---|
| `/auth/me` | 200 | object | không |
| `/academic-years` | 200 | array | không |
| `/accounts?type=staff&pageSize=1` | 200 | array | có |
| `/classes?pageSize=1` | 200 | array | có |
| `/teachers?pageSize=1` | 200 | array | có |
| `/students?pageSize=1` | 200 | array | có |
| `/class-transfers?pageSize=1` | 200 | array | có |
| `/outgoing-transfers?pageSize=1` | 200 | array | có |
| `/incoming-transfers?pageSize=1` | 200 | array | có |
| `/health-assessments?pageSize=1` | 200 | array | có |
| `/nutrition-assessments/grid-all?school_year_id=1&period=dau_nam` | 200 | array | không |

Kết quả này xác nhận response wrapper trong source đang khớp deploy cho các endpoint read chính.

## Canonical contract

### Auth

| API | Role | ID/query/body | Response | Ghi chú |
|---|---|---|---|---|
| `POST /auth/login` | Public | body: `email`, `password` | `{user}` + 2 Set-Cookie | Staff login |
| `POST /auth/parent-login` | Public | body: `student_id_card_number`, `password` | `{user}` + 2 Set-Cookie | Parent login |
| `POST /auth/refresh` | Public nhưng cần cookie | refresh cookie, body rỗng | `{message}` + access cookie mới | Không nhận Bearer refresh |
| `GET /auth/me` | Principal/Teacher/Parent | access cookie hoặc Bearer fallback | profile object | Dùng để restore session |
| `POST /auth/logout` | Principal/Teacher/Parent | session hiện tại | `{message}` + clear cookies | Flutter vẫn clear local trong `finally` |
| `POST /auth/change-password` | Principal/Teacher/Parent | `old_password`, `new_password` | `{message}` | Password mới tối thiểu 6 |

### Academic Years và Accounts

| API | Role | ID/query/body | Response | Ghi chú |
|---|---|---|---|---|
| `GET /academic-years` | Principal, Teacher | none | list | Không paginated |
| `POST /academic-years` | Principal | `name`, `start_date`, `end_date` | year | |
| `PATCH /academic-years/:school_year_id` | Principal | `name?`, `start_date?`, `end_date?`, `status?` | year | |
| `PATCH /academic-years/:id/activate` | Principal | id = `school_year_id` | year | |
| `POST /academic-years/:id/promote` | Principal | id = `school_year_id` | summary | |
| `DELETE /academic-years/:id`, `POST /:id/restore` | Principal | id = `school_year_id` | year | Soft delete |
| `GET /accounts?type=staff|parent` | Principal | pagination + `role`, `has_role`, `is_active`, `work_status`, `student_status` | paginated list | `type`, không phải `account_type` |
| `POST /accounts/:teacher_id/assign-role` | Principal | body: `role`, `password` | account | ID là `teacher_id` |
| `PATCH /accounts/:teacher_id/role` | Principal | body: `role` | account | Backend service dùng `teacher_id`, dù web comment cũ nói account id |
| `PATCH /accounts/:account_id/active` | Principal | body: `is_active` bool | account | ID là `account_id` |
| `PATCH /accounts/:account_id/password` | Principal | body: `password` | account | ID là `account_id` |
| `PATCH /students/:student_id/active` | Principal | body: `is_active` bool | student | Action tài khoản phụ huynh |

### Classes, Teachers và Students

| API | Role | ID/query/body | Response | Ghi chú |
|---|---|---|---|---|
| `GET /classes` | Principal, Teacher | `school_year_id?`, `age_group?`, pagination/search | paginated list | Teacher chỉ thấy lớp được phân công |
| `POST /classes` | Principal | `class_name`, `school_year_id`, `age_group?`, `room?` | class | Không nhận teacher name/id |
| `PATCH /classes/:class_id` | Principal | `class_name?`, `age_group?`, `room?` | class | Không đổi year qua update |
| `POST /classes/:class_id/teachers` | Principal | body: `account_id` | `{teacher_id,class_id}` | Chỉ thêm giáo viên đã có account |
| `DELETE /classes/:class_id/teachers/:teacher_id` | Principal | path ids | result | Teacher id, không phải account id |
| `DELETE /classes/:id`, `PATCH /:id/restore` | Principal | id = `class_id` | class | Soft delete |
| `GET /teachers` | Principal, Teacher | `school_year_id?`, `is_active?`, `position?`, `role?`, `work_status?`, pagination/search | paginated list | |
| `POST /teachers` | Principal | `full_name`, `email`, `position`, fields hồ sơ tùy chọn | teacher | Tạo hồ sơ, không tự cấp login account |
| `PATCH /teachers/:teacher_id` | Principal | profile fields; `work_status` phải thuộc enum | teacher | |
| `DELETE /teachers/:id`, `PATCH /:id/restore` | Principal | id = `teacher_id` | teacher | Soft delete |
| `GET /students` | Principal, Teacher | `school_year_id?`, `class_id?`, `grade_level?`, `is_active?`, `student_status?`, pagination/search | paginated list | Teacher bị giới hạn lớp được giao |
| `POST /students` | Principal, Teacher | `full_name`, `date_of_birth`, `gender`; có thể `class_id`, `grade_level`, parents | student | `student_id_card_number` do BE tạo |
| `PATCH /students/:student_id` | Principal, Teacher | profile/status fields | student | Không nhận `class_id` hoặc `grade_level`; chuyển lớp dùng API transfer |
| `DELETE /students/:id`, `PATCH /:id/restore` | Principal | id = `student_id` | student | Soft delete |
| `PATCH /students/:id/parents` | Principal, Teacher | `{parents: [...]}` | parents | Tối đa 2; route batch update |

### Transfers

| API | Role | ID/query/body | Response | Ghi chú |
|---|---|---|---|---|
| `GET /class-transfers` | Principal, Teacher | `school_year_id?`, `class_id?`, `student_id?`, `status?`, pagination/search | paginated list | |
| `POST /class-transfers` | Principal, Teacher | `student_id`, `to_class_id`, `reason`, `effective_date` | transfer | Không nhận `status`, `from_class_id`, `school_year_id` |
| `PATCH /class-transfers/:transfer_id/status` | Principal, Teacher | `{action: approve|reject|cancel|revert, note?}` | transfer | Không phải generic update/archive |
| `GET /outgoing-transfers`, `GET /incoming-transfers` | Principal, Teacher | `school_year_id?`, `class_id?`, `student_id?`, `status?`, pagination/search | paginated list | status chỉ `Recorded|Cancelled` |
| `POST /outgoing-transfers` | Principal | `student_id`, `school_year_id?`, `destination_school`, `transfer_date`, `reason?`, `note?` | transfer | Không nhận `status` |
| `POST /incoming-transfers` | Principal | `student_id`, `school_year_id?`, `previous_school`, `transfer_date`, `reason?`, `note?` | transfer | Không nhận `status` |
| `PATCH /outgoing-transfers/:id`, `PATCH /incoming-transfers/:id` | Principal | school-specific editable fields | transfer | Không nhận `student_id`, `school_year_id`, `status` |
| `PATCH /.../:id/cancel` | Principal | `{cancel_reason?}` | transfer | |
| `DELETE /.../:id` | Principal | id = transfer id | transfer | Soft delete; backend không có restore endpoint |

### Health, Nutrition và Growth

| API | Role | ID/query/body | Response | Ghi chú |
|---|---|---|---|---|
| `GET /health-assessments` | Principal, Teacher | `school_year_id?`, `class_id?`, `student_id?`, `bmi_status?`, `date_from?`, `date_to?`, `latest?`, pagination/search | paginated list | List/history view |
| `GET /health-assessments/by-class-date` | Principal, Teacher | required `class_id`, `assessment_date` | record array | Roster prefill, không cần year |
| `POST /health-assessments/bulk` | Principal, Teacher | `school_year_id`, `class_id`, `assessment_date`, `rows[]` | `{created,updated,skipped,errors}` | Roster quick entry chính |
| `POST /health-assessments` | Principal, Teacher | `student_id`, `school_year_id`, `assessment_date`, `height_cm`, `weight_kg`, `note?` | assessment | Single record/history |
| `PATCH /health-assessments/:assessment_id` | Principal, Teacher | date/height/weight/note, ít nhất 1 field | assessment | |
| `DELETE /health-assessments/:id` | Principal, Teacher | assessment id | `{deleted:true}` | Hard delete, không phải archive |
| `GET /health-assessments/history` | Principal, Teacher | required `student_id`, optional `school_year_id` | `{student,records}` | Growth history |
| `GET /health-assessments/who-curves` | Principal, Teacher | `indicator=height|weight|bmi`, `gender=Nam|Nữ` | curve data | |
| `GET /nutrition-assessments/grid` | Principal, Teacher | required `class_id`, `school_year_id`, `period` | roster array | Grid của một lớp |
| `GET /nutrition-assessments/grid-all` | Principal, Teacher | required `school_year_id`, `period` | roster array | All classes in year |
| `POST /nutrition-assessments/bulk` | Principal, Teacher | `class_id`, `school_year_id`, `period`, `rows[]` | `{saved,cleared,skipped}` | Empty row xóa nutrition record; không có DELETE route |

## Repository audit matrix

Trạng thái: **Đúng** = current live branch bám contract; **Một phần** = endpoint có thật nhưng thiếu query/body/flow; **Sai** = gọi endpoint/payload/ID semantics trái contract; **Mock-only** = chưa có live operation cần thiết.

| Flutter repository | Current live status | Evidence và sai lệch cần sửa |
|---|---|---|
| `core/network/api_client.dart` | **Sai** | Gắn Bearer từ SharedPreferences; không lưu/send refresh cookie, không response interceptor retry 401. Web dùng cookie jar + refresh. Goal 31-32. |
| `auth_repository.dart` | **Một phần** | Paths/body login, me, logout, change password đúng. Nhưng parse riêng `sorak_access`, mất refresh cookie; startup hiện tin metadata local thay vì xác thực `/auth/me`. Goal 31-32. |
| `academic_year_repository.dart` | **Một phần** | CRUD, activate, archive/restore dùng đúng method/path. Thiếu `promote`, `archived`; provider chưa persist selected year. Goal 33-34. |
| `account_repository.dart` | **Một phần** | `getStaffAccounts`/`getParentAccounts` dùng `type` đúng. `getAll` thiếu `type`. `assign-role` và active/password đúng ID. `changeStaffRole` đang nhận `teacherId`, đúng backend; phải test UI không truyền `accountId`. CRUD account thường không phải web flow ưu tiên. Goal 34. |
| `class_repository.dart` | **Sai** | List không gửi year/filter/page. Create/update nhận raw form payload; form đang gửi `teacher_name`; update có thể gửi `school_year_id`, đều bị validator từ chối. Chưa có add/remove teacher endpoint. Goal 34. |
| `teacher_repository.dart` | **Một phần** | CRUD/archive/restore paths đúng. List không gửi global year/work status/pagination. Raw form payload cần validator test. Goal 34. |
| `student_repository.dart` | **Một phần** | CRUD/archive/restore paths đúng. List không gửi global year/class/status/pagination. Update raw payload có thể mang `class_id`, `class_name`, `grade_level` trái validator; phải tách class transfer. Goal 34. |
| `form_options_repository.dart` | **Sai** | Gọi list tổng rồi filter client-side. Vì underlying repositories không gửi selected year, options có thể lẫn năm/lớp; không phù hợp teacher access scope. Goal 33-34. |
| `class_transfer_repository.dart` | **Sai** | List thiếu query year/class/student/status. Create raw UI đang gửi `status`, validator từ chối. Update bỏ `note`; generic archive/restore là status action, không phải soft delete. Goal 35. |
| `outgoing_transfer_repository.dart` | **Một phần** | Paths CRUD/cancel/delete đúng. List thiếu filter/year/page; create/update raw UI gửi `status` trái validator; cancel không gửi `cancel_reason`. Không có restore backend. Goal 35. |
| `incoming_transfer_repository.dart` | **Một phần** | Cùng lỗi Outgoing: list/filter, raw `status`, cancel reason và restore không tồn tại. Goal 35. |
| `health_assessment_repository.dart` | **Một phần** | Single CRUD đúng shape sau `_liveCreatePayload`. Roster lại load list chung/filter client-side thay vì `by-class-date` + `bulk`; delete là hard delete nên không được gọi archive theo UI rule chung. Goal 36. |
| `nutrition_assessment_repository.dart` | **Sai** | Hard-code year 1/period; dùng `grid-all` nhưng model giả fields; generic CRUD giả tạo item; `archive` bulk-clear là sai semantics cho Delete UI. Backend chỉ có grid/grid-all/bulk. Goal 36. |
| `growth_who_repository.dart` | **Sai** | Latest gọi generic health list; history hard-code `school_year_id: 1`; Parent trả mock dù live branch. Chưa gọi WHO curves. Goal 36. |

## UI payload audit cần nhớ

Các màn đang đưa field UI vào `Map<String,dynamic>` cần repository map DTO whitelist theo action. Không gửi nguyên map lên live API.

| Flow | Field phải loại khỏi live payload |
|---|---|
| Create/Update Class | `teacher_name`; ở update bỏ `school_year_id` |
| Update Student | `class_id`, `class_name`, `grade_level`; dùng Class Transfer thay thế |
| Create Class Transfer | `status`, display-only student/class names, `school_year_id` |
| Create/Update School Transfer | `status`, display-only student name/class name; update bỏ `student_id`, `school_year_id` |
| Health single create/update | `student_name`, `student_code`, `class_id`, `class_name`, calculated BMI/status |
| Nutrition | Không dùng generic CRUD DTO; chỉ `grid` và `bulk` DTO |

## Điều kiện hoàn thành Goal 30

- [x] Đã inventory toàn bộ repository Flutter có live branch.
- [x] Đã đối chiếu endpoint/method/role/query/body/response với web + routes + validators + services.
- [x] Đã ghi rõ semantics ID không đồng nhất trong Accounts/Classes.
- [x] Đã đánh dấu repository đúng, một phần hoặc sai và gán Goal sửa tiếp theo.
- [x] Đã loại Excel khỏi scope mobile.

Goal tiếp theo được phép sửa code là Goal 31 - Cookie Session Foundation.
