# Phase 5 Retrospective: Habit Loop & Streak Engine

> **Project:** Habit Tracker  
> **Milestone:** Phase 5 – Habit Loop & Streak Engine (`v0.3.0-alpha`)  
> **Date:** July 29, 2026  
> **Status:** COMPLETED ✅ (137 tests passing, 0 static analysis warnings)

---

## Executive Summary

Phase 5 introduced the core interactive habit loop for the application: recording habit execution logs (`HabitLogsTable`), evaluating streak algorithms (`CalculateStreakUseCase`), protecting streaks during leave (`VacationMode`), and providing high-friction-free presentation components (`NumericProgressBottomSheet`, `TimerProgressBottomSheet`, and interactive `HabitCard` toggles).

This retrospective captures architectural successes, technical friction points during implementation and testing, and strategic adjustments for **Phase 6: Habit Management (Edit, Delete, Archive)**.

---

## 1. What Went Well

### 1.1 Architectural Decisions That Proved Effective

- **Clean Architecture Layer Isolation**:
  Maintaining strict boundaries between Data ([`DriftHabitRepository`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/data/repositories/drift_habit_repository.dart)), Domain ([`LogHabitProgressUseCase`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/domain/usecases/log_habit_progress_use_case.dart), [`CalculateStreakUseCase`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/domain/usecases/calculate_streak_use_case.dart)), and Presentation ([`habit_completion_provider.dart`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/presentation/providers/habit_completion_provider.dart)) ensured that database modifications never polluted business rules or widget state.
- **Pure Domain Entities & Freezed Immutability**:
  Entities like [`HabitLog`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/domain/entities/habit_log.dart), [`StreakInfo`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/domain/entities/streak_info.dart), and [`DailyCompletionStats`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/domain/entities/daily_completion_stats.dart) leveraged `@freezed` for value equality and immutability. This prevented state mutation bugs during complex multi-day streak calculation passes.
- **Decoupled Business Logic**:
  Placing streak rules and daily completion calculations into pure Dart use cases allowed 100% unit test coverage without requiring Flutter framework initialization or UI widget pumps.

### 1.2 Patterns to Reuse

- **Reactive Drift Stream to Riverpod Pipeline**:
  Binding Drift SQLite continuous query streams (`watchTodayLogs()`) directly to Riverpod `StreamProvider` instances ([`todayLogsStreamProvider`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/presentation/providers/habit_completion_provider.dart)) allowed presentation components to automatically reflect database changes without requiring manual refresh triggers or imperative callbacks.
- **Optimistic UI Updates with Fallback Rollback**:
  The 1-tap boolean quick-completion toggle in [`HabitCard`](file:///d:/Desktop/Habit%20Tracker/lib/features/dashboard/presentation/widgets/habit_card.dart) updates local visual state instantly alongside haptic feedback while triggering asynchronous persistence in the background. If database insertion fails, state cleanly rolls back.
- **Dedicated Progress Modals**:
  Encapsulating input validation, live stopwatch timers, and preset quick-chips inside self-contained bottom sheets ([`NumericProgressBottomSheet`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/presentation/widgets/numeric_progress_bottom_sheet.dart) and [`TimerProgressBottomSheet`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/presentation/widgets/timer_progress_bottom_sheet.dart)) kept parent screens focused solely on layout.

### 1.3 Components That Became Highly Reusable

| Component | File Path | Reuse Capability |
| :--- | :--- | :--- |
| **`StreakBadge`** | [`streak_badge.dart`](file:///d:/Desktop/Habit%20Tracker/lib/features/dashboard/presentation/widgets/streak_badge.dart) | Displays active streak counts and flame icons; auto-renders vacation freeze indicators. Reusable across cards, headers, and gamification screens. |
| **`CompletionRing`** | [`completion_ring.dart`](file:///d:/Desktop/Habit%20Tracker/lib/features/dashboard/presentation/widgets/completion_ring.dart) | Custom painter ring visualizing progress percentages. Reusable across dashboard summaries, widgets, and analytics screens. |
| **`VacationBanner`** | [`vacation_banner.dart`](file:///d:/Desktop/Habit%20Tracker/lib/features/dashboard/presentation/widgets/vacation_banner.dart) | Dismissible top banner indicating active streak protection; easily embedded in any top-level feature view. |
| **`HabitLogMapper`** | [`habit_log_mapper.dart`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/data/mappers/habit_log_mapper.dart) | Bidirectional conversion between Drift `HabitLogData` rows and domain `HabitLog` entities with normalized date handling. |

---

## 2. What Was Harder Than Expected

### 2.1 Complex Implementation Areas

> [!WARNING]
> **Streak Calculation Algorithm Edge Cases**
> Calculating streaks across non-daily custom frequencies (e.g., target days of week, target numeric thresholds), gap days, leap years, timezone shifts, and active Vacation Mode freezes required evaluating edge cases that simple day-counter algorithms miss.

- **Stopwatch Ticker State Management**:
  Managing live stopwatch timers in [`TimerProgressBottomSheet`](file:///d:/Desktop/Habit%20Tracker/lib/features/habits/presentation/widgets/timer_progress_bottom_sheet.dart) required synchronizing manual minute chip selections with active stopwatch ticks, handling pause/resume states, and preventing memory leaks upon bottom sheet dismissal.

### 2.2 Testing Challenges

- **Date/Time Dependency in Unit Tests**:
  Testing multi-day streak progression and historical log gaps in [`calculate_streak_use_case_test.dart`](file:///d:/Desktop/Habit%20Tracker/test/features/habits/domain/usecases/calculate_streak_use_case_test.dart) required careful zero-hour date normalization (`DateTime(year, month, day)`).
- **Asynchronous Stream Provider Verification**:
  Testing Riverpod `StreamProvider` reactivity required setting up in-memory SQLite Drift databases and using `ProviderContainer` listener assertions to flush microtask queues before evaluating state emissions.

### 2.3 Riverpod / Drift Interactions

- **Rebuild Optimization**:
  Preventing entire screen rebuilds when single habit log entries updated required careful scoping using `ref.watch(...select(...))` inside consumer widgets.
- **Compound Database Indexing**:
  Defining compound indexes on `(habit_id, target_date)` in [`HabitLogsTable`](file:///d:/Desktop/Habit%20Tracker/lib/core/database/tables/habit_logs_table.dart) was critical to avoid full table scans during daily log lookups.

### 2.4 Migration Pain Points

- **Schema Version Upgrade (V1 -> V2)**:
  Adding `HabitLogsTable` required updating [`AppDatabase`](file:///d:/Desktop/Habit%20Tracker/lib/core/database/app_database.dart) schema version and verifying migration strategies (`onUpgrade`) so existing stored habit entries were preserved without data loss.

---

## 3. What Should Change in Phase 6

Phase 6 focuses on **Habit Management (Edit, Delete, Archive)** (`v0.4.0-alpha`). Based on learnings from Phase 5, the following engineering refinements will be instituted:

### 3.1 Coding Conventions

1. **Standardized Date Normalization**:
   Enforce zero-hour date normalization (`DateTime.toNormalizedDate()`) across all repositories, use cases, and database queries via a core utility (`lib/core/utils/date_utils.dart`) to eliminate off-by-one date bugs.
2. **Typed Domain Failures**:
   Replace generic runtime exceptions with explicit domain failure classes (`HabitNotFoundFailure`, `DatabaseFailure`) in repository contracts.

### 3.2 Review Checklist

> [!IMPORTANT]
> **Mandatory PR Review Additions for Phase 6**
> - [ ] **Resource Cleanup**: Verify all `Timer`, `StreamSubscription`, and `AnimationController` instances have explicit `dispose()` invocations.
> - [ ] **Rebuild Scoping**: Verify `ref.watch()` calls use `.select()` where applicable.
> - [ ] **Accessibility Verification**: Verify minimum 48x48dp touch target boundaries and WCAG AA `Semantics` tags.

### 3.3 Issue Sizing

- **Decouple Data & Presentation Tasks**:
  Avoid bundling schema/repository extensions and complex UI sheets into a single oversized task. Break Phase 6 issues into distinct steps:
  - **Data/Domain**: Schema updates, repository methods, use cases.
  - **Presentation**: State providers, UI sheets/dialogs, animation flows.
- Target a maximum issue scope of **<=250 lines of code changed per issue**.

### 3.4 Testing Strategy

- **Shared `FakeClock` Test Utility**:
  Introduce a deterministic clock helper for all domain unit tests to streamline multi-day time travel assertions.
- **Golden UI Tests**:
  Introduce golden visual regression tests for core interactive widgets ([`HabitCard`](file:///d:/Desktop/Habit%20Tracker/lib/features/dashboard/presentation/widgets/habit_card.dart), edit forms, and delete confirmation dialogs).

### 3.5 Documentation Process

- **DartDoc Contracts**:
  Require standard DartDoc comments on all public repository interfaces and domain use cases specifying parameters, pre-conditions, and potential failure returns.
- **Automated QA Verification**:
  Maintain automated PowerShell verification scripts (`05-verify-github.ps1`) to run static analysis (`flutter analyze`), format checks (`dart format`), and complete test suites before tagging milestone releases.

---

## Conclusion & Phase 6 Readiness

Phase 5 successfully established a resilient, offline-first Habit Loop and Streak Engine. The codebase is well-structured, 100% covered by unit and widget tests (137 tests passing), and ready to proceed with **Phase 6: Habit Management (Edit, Delete, Archive)**.
