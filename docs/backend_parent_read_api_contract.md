# Parent Health/Growth Read API Contract Proposal

Status: **proposal only**. Flutter must not call these paths until the backend
implements and documents them.

## Current Backend Evidence

- `health-assessments.routes.js` applies `requireRoles('PRINCIPAL', 'TEACHER')`
  to every route.
- `nutrition-assessments.routes.js` applies the same staff-only guard.
- `/auth/me` returns the authenticated Parent's student, parents and latest
  enrollment, but no health, nutrition or growth records.

Current source:

- https://github.com/toanthienla/sorak-mamnonhontre/blob/main/sorak-api/src/routes/health-assessments.routes.js
- https://github.com/toanthienla/sorak-mamnonhontre/blob/main/sorak-api/src/routes/nutrition-assessments.routes.js
- https://github.com/toanthienla/sorak-mamnonhontre/blob/main/sorak-api/src/services/auth.service.js

## Security Rules

1. Every endpoint uses the existing cookie session and requires `PARENT`.
2. The service derives `student_id` from `req.user.sub -> account -> student`.
3. Parent requests must not accept `student_id`, `class_id` or
   `school_year_id` from the client. This prevents IDOR and staff-filter reuse.
4. Deleted students/accounts and archived assessments are excluded.
5. Endpoints are read-only. Parent cannot call bulk, create, update or delete.
6. Response and error envelopes keep the existing `{success,data}` and
   `{success:false,message,errors,traceId}` contracts.

## Proposed Endpoints

### `GET /api/parent/health-history`

Optional query: `from`, `to`. The backend resolves the current student and
enrollment.

```json
{
  "success": true,
  "data": {
    "student": {
      "student_id": 401,
      "full_name": "...",
      "gender": "Nam"
    },
    "records": [
      {
        "assessment_id": 601,
        "student_id": 401,
        "school_year_id": 101,
        "assessment_date": "2026-07-11",
        "height_cm": 102.5,
        "weight_kg": 16.2,
        "bmi": 15.42,
        "bmi_status": "Bình thường",
        "height_status": "Bình thường",
        "weight_status": "Bình thường",
        "note": ""
      }
    ]
  }
}
```

Each record must parse with Flutter `HealthAssessment.fromJson`.

### `GET /api/parent/nutrition`

Optional query: `period`. Allowed values must match the backend nutrition
validator.

```json
{
  "success": true,
  "data": [
    {
      "nutrition_id": 701,
      "student_id": 401,
      "school_year_id": 101,
      "period": "dau_nam",
      "weight_channel": "Bình thường",
      "is_stunting": false,
      "is_severe_stunting": false,
      "is_obese": false,
      "latest_bmi": 15.42,
      "latest_bmi_status": "Bình thường",
      "note": ""
    }
  ]
}
```

Each row must parse with Flutter `NutritionAssessment.fromJson`.

### `GET /api/parent/growth`

Required query: `indicator=height|weight|bmi`. Gender comes from the owned
student, not client input.

```json
{
  "success": true,
  "data": {
    "student": {
      "student_id": 401,
      "full_name": "...",
      "gender": "Nam"
    },
    "records": [],
    "curves": [
      {
        "month": 48,
        "sd3neg": 91.0,
        "sd2neg": 94.0,
        "median": 102.0,
        "sd2": 110.0,
        "sd3": 114.0
      }
    ]
  }
}
```

`records` uses `HealthAssessment`; `curves` uses `WhoCurvePoint`.

## Backend Acceptance Tests

- Parent A receives only Parent A's student records.
- Passing `student_id` is rejected or ignored; it can never switch ownership.
- Parent cannot call staff list/bulk/mutation routes.
- Principal/Teacher behavior remains unchanged.
- Archived Parent/student returns 401 or 404 without leaking records.
- Empty history returns a successful empty list, not 400.

## Flutter Rollout

1. Merge and deploy the backend contract first.
2. Add exact paths to `ApiEndpoints`; do not guess or probe alternatives.
3. Add Parent repository methods that use the existing `ApiClient`,
   `ApiResponse` and model parsers.
4. Replace unavailable cards only after 2xx parsing succeeds. Never fall back
   to mock when `USE_MOCK_API=false`.
5. Add canonical mock fixtures and Parent widget journeys for data, empty,
   401/403, malformed response and retry.
6. Repeat Parent Android live smoke with a prefixed student and archive it.
