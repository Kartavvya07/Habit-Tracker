# Changelog

All notable changes to the Habit Tracker project will be documented in this file.

## v0.2.0-alpha

### Features
- Reactive Dashboard Screen with Material 3 design system
- Material 3 Habit Cards (`HabitCard`) displaying color accent tint, icon avatar, title, description, frequency, habit type, and target value metadata
- Live Drift SQLite stream integration via Riverpod `habitsStreamProvider` and `dashboardProvider`
- Responsive state handling for `DashboardLoading`, `DashboardEmpty`, `DashboardLoaded`, and `DashboardError` presentation states
- Automatic UI updates upon new habit creation without manual refresh
- Floating Action Button navigation to `/create-habit`
- Expanded widget test suite covering all presentation states, FAB navigation, retry error handling, and reactive stream updates

### Known Limitations
- Completion tracking not implemented (Phase 5)
- Edit/Delete not implemented (Phase 5)
- Notifications not implemented (Phase 6)
- Streaks not implemented (Phase 5)

## v0.1.0-alpha

### Features
- Create Habit screen
- Material 3 UI
- Habit validation
- Drift persistence
- Riverpod state management
- CreateHabitUseCase
- SQLite integration
- Android APK generation

### Fixed
- Android MainActivity package mismatch

### Technical
- Providers moved to presentation layer
- HabitColor decoupled from UI
- Added unit and widget tests
