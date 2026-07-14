# Parent Health/Growth Read API Contract

Status: **Health deployed; Nutrition/Growth remain proposals**.

The deployed Health contract is `GET /api/parent/health-history`. It derives
the student from the authenticated Parent account and accepts no
`student_id`, `class_id` or `school_year_id` query from Flutter.

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

## Deployed Endpoint

### `GET /api/parent/health-history`

No query parameters. The backend resolves the owned student from the current
cookie session.

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

## Proposed Endpoints

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

1. Health uses the exact deployed path in `ApiEndpoints`, existing
   `ApiClient`, `ApiResponse`, and `HealthAssessment` parser.
2. Parent report renders Health read-only, newest first, with loading/error/
   empty states and no live-to-mock fallback.
3. Nutrition/Growth stay hidden until their contracts are deployed and pass
   2xx parsing.
4. Repeat Parent Android live smoke for Health history and ownership.
