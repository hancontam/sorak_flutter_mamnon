# Goal 33 - Global Academic Year State

Status: complete (2026-07-10).

## Behavior

- `ActiveAcademicYearProvider` is the only source of the selected academic year.
- `LocalStorage` persists `selected_academic_year_id`. A stale value falls back to the active academic year, then the first available year.
- The selector belongs in `AppShell`. Do not create per-module global year selectors.
- On a year change, AppShell updates `FormOptionsProvider`, reloads the visible destination, then remounts that screen after data finishes loading.

## Scoped Data

Classes, Students, Teachers, Class Transfers, Incoming Transfers, Outgoing Transfers, Health Assessments, Nutrition Assessments, and Growth WHO receive the selected year before fetching data. Form options reset dependent class and student choices when the year changes.

## Live API Rule

No live request or live create/bulk payload may have `school_year_id: 1`, `?? 1`, or any implicit year-id fallback. Static mock fixtures may use an example id.

## Verification

`test/functional/active_academic_year_functional_test.dart` covers selected-year persistence and AppShell synchronization with form options and a scoped list provider. On 2026-07-10, `flutter analyze` passed and `flutter test` passed 65 tests.
