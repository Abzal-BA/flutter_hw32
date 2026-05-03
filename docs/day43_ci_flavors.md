# Домашнее задание 43 дня

## Что реализовано

- Добавлен GitHub Actions workflow:
  `flutter pub get -> dart analyze -> flutter test -> build apk`
- Добавлены Android flavors:
  `dev` и `prod`
- Добавлены отдельные entrypoints:
  - `lib/main_dev.dart`
  - `lib/main_prod.dart`
- Для `dev` и `prod` настроены разные app labels.
- Для `dev` включён визуальный banner `DEV` внутри Flutter-приложения.
- Для release build в CI добавлено автоматическое повышение `build number` через `GITHUB_RUN_NUMBER`.

## Flavors

### Dev

- Android flavor: `dev`
- entrypoint: `lib/main_dev.dart`
- app label: `Flutter HW32 Dev`
- version suffix: `-dev`

### Prod

- Android flavor: `prod`
- entrypoint: `lib/main_prod.dart`
- app label: `Flutter HW32`

## Примеры локальной сборки

### Dev debug APK

```bash
flutter build apk --debug --flavor dev -t lib/main_dev.dart
```

### Dev release APK

```bash
flutter build apk --release --flavor dev -t lib/main_dev.dart
```

### Prod debug APK

```bash
flutter build apk --debug --flavor prod -t lib/main_prod.dart
```

### Prod release APK

```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

## Автоматический build number

В GitHub Actions для release APK используется:

```text
--build-number $GITHUB_RUN_NUMBER
```

Это даёт автоматическое увеличение build number при каждом новом release-прогоне workflow.
