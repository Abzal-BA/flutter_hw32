# Домашнее задание 41 дня

## Задание

- Замокать внешние сервисы (`ApiClient` / `DB`) с помощью `mocktail` или `mockito` и протестировать репозиторий.
- Добавить integration test для полного минимального сценария: `логин -> список -> добавление -> выход`.
- Проверить, что зависимости подменяются через DI тестовыми реализациями и что в тестах нет реальных сетевых запросов.
- Добавить fake-сервер или заглушку с фиксированными ответами JSON.
- Запускать тесты в CI хотя бы одним workflow step.

## Выполненная работа

- Добавлена минимальная фича управления текущими задачами, чтобы покрыть тестовый сценарий без реальных backend-запросов.
- Реализованы абстракции `ApiClient` и `ItemsDb` для тестирования репозитория.
- Добавлены `FakeServerApiClient` с фиксированными JSON-ответами и `InMemoryItemsDb` как локальная заглушка базы данных.
- Реализован `ItemRepositoryImpl` и добавлены unit-тесты для него с использованием `mocktail`.
- Добавлен `FakeAuthRepository` для тестирования авторизации без Firebase.
- Расширен DI в `service_locator.dart` через `DependencyOverrides`, чтобы тестовые зависимости могли подменять боевые.
- Добавлен integration test для сценария `логин -> список задач -> добавление задачи -> изменение статуса -> выход`.
- Добавлены стабильные `key` у виджетов на экранах авторизации и главной страницы для надёжного integration testing.
- Главная страница теперь отвечает только за управление текущими задачами.
- Страница настроек профиля вынесена отдельно и открывается через `Drawer`.
- Добавлена отдельная страница редактирования задачи с возможностью обновлять её статус.
- Добавлен GitHub Actions workflow с шагами `flutter pub get`, `dart analyze`, `flutter test` и `flutter test integration_test/app_flow_test.dart`.

## Основные файлы

- `lib/features/items/data/api_client.dart`
- `lib/features/items/data/items_db.dart`
- `lib/features/items/data/fake_server_api_client.dart`
- `lib/features/items/data/in_memory_items_db.dart`
- `lib/features/items/data/item_repository_impl.dart`
- `lib/features/items/presentation/controller/items_controller.dart`
- `lib/features/items/presentation/pages/task_edit_page.dart`
- `lib/di/service_locator.dart`
- `lib/features/auth/presentation/pages/home_screen.dart`
- `lib/features/auth/presentation/pages/user_settings_page.dart`
- `test/features/items/data/item_repository_impl_test.dart`
- `test/helpers/fake_auth_repository.dart`
- `integration_test/app_flow_test.dart`
- `.github/workflows/flutter_ci.yml`
