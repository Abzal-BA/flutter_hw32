# Day 39 Homework

## Completed

- Added unit tests for the DTO -> Domain mapper `TaskModel.fromDoc` with 5 different inputs.
- Added tests for `AddTaskUseCase` with a mock/fake repository.
- Added an error-handling test and validation of the expected error message.
- Moved test data into fixtures and reused it across tests.
- Set up coverage execution via `flutter test --coverage`.

## Files

- `test/fixtures/task_fixtures.dart`
- `test/features/tasks/data/models/task_model_test.dart`
- `test/features/tasks/domain/usecases/add_task_usecase_test.dart`
- `tool/check_coverage.sh`

## Commands

```bash
flutter test
flutter test --coverage
./tool/check_coverage.sh
```

## Coverage Check

After running `flutter test --coverage`, the following file is generated:

```bash
coverage/lcov.info
```

The key files are present in the coverage report:

- `lib/features/tasks/data/models/task_model.dart`
- `lib/features/tasks/domain/usecases/add_task_usecase.dart`
