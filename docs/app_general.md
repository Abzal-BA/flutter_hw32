# App General Documentation

## App Overview

This application is a Flutter task tracker with authentication, profile settings, notifications, and current task management.

Main navigation:

- `Login / Register` screen for authentication
- `Current Tasks` page as the main working screen
- `Profile Settings` page opened through the drawer
- `Notification` pages for local notification details and settings

## Task Tracker Description

The task tracker is the main part of the app.

Current behavior:

- shows the list of current tasks after user login
- allows adding a new task from the main page
- allows opening a separate task edit page
- allows updating task status
- keeps profile settings separate from task management
- opens profile settings through the drawer

Current task statuses:

- `todo`
- `in_progress`
- `done`

## Color Codes

The app currently uses Material 3 with `colorSchemeSeed: Colors.indigo`.

Main colors used in the app:

- Primary seed color: `#3F51B5` (`Colors.indigo`)
- Error light background: `#FFEBEE` (`Colors.red.shade50`)
- Error text color: `#D32F2F` (`Colors.red.shade700`)
- Default light background: `#FFFFFF`
- Default text color: `#000000`

## UI Structure

- The main page is focused only on current task management.
- The profile settings page is separated from the task page.
- Access to profile settings is done through the drawer.
- Task editing is done on a dedicated task edit page.

## Important Files

- `lib/main.dart`
- `lib/features/auth/presentation/pages/auth_screen.dart`
- `lib/features/auth/presentation/pages/home_screen.dart`
- `lib/features/auth/presentation/pages/user_settings_page.dart`
- `lib/features/items/presentation/pages/task_edit_page.dart`
- `lib/features/items/presentation/controller/items_controller.dart`
