# Changelog

All notable changes to the Habit Tracker project will be documented in this file.

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

### Known Limitations
- Habit editing, archiving, and deletion deferred to Phase 6 (`v0.4.0-alpha`).
- System notifications and reminders deferred to Phase 7 (`v0.5.0-beta`).
- Native home screen widgets deferred to Phase 8.
- Gamification & XP engine deferred to Phase 9.



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
