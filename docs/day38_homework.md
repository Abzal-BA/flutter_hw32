# Day 38 Homework

## Repository

- Interface: [i_notes_repository.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/domain/repositories/i_notes_repository.dart)
- Implementation: [notes_repository_impl.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/repositories/notes_repository_impl.dart)

## Adapter

- External format to domain-friendly model mapping:
  [note_remote_adapter.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/adapters/note_remote_adapter.dart)

The adapter converts fields like:
- `note_id` -> `id`
- `title_text` -> `title`
- `body_text` -> `content`
- `updated_at` -> `updatedAt`

## Model Mapping

- Model: [note_model.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/models/note_model.dart)
- Adapter tests:
  [note_remote_adapter_test.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/test/features/notes/data/adapters/note_remote_adapter_test.dart)

Covered cases:
- Normal data
- Empty data
- Incorrect data types

## Caching

- Local cache datasource:
  [note_local_datasource.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/datasources/note_local_datasource.dart)
- Cache-first repository flow:
  [notes_repository_impl.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/repositories/notes_repository_impl.dart)

Behavior:
- first returns local cached notes
- then fetches fresh notes from remote
- saves fresh notes back to local cache

## Datasource Layer

- Remote datasource:
  [note_remote_datasource.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/datasources/note_remote_datasource.dart)
- Local datasource:
  [note_local_datasource.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/data/datasources/note_local_datasource.dart)

Strategy switching is defined in:
- [i_notes_repository.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/domain/repositories/i_notes_repository.dart)

Available strategies:
- `cacheFirst`
- `remoteOnly`
- `localOnly`

## Use Case And Presentation

- Use case:
  [watch_notes_usecase.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/domain/usecases/watch_notes_usecase.dart)
- ViewModel:
  [notes_view_model.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/presentation/viewmodel/notes_view_model.dart)
- Page:
  [notes_page.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/features/notes/presentation/pages/notes_page.dart)

## Dependency Injection

- Registered in:
  [service_locator.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/lib/di/service_locator.dart)

## Tests

- Adapter mapping tests:
  [note_remote_adapter_test.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/test/features/notes/data/adapters/note_remote_adapter_test.dart)
- Repository caching and strategy tests:
  [notes_repository_impl_test.dart](/Users/mac/Flutter%20lessons/flutter_practics/flutter_hw32/test/features/notes/data/repositories/notes_repository_impl_test.dart)
