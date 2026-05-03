# App General Documentation

## App Overview

This application is a Flutter app with authentication, profile settings, and notifications.

Main navigation:

- `Login / Register` screen for authentication
- `Home` page after successful login
- `Profile Settings` page opened through the drawer from the home page
- `Notification` pages for local notification details and settings

## Color Codes

The app currently uses Material 3 with `colorSchemeSeed: Colors.indigo`.

Main colors used in the app:

- Primary seed color: `#3F51B5` (`Colors.indigo`)
- Error light background: `#FFEBEE` (`Colors.red.shade50`)
- Error text color: `#D32F2F` (`Colors.red.shade700`)
- Default light background: `#FFFFFF`
- Default text color: `#000000`

## UI Structure

- The home page is a separate screen shown after authentication.
- The profile settings page is separated from the home page.
- Access to profile settings is done through the drawer.

## Important Files

- `lib/main.dart`
- `lib/features/auth/presentation/pages/auth_screen.dart`
- `lib/features/auth/presentation/pages/home_screen.dart`
- `lib/features/auth/presentation/pages/user_settings_page.dart`
