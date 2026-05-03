# Домашнее задание 42 дня: Release Build

## Что подготовлено

- Обновлена версия приложения до `1.0.0+42`.
- Android release build настроен на использование `versionName` и `versionCode` из Flutter version.
- Добавлена release signing-конфигурация через `android/key.properties`.
- Добавлен шаблон `android/key.properties.example`.
- В `.gitignore` добавлены `key.properties`, `*.jks`, `*.keystore`.
- Подготовлены конфиги для `flutter_launcher_icons` и `flutter_native_splash`.

## Подпись Android release

Файл конфигурации:

- `android/key.properties.example`

Ожидаемый локальный файл:

- `android/key.properties`

Формат:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

## Чеклист релизной сборки Android

1. Создать или получить upload keystore.
2. Положить keystore в `android/app/`.
3. Создать `android/key.properties` на основе `android/key.properties.example`.
4. Проверить `versionName/versionCode` в `pubspec.yaml`.
5. Выполнить:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter build appbundle --release
```

6. Проверить, что собирается `AAB` для Play Console.

## Фактический результат

- Release bundle успешно собран `2026-05-03`.
- Артефакт:
  `build/app/outputs/bundle/release/app-release.aab`
- Размер артефакта:
  около `43 MB`

## Internal Testing

Для внутреннего релиза в Play Console:

1. Собрать `appbundle`:

```bash
flutter build appbundle --release
```

2. Открыть Play Console.
3. Выбрать приложение.
4. Перейти в `Testing` -> `Internal testing`.
5. Создать релиз и загрузить `build/app/outputs/bundle/release/app-release.aab`.
6. Заполнить release notes.
7. Добавить тестеров.
8. Отправить релиз в internal testing.

## Статус

- Локальная release-конфигурация подготовлена.
- Android `AAB` успешно собран локально.
- Play Console internal release требует доступа к аккаунту разработчика и выполняется вручную.
