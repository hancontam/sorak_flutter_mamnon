# Sorak Flutter - Functional Test Plan After Core API

Baseline date: 2026-07-10

## Baseline

| Gate | Result |
| --- | --- |
| `flutter analyze` | Pass |
| `flutter test` | 83 passed, 2 skipped live-contract cases |
| Live-branch adapter contract | 2 passed |
| Android mock role UI | Pass on Pixel 7 Pro emulator, Android 16/API 36 |
| Android live UI | Partial: Principal/Teacher pass on API 35; Parent credential unavailable |

## Implemented Evidence

- Canonical HTTP mock envelopes and production `fromJson` parsing.
- Repository-local legacy fixtures/branches removed; mock and live have one
  Dio request path.
- Exact Class, Student, Class Transfer, Incoming and Outgoing DTO assertions.
- Three-year dataset, global invalidation and stale-response race regression.
- Principal account flow, Teacher data/action scope and API 403 checks.
- Parent `/auth/me` profile with no staff year selector or fake Health/Growth.
- Health/Nutrition bulk save then reload, Growth history/WHO curves.
- Teacher-to-Accounts and class-transfer approve/revert integrity.
- Android screenshots for login, Principal dashboard/Health, Teacher dashboard,
  and Parent profile/unavailable Health in `docs/evidence/`.
- Live Android screenshots for login, Principal, Teacher and Teacher Health on
  a clean API 35 AVD. No live mutation was performed.

Passing widget tests are not sufficient evidence for live behavior. A feature passes only when its role visibility, displayed data, request contract, mutation refresh, and error/empty/loading states are asserted.

## Test Layers

1. Canonical mock contract: raw live-shaped envelopes are parsed by production models.
2. Repository/provider contract: exact method, path, query, body, pagination, error, and year state.
3. Role journeys: Principal, Teacher, and Parent enter through authentication and exercise allowed UI only.
4. Cross-module integrity: mutations update every related view and preserve archive rules.
5. Live smoke: read-only by default; mutations use records prefixed `MOBILE_TEST_`.

## Role Acceptance

| Area | Principal | Teacher | Parent |
| --- | --- | --- | --- |
| Dashboard | Whole-school data and approvals | Assigned classes and daily entry | Own student profile |
| Accounts/Teachers | Manage | Hidden/guarded | Hidden/guarded |
| Classes/Students | Full permitted management | Assigned scope and permitted actions | Own enrollment only |
| Transfers | Full workflow | Own class requests; school transfers read-only | Hidden |
| Health/Nutrition/Growth | All classes | Assigned classes | Requires parent read-only backend contract |

## Completion Gates

- Mock and live use the same response parser and model mapping.
- No live flow falls back to mock records.
- Every mutation DTO is accepted by the matching backend validator.
- Changing academic year cannot expose stale class/student/health data.
- Critical and High defects are closed; remaining defects have an owner and status.
- Analyze, functional tests, live-contract tests, Android smoke, and debug APK results are recorded.

Current completion status: **Partial**. Automated, Android mock, live Principal
and live Teacher gates pass, but SORAK-TEST-011 and SORAK-TEST-013 remain
open/partial.
Goal 50 must not start until those High items are closed or explicitly accepted.
