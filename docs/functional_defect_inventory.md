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
| SORAK-TEST-012 | High | Partial | Principal UI shows Bad Request | Exact mutation DTO tests and safe backend message pass; live mutation pending | Confirm mutation on `MOBILE_TEST_` record during Android smoke |
| SORAK-TEST-013 | High | Partial | Android role journeys lacked evidence | Mock Principal/Teacher/Parent pass on API 36; live remains pending | Repeat role smoke with live API build and read-only data |
