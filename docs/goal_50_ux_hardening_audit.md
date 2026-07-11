# Goal 50 UI/UX Hardening Audit

Goal 50 remains gated by SORAK-TEST-011. This file records current evidence so
work can begin without re-auditing the whole app after the backend decision.

| Requirement | Status | Current evidence | Required work |
| --- | --- | --- | --- |
| Role dashboard relevance | Pass | Principal/Teacher/Parent live screenshots and role tests | Keep regression coverage |
| Search/filter reflect server state | Partial | Global year is server-scoped; `ModuleListScreen` search/filter is local | Add repository query state, debounce and pagination where backend supports it |
| Vietnamese contextual error + retry | Partial | `ApiException` keeps message/traceId; `ErrorView` defaults remain English | Localize title/button, expose safe traceId and add semantics |
| Distinct empty/permission/unsupported states | Mostly pass | Module empty, RoleGuard and Parent unavailable states differ | Add explicit state enum/keys and test each state |
| Health dirty state and sticky save | Missing | Quick entry saves, but no proven leave-screen guard | Track edited rows, sticky save, discard confirmation and save failure retention |
| Minimum 48 px touch targets | Unproven | Material controls generally comply | Add widget assertions for key icon/menu/FAB controls |
| Text scaling and overflow | Partial | Small-screen Health test and live screenshots pass | Test textScale 1.3/2.0 on dashboard, forms and bottom navigation |
| Screen reader labels | Partial | Bottom nav and many icon tooltips exist | Add semantic labels for summary cards, status and quick-entry rows |
| Contrast | Unproven | Locked palette is used | Run automated/manual contrast audit for text/status combinations |

## Implementation Order After Gate Opens

1. Localize `ErrorView` and `EmptyView` defaults; add stable keys and semantics.
2. Introduce typed list query state (`search`, filters, page, pageSize, year)
   without changing endpoints that lack server support.
3. Add Health/Nutrition dirty-state tracking, sticky save and leave guard.
4. Add text-scale, touch-target, semantics and small-screen widget tests.
5. Run analyze, full functional tests, live contract, mock Android and live
   role smoke before declaring Goal 50 complete.

## Gate

Start implementation only when the backend Parent read contract is deployed or
the product owner explicitly accepts the current unavailable state as final
scope. Do not silently downgrade the gap and do not use live mock fallback.
