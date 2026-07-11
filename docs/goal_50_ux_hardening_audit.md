# Goal 50 UI/UX Hardening Audit

The product owner confirmed that Parent Health/Growth is not supported by the
current backend. The explicit unavailable state is therefore accepted release
scope. It must remain truthful and must never fall back to mock data in live
mode.

| Requirement | Status | Current evidence | Required work |
| --- | --- | --- | --- |
| Role dashboard relevance | Pass | Principal/Teacher/Parent live screenshots and role tests | Keep regression coverage |
| Search/filter reflect server state | Medium follow-up | Lists fetch the selected-year snapshot (up to 500 rows), then filter locally | SORAK-UX-001 owns server pagination when a module exceeds 500 active rows |
| Vietnamese contextual error + retry | Pass | Shared error/loading/empty/search/dialog defaults are Vietnamese; safe API message/traceId is preserved | Keep widget regression coverage |
| Distinct empty/permission/unsupported states | Pass | Typed empty state keys, permission key and Parent unsupported keys are separate | Keep role regression coverage |
| Health dirty state and sticky save | Pass | Health/Nutrition sheet tracks edits, pins Save and confirms discard | Keep failure-retention and small-screen regression coverage |
| Minimum 48 px touch targets | Pass | App theme locks Filled/Outlined/Icon controls to at least 48 px; widget assertion passes | Keep theme regression coverage |
| Text scaling and overflow | Pass for critical flows | Shared states pass 2.0; Health quick entry passes 1.3 on 360x640 | Extend to new screens as they are added |
| Screen reader labels | Pass for shared states | Error/loading/empty/status and Parent unsupported states expose semantics | Extend labels with new icon-only controls |
| Contrast | Pass | Ratios: dark/white 17.74, gray/white 4.76, primary/white 14.65; status text/tints 6.36-7.13 | Re-audit if locked colors change |

## Implemented

1. Localized shared states and controls; added stable keys and semantics.
2. Preserved server-scoped academic year and documented bounded local list
   querying as SORAK-UX-001 instead of guessing unsupported query contracts.
3. Added Health/Nutrition dirty tracking, sticky Save and leave confirmation.
4. Added text-scale, touch-target, semantics and small-screen widget tests.
5. Kept the accepted Parent unavailable state truthful in live mode.

## Gate Decision

Gate opened on 2026-07-11 by product-owner confirmation. SORAK-TEST-011 is now
`Accepted scope`, not `Pass`: the API capability still does not exist. Future
implementation must follow `docs/backend_parent_read_api_contract.md` and must
not guess endpoints or reuse staff routes.
