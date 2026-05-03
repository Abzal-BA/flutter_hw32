# Permissions And Privacy

## Используемые permissions

### Android

- `android.permission.POST_NOTIFICATIONS`

Причина:

- приложение использует Firebase Messaging и локальные уведомления.

### Не используются

- Камера
- Фото / галерея

Для них дополнительные permissions и privacy-тексты не добавлялись, так как в текущем приложении эти функции отсутствуют.

## Privacy Texts

### Notifications

Android:

- permission используется для отображения уведомлений приложения.

iOS:

- приложение запрашивает системное разрешение на уведомления через Firebase Messaging / local notifications
- отдельный privacy-текст в `Info.plist` для уведомлений не используется

## Рекомендация перед релизом

- проверить фактический список permissions в итоговом `AAB/APK`
- убедиться, что privacy form в Play Console соответствует реальному функционалу приложения
