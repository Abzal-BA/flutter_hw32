# App General Documentation

## App Overview

This application is a Flutter app with authentication, task management, profile settings, and notifications.

Main navigation:

- `Login / Register` screen for authentication
- `Task Manager` page after successful login
- `Profile Settings` page opened through the drawer from the home page
- `Task Edit` page for updating task status
- `Notification` pages for local notification details and settings

## Task Manager

The task manager is the main part of the application.

Current behavior:

- shows current tasks on the main screen after login
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

- The main page is focused on task management.
- The profile settings page is separated from the main page.
- Access to profile settings is done through the drawer.
- Task editing is done on a dedicated task edit page.

## Important Files

- `lib/main.dart`
- `lib/features/auth/presentation/pages/auth_screen.dart`
- `lib/features/auth/presentation/pages/home_screen.dart`
- `lib/features/auth/presentation/pages/user_settings_page.dart`
- `lib/features/tasks/presentation/pages/task_edit_page.dart`
- `lib/features/tasks/presentation/controller/tasks_controller.dart`
