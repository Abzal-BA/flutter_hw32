# Play Console Internal Testing

## Что подготовлено локально

- release build configuration для Android
- `versionName/versionCode`
- signing через `android/key.properties`
- launcher icons
- native splash screen
- release documentation по permissions/privacy и risks
- готовый `AAB` для загрузки в internal testing:
  `build/app/outputs/bundle/release/app-release.aab`

## Что нужно сделать в Play Console

1. Войти в аккаунт разработчика Google Play Console.
2. Открыть нужное приложение.
3. Перейти в `Testing` -> `Internal testing`.
4. Создать новый релиз.
5. Загрузить `AAB` файл:

```text
build/app/outputs/bundle/release/app-release.aab
```

6. Добавить release notes.
7. Добавить список тестеров или email group.
8. Publish to internal testing.

## Suggested Release Notes

```text
Internal build 1.0.0 (42)
- Android release bundle signed and built
- launcher icon updated
- splash screen updated
- notifications permission/privacy reviewed
```

## Ограничение

Этот шаг нельзя завершить автоматически из локального workspace без доступа к вашему Play Console аккаунту.
