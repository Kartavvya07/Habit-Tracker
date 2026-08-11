# Changelog

All notable changes to the Habit Tracker project will be documented in this file.

## v0.5.0-beta

### Features
- **Local Notifications & Reminders Engine**: Integrated `flutter_local_notifications: ^17.1.2` and `timezone: ^0.9.3` for high-precision local exact alarms on Android (`habit_reminders` M3 notification channel).
- **Drift Database Schema v3 Migration**: Extended `habits` table with `reminder_time` (`TEXT`) and `is_reminder_enabled` (`BOOLEAN`) columns with automatic schema migration.
- **Deterministic Notification Scheduling Engine**: `ScheduleHabitRemindersUseCase` with deterministic notification ID hashing (`getNotificationId`), exact `TZDateTime` calculation (`computeNextReminderDateTime`), weekly/monthly day-of-week/day-of-month frequency math, and Vacation Mode suppression.
- **Habit Lifecycle Notification Triggers**: Integrated notification scheduling & cancellation into habit CRUD lifecycle (`CreateHabitUseCase`, `UpdateHabitUseCase`, `ArchiveHabitUseCase`, `RestoreHabitUseCase`, `DeleteHabitUseCase`).
- **Interactive Notification Action Buttons**:
  - **Mark Complete**: Top-level background callback (`NotificationActionHandler`) logging habit progress for today directly to Drift SQLite when tapped from notification drawer.
  - **Snooze 15m**: Schedules a 15-minute one-off notification reminder.
- **Reboot & Timezone Recovery Engine**: `ReconcileRemindersUseCase` automatically restoring all active exact habit alarms on app launch and system startup (`RECEIVE_BOOT_COMPLETED`).
- **Reminder Time Picker Widget**: M3 `ReminderTimePicker` form widget integrated into `CreateHabitScreen` and `EditHabitScreen` with toggle switch and M3 `showTimePicker` dialog.
- **OEM Battery Optimization Onboarding UX**: Dedicated M3 `BatteryOptimizationDialog` in `SettingsScreen` providing step-by-step guidance for Xiaomi MIUI, Samsung OneUI, and Huawei EMUI background battery restrictions.

### Quality & Engineering
- **Desugaring Enabled**: Enabled Android Core Library Desugaring (`desugar_jdk_libs:2.1.4`) for Java 8+ time API compatibility.
- **Static Analysis**: 0 errors / 0 warnings (`flutter analyze`).
- **Test Suite Coverage**: 100% test pass rate across 220 unit, widget, and mock integration tests (`flutter test`).
- **Android Compilation**: Successfully compiled debug APK (`app-debug.apk`).

---

## v0.4.0-alpha

### Features
- **Habit Editing Engine**: Complete habit editing capabilities via `EditHabitScreen` pre-populated with existing habit title, description, frequency, habit type, numeric target count, target duration, color token, and icon avatar.
- **Form State Pre-Population**: `EditHabitNotifier` extending `AutoDisposeFamilyNotifier<EditHabitState, Habit>` (`editHabitProvider`) for instant, zero-spin form initialization.
- **Safe Archive & Restore Workflow**: Added `ArchiveHabitUseCase` and `RestoreHabitUseCase` moving active habits out of the daily dashboard feed to `ArchivedHabitsScreen` to prevent accidental log deletion.
- **Archived Habits Management Screen**: Dedicated screen (`ArchivedHabitsScreen`) listing archived habits reactively via `watchArchivedHabits()`, featuring empty states, 1-tap Restore actions (`RestoreHabitUseCase`), and Permanent Delete actions with native M3 `AlertDialog` confirmation.
- **Dashboard Swipe Gestures**: `Dismissible` swipe interactions on `HabitCard` cards:
  - **Swipe Right (Start-to-End)**: Triggers quick edit navigation to `/edit-habit`.
  - **Swipe Left (End-to-Start)**: Archives the habit with an instant SnackBar **Undo** action to restore state if tapped.
- **Header Navigation**: Added Archived Habits header action button (`Icons.archive_outlined`) in `DashboardScreen` AppBar.
- **Drift DAO Architecture**: Built `HabitsDao` with dedicated accessors for active/archived queries (`watchActiveHabits()`, `watchArchivedHabits()`), updating, archiving, restoring, and deleting with foreign key cascading log deletions.

### Quality & Engineering
- **Static Analysis**: 0 warnings (`flutter analyze`).
- **Test Suite Coverage**: 100% test pass rate across 177 unit and widget tests (`flutter test`).
- **Production Build**: Generated release APK (`app-release.apk`).

---

## v0.3.0-alpha

### Features
- **Habit Loop & Progress Logging Engine**: Complete SQLite schema migration (`HabitLogsTable`) supporting atomic progress logging for boolean, numeric, and timer habits.
- **Streak Calculation Engine**: Pure domain algorithm (`CalculateStreakUseCase`) calculating current streak, best streak, completion percentages, leap years, timezone boundaries, and Vacation Mode protections.
- **Reactive Riverpod Architecture**: Continuous Drift SQLite streams (`watchTodayLogs`) bound directly to Riverpod `todayLogsStreamProvider`, `todayCompletionsProvider`, `streakProvider`, and `timerCountdownProvider`.
- **Numeric Progress Logging Sheet**: Interactive modal (`NumericProgressBottomSheet`) featuring Material 3 `Slider`, visual progress bar (`55 / 100`), 4-way input synchronization (Slider, Stepper, Quick Chips, Direct Text), and Goal Reached badge.
- **Android-Style Countdown Timer**: Real-time timer (`TimerProgressBottomSheet`) counting down from target duration to zero (`30:00` → `00:00`), auto-completing progress upon reaching zero, and managing control states (`Start` → `Pause/Reset` → `Resume/Reset`).
- **Persistent Timer Sessions Across Navigation**: Refactored `timerCountdownProvider` to non-autoDispose Riverpod `NotifierProviderFamily` using timestamp delta calculations (`targetDuration - (now - startTimestamp)`). Timer state survives modal dismissals and screen navigation.
- **Live Dashboard Timer Synchronization**: Direct subscription on `HabitCard` to `timerCountdownProvider`, rendering live dashboard updates (`⏱ 14 sec remaining`, `Paused • 08:42 remaining`) without duplicate state or database overhead.
- **Single-Source Duration Formatter**: Core utility (`DurationFormatter`) providing unified clock formatting (`MM:SS` for < 1hr, `HH:MM:SS` for ≥ 1hr up to `99:59:59`) across all UI views.
- **Expanded Multi-Day Duration Picker**: Wheel scroll picker supporting hours from `0` to `99` without clock wraparound or arbitrary caps.
- **Modal Sheet Safe Area Architecture**: Re-architected modal sheets (`showModalBottomSheet` with `useSafeArea: true`) with sticky bottom primary action buttons unaffected by soft keyboards or gesture navigation bars.
- **1-Tap Boolean Quick Completion Toggle**: Optimistic UI toggle on `HabitCard` with instant visual state feedback, strikethrough animation, haptic feedback, and error state rollback.
- **Vacation Mode & Streak Protection**: Global `vacationModeProvider`, `VacationBanner`, and streak freeze protection logic preserving streaks during time off.
- **Dashboard Progress Integration**: Integrated `StreakBadge`, `DailySummaryCard`, and `CompletionRing` into `DashboardScreen`.

### Quality & Engineering
- **Static Analysis**: 0 warnings (`flutter analyze`).
- **Test Suite Coverage**: 100% test pass rate across 155 unit and widget tests (`flutter test`).
- **Physical Device Validation**: Tested and validated on physical Android device.

---

## v0.2.0-alpha

### Features
- Reactive Dashboard Screen with Material 3 design system
- Material 3 Habit Cards (`HabitCard`) displaying color accent tint, icon avatar, title, description, frequency, habit type, and target value metadata
- Live Drift SQLite stream integration via Riverpod `habitsStreamProvider` and `dashboardProvider`
- Responsive state handling for `DashboardLoading`, `DashboardEmpty`, `DashboardLoaded`, and `DashboardError` presentation states
- Automatic UI updates upon new habit creation without manual refresh
- Floating Action Button navigation to `/create-habit`
- Expanded widget test suite covering all presentation states, FAB navigation, retry error handling, and reactive stream updates

---

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
