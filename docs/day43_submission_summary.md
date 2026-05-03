# Day 43 Submission Summary

## Выполнено

- Создан GitHub Actions workflow:
  `flutter pub get -> dart analyze -> flutter test -> build apk`
- Добавлены Android flavors:
  `dev` и `prod`
- Добавлены отдельные entrypoints:
  - `lib/main_dev.dart`
  - `lib/main_prod.dart`
- Для `dev` и `prod` настроены разные app labels.
- Для `dev` включён banner `DEV`.
- Для release build в CI добавлено автоматическое увеличение `build number` через `GITHUB_RUN_NUMBER`.
- Добавлен минимальный тест, чтобы шаг `flutter test` был рабочим.

## Локальная проверка

- `dart analyze` — успешно
- `flutter test` — успешно
- `flutter build apk --debug --flavor dev -t lib/main_dev.dart` — успешно
- `flutter build apk --release --flavor prod -t lib/main_prod.dart` — успешно

## Основные файлы

- `.github/workflows/flutter_day43_ci.yml`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `lib/bootstrap.dart`
- `lib/main.dart`
- `lib/main_dev.dart`
- `lib/main_prod.dart`
- `lib/app/app_environment.dart`
- `test/features/auth/presentation/state/auth_state_test.dart`
- `docs/day43_ci_flavors.md`
