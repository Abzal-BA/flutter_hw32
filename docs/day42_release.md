# Домашнее задание 42 дня

## Краткий итог

- Подготовлена Android release-конфигурация.
- Настроены `versionName` и `versionCode`.
- Настроена release signing-конфигурация через `keystore`.
- Сгенерированы launcher icons.
- Сгенерирован native splash screen.
- Проверены permissions и privacy-требования для уведомлений.
- Подготовлена инструкция для Play Console internal testing.
- Подготовлен список релизных рисков и план отката.
- Успешно собран release bundle:
  `build/app/outputs/bundle/release/app-release.aab`

## Release Build

### Что подготовлено

- Обновлена версия приложения до `1.0.0+42`.
- Android release build настроен на использование `versionName` и `versionCode` из Flutter version.
- Добавлена release signing-конфигурация через `android/key.properties`.
- Добавлен шаблон `android/key.properties.example`.
- В `.gitignore` добавлены `key.properties`, `*.jks`, `*.keystore`.
- Подготовлены конфиги для `flutter_launcher_icons` и `flutter_native_splash`.

### Подпись Android release

Файл-шаблон:

- `android/key.properties.example`

Локальный файл:

- `android/key.properties`

Формат:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```

### Чеклист релизной сборки Android

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

### Фактический результат

- Release bundle успешно собран `2026-05-03`.
- Артефакт:
  `build/app/outputs/bundle/release/app-release.aab`
- Размер:
  около `43 MB`

## Permissions And Privacy

### Используемые permissions

#### Android

- `android.permission.POST_NOTIFICATIONS`

Причина:

- приложение использует Firebase Messaging и локальные уведомления.

#### Не используются

- Камера
- Фото / галерея

Для них дополнительные permissions и privacy-тексты не добавлялись, так как в текущем приложении эти функции отсутствуют.

### Privacy

#### Notifications

Android:

- permission используется для отображения уведомлений приложения.

iOS:

- приложение запрашивает системное разрешение на уведомления через Firebase Messaging / local notifications
- отдельный privacy-текст в `Info.plist` для уведомлений не используется

### Рекомендация перед релизом

- проверить фактический список permissions в итоговом `AAB/APK`
- убедиться, что privacy form в Play Console соответствует реальному функционалу приложения

## Internal Testing

### Что подготовлено локально

- release build configuration для Android
- `versionName/versionCode`
- signing через `android/key.properties`
- launcher icons
- native splash screen
- release documentation по permissions/privacy и risks
- готовый `AAB` для загрузки в internal testing:
  `build/app/outputs/bundle/release/app-release.aab`

### Что нужно сделать в Play Console

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

### Suggested Release Notes

```text
Internal build 1.0.0 (42)
- Android release bundle signed and built
- launcher icon updated
- splash screen updated
- notifications permission/privacy reviewed
```

### Ограничение

Этот шаг нельзя завершить автоматически из локального workspace без доступа к вашему Play Console аккаунту.

## Релизные риски и откат

### Релизные баги и риски

1. Ошибка signing-конфигурации.  
Риск: release build не соберётся или не загрузится в Play Console.  
Снижение риска: проверить `android/key.properties`, alias, passwords и путь к keystore до сборки.

2. Неверный `versionCode`.  
Риск: Play Console отклонит upload.  
Снижение риска: увеличивать build number перед каждым новым релизом.

3. Некорректные иконки или splash screen.  
Риск: визуальные дефекты на части устройств или Android 12+.  
Снижение риска: проверить запуск на реальном Android-устройстве и эмуляторе до релиза.

4. Ошибка permission flow для уведомлений.  
Риск: уведомления не будут отображаться или пользователь не поймёт, зачем нужен доступ.  
Снижение риска: проверить первый запуск и экран настроек уведомлений на устройстве.

5. Firebase / notification regression.  
Риск: push token не сохранится или deep link не откроется.  
Снижение риска: проверить авторизацию, получение токена и тестовое уведомление перед выкладкой.

### План отката

1. Не выкатывать релиз выше internal testing, пока не пройдена ручная проверка.
2. Если ошибка найдена на internal testing, не переводить сборку в closed/open/production и загрузить новый build с увеличенным `versionCode`.
3. Если проблема обнаружена после повышения окружения, остановить rollout в Play Console.
4. Подготовить hotfix build с новым `versionCode`.
5. Использовать предыдущий стабильный build как baseline для сравнения.

### Минимальный smoke test перед релизом

- запуск приложения
- логин / логаут
- открытие profile settings
- запрос permission на уведомления
- отправка тестового локального уведомления
- открытие notification details

## Что осталось ручным шагом

- Проверка иконок и splash screen на реальном Android-устройстве.
- Загрузка `AAB` в Google Play Console -> Internal testing.
