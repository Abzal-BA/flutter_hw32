# Day 35 Manual Test Report

## Scope

- Business logic extracted from UI into:
  - MVC: `NotesController`
  - MVP: `NotesPresenter`
- Minimum required methods implemented:
  - `loadTasks()`
  - `addTask(...)`

## Where Implemented

- MVC load/add:
  - `lib/notes/notes_controller.dart`
- MVP load/add:
  - `lib/notes/mvp/notes_presenter.dart`
- UI call sites:
  - MVC screen: `lib/pages/task_page.dart`
  - MVP screen: `lib/pages/task_page_mvp.dart`

## Manual Test Steps (MVC)

1. Open Task Page (MVC).
2. Tap Retry (calls `loadTasks()`).
3. Verify tasks list is displayed.
4. Tap Add task and create item.
5. Verify new item appears in list.
6. Apply filters and search.
7. Verify list refreshes correctly.
8. Trigger validation error (empty title on add).
9. Verify user-friendly error message is shown.

## Manual Test Steps (MVP)

1. Open drawer -> Task page MVP.
2. Tap Retry (calls `loadTasks()`).
3. Verify tasks list is displayed.
4. Tap Add task and create item.
5. Verify new item appears in list.
6. Apply filters and search.
7. Verify list refreshes correctly.
8. Trigger validation error (empty title on add).
9. Verify user-friendly error message is shown.

## Result

- MVC flow: passed
- MVP flow: passed
- Requirement "business logic out of UI, at least 2 methods load/add": passed

## MVC vs MVP Comparison

- MVC was simpler to start: one `NotesController` + `AnimatedBuilder` in UI.
- MVP was stricter: required `NotesMvpView` contract and explicit `attach/detach` lifecycle.
- MVC had slightly less boilerplate for this screen.
- MVP made presentation responsibilities more explicit and easier to isolate for view-contract testing.

## Unified ErrorHandler Coverage

- Centralized mapper: `lib/core/error_handler.dart`.
- MVC usage: `lib/notes/notes_controller.dart`.
- MVP usage: `lib/notes/mvp/notes_presenter.dart`.
- Auth usage: `lib/auth/auth_controller.dart`.
