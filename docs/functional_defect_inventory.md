# Sorak Flutter - Functional Defect Inventory

| ID | Severity | Status | Defect | Evidence | Exit criterion |
| --- | --- | --- | --- | --- | --- |
| SORAK-TEST-001 | High | Closed | Repository mocks bypass API envelopes and `fromJson` | Canonical backend adapter contract tests pass | All mock calls use live-shaped envelopes and production parsing |
| SORAK-TEST-002 | High | Closed | Mock domain values and relations are inconsistent | Canonical Vietnamese fixture and relation tests pass | Canonical Vietnamese fixture graph passes relation tests |
| SORAK-TEST-003 | High | Closed | Year change can leave non-active tabs scoped to an old year | Global invalidation, empty year and race tests pass | Every year-scoped provider reads the latest global year |
| SORAK-TEST-004 | High | Closed | Class payload contains validator-rejected fields | DTO request log proves separate teacher assignment | Exact create/update DTO tests pass |
| SORAK-TEST-005 | High | Closed | Student update contains validator-rejected class fields | Update request excludes enrollment-only fields | Update DTO excludes enrollment fields |
| SORAK-TEST-006 | High | Closed | School-transfer payload sends UI-only status/name fields | Class/Incoming/Outgoing contract tests pass | Exact create/update DTO tests pass |
| SORAK-TEST-007 | Medium | Closed | Backend errors are reduced to generic Dio text | Shared `ApiException` parses message/errors/traceId | Vietnamese API error includes safe message and traceId |
| SORAK-TEST-008 | High | Closed | Teacher mock data is not role-scoped | Assigned data, action visibility and API 403 tests pass | Teacher only sees assigned classes/students/actions |
| SORAK-TEST-009 | Critical | Closed | Parent live flow can display mock Health/Growth data | Parent repositories/screens never return fixture Health/Growth | No mock fallback in live mode |
| SORAK-TEST-010 | High | Closed | Parent profile uses hard-coded student id | Parent profile renders student 401 from `/auth/me` | Student id comes from `/auth/me` profile |
| SORAK-TEST-011 | High | Contract gap | Parent Health/Growth endpoints do not exist | Backend health routes allow staff only | UI reports unavailable until a real read-only contract exists |
| SORAK-TEST-012 | High | Closed | Principal UI shows Bad Request | Android live created Teacher ID 26 with `MOBILE_TEST_` prefix, refreshed list, then soft-archived it; detail has `deleted_at` | Exact DTO tests and live prefixed mutation pass without 400 |
| SORAK-TEST-013 | High | Partial | Android role journeys lacked evidence | Live Principal and Teacher pass read-only on API 35; no usable Parent live credential | Run Parent profile after a test account is provisioned |
| SORAK-TEST-014 | High | Closed | Principal dashboard kept Teacher count loading after login | Removed unscoped Home load; AppShell is the only year-scoped loader; live shows 21 teachers | Principal dashboard settles with year 21 and no duplicate initial fetch |
| SORAK-TEST-015 | Medium | Closed | Clean Android build can stall under 8 GB Gradle heap configuration | Gradle heap reduced to 2 GB; clean and incremental live APK builds pass | Debug APK builds on the project workstation without memory starvation |
