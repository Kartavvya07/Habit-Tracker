# ==============================================================================
# 02-create-issues.ps1
# Automates the creation of all GitHub issues, linking them to milestones and labels.
# Safe to rerun multiple times (Idempotent).
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path += ";C:\Program Files\GitHub CLI"
    }
}

$Repo = "Kartavvya07/Habit-Tracker"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 2: Creating & Assigning GitHub Issues        " -ForegroundColor Cyan
Write-Host "  Repository: $Repo                                 " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Fetch milestones map from GitHub API
Write-Host "Fetching existing milestones..." -ForegroundColor Yellow
$MilestonesJson = gh api repos/$Repo/milestones?state=all 2>$null | Out-String
$Milestones = @()
if ($MilestonesJson) {
    try {
        $Milestones = $MilestonesJson | ConvertFrom-Json
    } catch {
        $Milestones = @()
    }
}

# Helper to resolve exact milestone title for Phase N
function Get-MilestoneTitle ($PhaseNumber) {
    foreach ($m in $Milestones) {
        if ($m.title -like "Phase $PhaseNumber - *" -or $m.title -like "Phase ${PhaseNumber}:*" -or $m.title -like "Phase $PhaseNumber *") {
            return $m.title
        }
    }
    return $null
}

# Fetch existing issues to prevent duplicates
Write-Host "Fetching existing issues..." -ForegroundColor Yellow
$ExistingIssuesJson = gh issue list --repo $Repo --limit 500 --state all --json number,title,milestone,labels 2>$null | Out-String
$ExistingIssues = @()
if ($ExistingIssuesJson) {
    try {
        $ExistingIssues = $ExistingIssuesJson | ConvertFrom-Json
    } catch {
        $ExistingIssues = @()
    }
}

# Assign pre-existing legacy issues (#1 to #7) to Phase 2
$LegacyAssignments = @{
    1 = @{ phase = 2; label = "architecture" };
    2 = @{ phase = 2; label = "architecture" };
    3 = @{ phase = 2; label = "database" };
    4 = @{ phase = 2; label = "database" };
    5 = @{ phase = 2; label = "database" };
    6 = @{ phase = 2; label = "testing" };
    7 = @{ phase = 2; label = "documentation" }
}

foreach ($legId in $LegacyAssignments.Keys) {
    $legItem = $LegacyAssignments[$legId]
    $mTitle = Get-MilestoneTitle -PhaseNumber $legItem.phase
    $lbl = $legItem.label
    if ($mTitle) {
        gh issue edit $legId --repo $Repo --milestone $mTitle --add-label $lbl 2>$null
    } else {
        gh issue edit $legId --repo $Repo --add-label $lbl 2>$null
    }
}

# Master Issue Definition List (Refactored Clean Architecture Order & Labels)
$Issues = @(
    # Phase 1 (Completed Historical)
    @{ phase = 1; title = "Initialize Flutter Project & Architecture"; desc = "Set up Clean Architecture feature-first folders and pubspec constraints."; acceptance = "Builds cleanly across platforms."; priority = "High"; labels = @("architecture"); effort = "S" },
    @{ phase = 1; title = "Implement Design Tokens & M3 Theme"; desc = "Create AppColors, AppRadius, AppSpacing, AppTypography, and AppTheme."; acceptance = "Themes validate M3 specs and token colors."; priority = "High"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 1; title = "Configure GoRouter & Riverpod Setup"; desc = "Initialize GoRouter navigation setup and ProviderContainer root."; acceptance = "Router and Riverpod providers resolve error-free."; priority = "High"; labels = @("architecture", "riverpod"); effort = "M" },
    @{ phase = 1; title = "Initialize Drift SQLite Engine & Logging"; desc = "Create AppDatabase, platform connection, and appDatabaseProvider."; acceptance = "SQLite opens cleanly and database provider resolves."; priority = "High"; labels = @("database"); effort = "M" },

    # Phase 2 (Completed Historical)
    @{ phase = 2; title = "Define Core Domain Entities"; desc = "Create Habit immutable entity using @freezed and enums."; acceptance = "Enforces value types, default values & equality."; priority = "High"; labels = @("domain", "architecture"); effort = "M" },
    @{ phase = 2; title = "Implement Drift Database Tables"; desc = "Define HabitsTable schema in Drift with auto-incrementing ID / UUID."; acceptance = "Schema generates cleanly with indexes & types."; priority = "High"; labels = @("database"); effort = "L" },
    @{ phase = 2; title = "Implement Data Mappers & DTOs"; desc = "Write bidirectional HabitMapper between Drift rows and Domain entities."; acceptance = "100% test coverage on entity-row transformation."; priority = "High"; labels = @("database", "repository"); effort = "M" },
    @{ phase = 2; title = "Implement Habit Repository"; desc = "Implement DriftHabitRepository wrapping Drift queries."; acceptance = "Reactive streams emit live updates upon database mutations."; priority = "High"; labels = @("repository", "database"); effort = "L" },
    @{ phase = 2; title = "Repository Unit & Integration Tests"; desc = "Write mock and in-memory SQLite unit tests for repository CRUD methods."; acceptance = "All CRUD operations pass integration tests."; priority = "High"; labels = @("testing", "repository"); effort = "L" },

    # Phase 3 (Completed Historical)
    @{ phase = 3; title = "Domain Use Cases & Riverpod State Notifier"; desc = "Implement CreateHabitUseCase, UpdateHabitUseCase, DeleteHabitUseCase, and CreateHabitNotifier."; acceptance = "Manages validation, form state, and persistence cleanly."; priority = "High"; labels = @("usecase", "riverpod"); effort = "L" },
    @{ phase = 3; title = "Create Habit Screen & Form Components"; desc = "Build CreateHabitScreen with custom ColorSelector and IconSelector widgets."; acceptance = "Responsive UI conforming to Material 3 design tokens."; priority = "High"; labels = @("ui"); effort = "L" },

    # Phase 4 (Completed Historical)
    @{ phase = 4; title = "Repository Reactive Read Layer"; desc = "Implement watchHabits() in HabitRepository emitting Stream<List<Habit>> ordered by createdAt DESC."; acceptance = "Streams live updates from Drift database reactively."; priority = "High"; labels = @("repository", "database"); effort = "M" },
    @{ phase = 4; title = "Riverpod StreamProvider Integration"; desc = "Expose habitsStreamProvider wrapping watchHabits()."; acceptance = "Automatically updates downstream providers on DB mutations."; priority = "High"; labels = @("riverpod", "architecture"); effort = "M" },
    @{ phase = 4; title = "Dashboard State Management"; desc = "Design DashboardState sealed class and dashboardProvider."; acceptance = "Transforms repository stream into presentation states with 100% tests."; priority = "High"; labels = @("riverpod", "architecture"); effort = "M" },
    @{ phase = 4; title = "Dashboard UI & Habit Cards"; desc = "Implement DashboardScreen UI consuming dashboardProvider, habit card widgets, loading/empty states, and FAB navigation."; acceptance = "Renders habits feed reactively with Material 3 cards."; priority = "High"; labels = @("ui", "ux"); effort = "L" },

    # Phase 5 – Habit Loop & Streak Engine (v0.3.0-alpha)
    @{ phase = 5; title = "P5-01 Habit Log Schema & Drift Migration"; desc = "Define HabitLogsTable in Drift, HabitLog domain entity, and bidirectional HabitLogMapper."; acceptance = "Compiles cleanly, auto-generates schema via build_runner, supports index on (habit_id, target_date)."; priority = "High"; labels = @("database", "architecture"); effort = "S" },
    @{ phase = 5; title = "P5-02 Habit Log Repository Integration"; desc = "Add logProgress(), getLogsForHabit(), watchTodayLogs(), deleteLog() to HabitRepository & DriftHabitRepository."; acceptance = "Log operations update database reactively and emit updated log streams."; priority = "High"; labels = @("repository", "database"); effort = "S" },
    @{ phase = 5; title = "P5-03 Habit Log & Streak Use Cases"; desc = "Implement LogHabitProgressUseCase and CalculateStreakUseCase."; acceptance = "Correctly calculates streaks respecting custom frequencies and missing days."; priority = "High"; labels = @("usecase", "domain"); effort = "M" },
    @{ phase = 5; title = "P5-04 Daily Completion & Streak Riverpod Providers"; desc = "Build todayCompletionsProvider, habitLogsStreamProvider, and streakProvider."; acceptance = "Providers recompute reactively whenever a habit log entry is added or removed."; priority = "High"; labels = @("riverpod", "architecture"); effort = "S" },
    @{ phase = 5; title = "P5-05 Numeric & Timer Progress Logging Modals"; desc = "Build NumericProgressBottomSheet and TimerProgressBottomSheet with live countdown/stopwatch."; acceptance = "Accepts numeric/timer input and correctly logs progress values."; priority = "High"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 5; title = "P5-06 Boolean Quick Completion Toggle UI"; desc = "Add one-tap completion button/checkbox on HabitCard with optimistic state update and haptic feedback."; acceptance = "Tapping completion toggle instantly updates UI state and persists log to database."; priority = "High"; labels = @("ui", "ux"); effort = "S" },
    @{ phase = 5; title = "P5-07 Vacation Mode & Streak Protection Engine"; desc = "Create VacationModeNotifier, vacationModeProvider, and streak protection logic."; acceptance = "Active Vacation Mode freezes streak decay without breaking streaks."; priority = "Medium"; labels = @("domain", "feature"); effort = "S" },
    @{ phase = 5; title = "P5-08 Dashboard Integration & Streak Badges"; desc = "Render active streak flame badges and progress bars on HabitCard and Dashboard header."; acceptance = "Displays current streak and daily progress ring accurately on UI."; priority = "High"; labels = @("ui", "ux"); effort = "S" },
    @{ phase = 5; title = "P5-09 Habit Loop & Streak Unit & Widget Tests"; desc = "Write unit tests for streak calculation, logging use cases, and widget tests for logging UI."; acceptance = "100% pass rate across all new unit and widget tests."; priority = "High"; labels = @("testing"); effort = "M" },
    @{ phase = 5; title = "P5-10 Release & Verification"; desc = "Perform milestone verification (analyze, test, QA), update CURRENT_PHASE.md, tag v0.3.0-alpha, build APK."; acceptance = "0 analyze warnings, 100% test pass rate, release APK built, git tag v0.3.0-alpha created."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 6 – Habit Management (Edit, Delete, Archive) (v0.4.0-alpha)
    @{ phase = 6; title = "P6-01 Edit & Archive Domain Use Cases"; desc = "Implement UpdateHabitDetailsUseCase, ArchiveHabitUseCase, and DeleteHabitWithLogsUseCase."; acceptance = "Enforces validation rules and handles cascading deletion of habit logs."; priority = "High"; labels = @("usecase", "domain"); effort = "S" },
    @{ phase = 6; title = "P6-02 Repository Edit, Archive & Deletion Queries"; desc = "Extend DriftHabitRepository with updateHabit(), archiveHabit(), and deleteHabitAndLogs()."; acceptance = "Queries execute transactionally to prevent orphaned database records."; priority = "High"; labels = @("repository", "database"); effort = "S" },
    @{ phase = 6; title = "P6-03 Edit Habit Riverpod Notifier & State"; desc = "Create EditHabitNotifier and editHabitProvider pre-populated with existing habit fields."; acceptance = "Pre-loads habit parameters into form state and dispatches valid updates."; priority = "High"; labels = @("riverpod", "architecture"); effort = "S" },
    @{ phase = 6; title = "P6-04 Edit Habit Screen UI"; desc = "Build EditHabitScreen sharing M3 form controls, color selector, icon selector, and delete dialog."; acceptance = "Loads existing parameters, allows modifications, navigates back on save."; priority = "High"; labels = @("ui"); effort = "M" },
    @{ phase = 6; title = "P6-05 Swipe-to-Edit & Swipe-to-Delete Dashboard Actions"; desc = "Wrap HabitCard in dismissible swipe actions for quick edit, archive, and delete triggers."; acceptance = "Swiping reveals action buttons with safety delete confirmation dialog."; priority = "High"; labels = @("ui", "ux"); effort = "S" },
    @{ phase = 6; title = "P6-06 Archived Habits Management Screen"; desc = "Create ArchivedHabitsScreen listing archived habits with restore and permanent delete options."; acceptance = "Lists archived habits and un-archiving restores habit to active feed."; priority = "Medium"; labels = @("ui"); effort = "S" },
    @{ phase = 6; title = "P6-07 Habit Management Unit & Widget Tests"; desc = "Write unit tests for management use cases and widget tests for Edit & Archive screens."; acceptance = "100% test pass rate across habit management suite."; priority = "High"; labels = @("testing"); effort = "M" },
    @{ phase = 6; title = "P6-08 Release & Verification"; desc = "Run flutter analyze, flutter test, manual QA, update docs, tag v0.4.0-alpha, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK generated, GitHub release published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 7 – Notification & Reminder Engine (v0.5.0-beta)
    @{ phase = 7; title = "P7-01 Notification Service Interface & Plugin Wrapper"; desc = "Create NotificationService interface and LocalNotificationServiceImpl over flutter_local_notifications."; acceptance = "Initializes notification permissions and channels cleanly on Android & iOS."; priority = "High"; labels = @("notifications"); effort = "S" },
    @{ phase = 7; title = "P7-02 Habit Reminder Scheduling Domain Engine"; desc = "Create ScheduleHabitRemindersUseCase and CancelHabitRemindersUseCase mapping habit times to exact local alarms."; acceptance = "Correctly computes next alarm trigger timestamp respecting habit frequency."; priority = "High"; labels = @("notifications", "usecase"); effort = "M" },
    @{ phase = 7; title = "P7-03 Interactive Notification Action Handlers"; desc = "Register action buttons ('Complete', 'Snooze 15m') directly in notification payload."; acceptance = "Tapping notification action logs progress without launching full app UI."; priority = "High"; labels = @("notifications", "ux"); effort = "M" },
    @{ phase = 7; title = "P7-04 Android BOOT_COMPLETED & Timezone Recovery"; desc = "Register Android BroadcastReceiver for BOOT_COMPLETED and TIMEZONE_CHANGED."; acceptance = "Scheduled alarms auto-restore upon device reboot and timezone changes."; priority = "High"; labels = @("notifications", "architecture"); effort = "S" },
    @{ phase = 7; title = "P7-05 Reminder Settings & Time Picker UI Integration"; desc = "Build ReminderTimePicker UI and wire to habit creation/editing state notifier."; acceptance = "Allows user to set reminder times per habit and toggle global notifications."; priority = "High"; labels = @("ui", "notifications"); effort = "S" },
    @{ phase = 7; title = "P7-06 Battery Optimization Onboarding Dialog"; desc = "Build OEM battery guidance dialog detecting background killers (Xiaomi, Samsung) and deep-linking settings."; acceptance = "Detects restriction status and guides user with whitelist instructions."; priority = "Medium"; labels = @("notifications", "ux"); effort = "S" },
    @{ phase = 7; title = "P7-07 Notification Unit & Mock Integration Tests"; desc = "Write unit tests for alarm calculation math, payload parsing, and time picker UI."; acceptance = "100% test pass rate across notification test suite."; priority = "High"; labels = @("testing"); effort = "M" },
    @{ phase = 7; title = "P7-08 Release & Verification"; desc = "Run analyze, test, manual notification QA on device, tag v0.5.0-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK built, release v0.5.0-beta published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 8 – Interactive Native Home Screen Widgets (v0.6.0-beta)
    @{ phase = 8; title = "P8-01 Native Data Exporter & Shared App Group Engine"; desc = "Build WidgetDataExporter writing SQLite habit snapshots to SharedPreferences / AppGroup UserDefaults."; acceptance = "Updating habit in Flutter syncs snapshot to shared native storage instantly."; priority = "High"; labels = @("widgets", "native", "architecture"); effort = "S" },
    @{ phase = 8; title = "P8-02 Android Glance Quick-Complete Widget Scaffold"; desc = "Create Jetpack Compose Glance widget in Kotlin displaying today's active habits."; acceptance = "Widget renders on Android home screen displaying live habit titles and check states."; priority = "High"; labels = @("widgets", "native"); effort = "M" },
    @{ phase = 8; title = "P8-03 Android Glance Action Receiver & Database Sync"; desc = "Implement Glance ActionCallback in Kotlin handling tap events to update SQLite database."; acceptance = "Tapping widget checkbox updates completion state in background without launching app."; priority = "High"; labels = @("widgets", "native"); effort = "M" },
    @{ phase = 8; title = "P8-04 iOS WidgetKit SwiftUI Interactive Widget"; desc = "Create Swift WidgetKit interactive widget targeting iOS 17+ using SwiftUI."; acceptance = "Renders native SwiftUI widget on iOS home screen reading AppGroup data."; priority = "High"; labels = @("widgets", "native"); effort = "M" },
    @{ phase = 8; title = "P8-05 iOS WidgetKit AppIntent Direct Completion Handler"; desc = "Implement Swift AppIntent updating AppGroup UserDefaults and reloading widget timeline."; acceptance = "Tapping habit on iOS widget toggles state cleanly via AppIntent."; priority = "High"; labels = @("widgets", "native"); effort = "M" },
    @{ phase = 8; title = "P8-06 Native Widget Configuration & Size Variants"; desc = "Implement Small (1x1), Medium (2x2), and Large (4x2) widget size layouts."; acceptance = "Widgets scale gracefully across all system widget dimensions."; priority = "Medium"; labels = @("widgets", "ui"); effort = "S" },
    @{ phase = 8; title = "P8-07 Widget Data Exporter & Platform Channel Tests"; desc = "Write unit tests for data serialization and platform channel payload export."; acceptance = "100% test pass rate on data exporter."; priority = "High"; labels = @("testing"); effort = "S" },
    @{ phase = 8; title = "P8-08 Release & Verification"; desc = "Run analyze, test, manual widget QA, update docs, tag v0.6.0-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK generated, GitHub release published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 9 – Gamification Engine (v0.7.0-beta)
    @{ phase = 9; title = "P9-01 Gamification Domain Models & Drift Tables"; desc = "Create UserProgressTable and QuestsTable in Drift, UserProgress and Quest domain entities."; acceptance = "Drift schema auto-generates cleanly, backing level, XP, and quest records."; priority = "High"; labels = @("database", "domain", "gamification"); effort = "S" },
    @{ phase = 9; title = "P9-02 XP Calculation & Leveling Engine Use Cases"; desc = "Create CalculateXpGainUseCase and AwardXpUseCase with dynamic level scaling formulas."; acceptance = "Accurately awards XP for habits and triggers level-up threshold events."; priority = "High"; labels = @("usecase", "gamification"); effort = "S" },
    @{ phase = 9; title = "P9-03 Quest Lines & Challenge Tracker Engine"; desc = "Build QuestTrackerUseCase evaluating daily and weekly quest progression."; acceptance = "Automatically updates quest progress and claims bonus XP rewards."; priority = "High"; labels = @("gamification", "usecase"); effort = "M" },
    @{ phase = 9; title = "P9-04 Gamification Riverpod State Providers"; desc = "Build userProgressProvider and activeQuestsProvider emitting live XP and quest status."; acceptance = "Providers recompute reactively whenever XP is awarded or quest state changes."; priority = "High"; labels = @("riverpod", "architecture"); effort = "S" },
    @{ phase = 9; title = "P9-05 User Profile & Quest Hub Screen UI"; desc = "Build ProfileScreen featuring Level progress bar, XP badges, active quests list, and level-up modal."; acceptance = "Renders user stats, level progress, and active quests cleanly conforming to M3."; priority = "High"; labels = @("ui", "gamification"); effort = "M" },
    @{ phase = 9; title = "P9-06 Interactive Skill Tree & Cosmetic Unlocks"; desc = "Build SkillTreeScreen allowing users to spend skill points to unlock custom app themes and icons."; acceptance = "Unlocked cosmetic nodes immediately unlock new theme options in Settings."; priority = "Medium"; labels = @("ui", "gamification"); effort = "M" },
    @{ phase = 9; title = "P9-07 Achievement Badges & Regional Milestones"; desc = "Implement BadgeRepository awarding vector badges for long-term consistency milestones."; acceptance = "Unlocked badges render with vector artwork and offer shareable summary card."; priority = "Low"; labels = @("ui", "gamification"); effort = "S" },
    @{ phase = 9; title = "P9-08 Gamification Engine Unit & Widget Tests"; desc = "Write unit tests for XP math, leveling curves, quest evaluations, and widget tests."; acceptance = "100% pass rate across gamification suite."; priority = "High"; labels = @("testing"); effort = "M" },
    @{ phase = 9; title = "P9-09 Release & Verification"; desc = "Run analyze, test, manual QA, update docs, tag v0.7.0-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK built, release v0.7.0-beta published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 10 – Analytics & Health Integrations (v0.8.0-beta)
    @{ phase = 10; title = "P10-01 Analytics SQL Aggregation Queries & Repository"; desc = "Implement optimized Drift SQLite queries for completion rates, monthly counts, and trends."; acceptance = "Aggregation queries execute in <50ms over 10,000+ log rows."; priority = "High"; labels = @("database", "repository", "analytics"); effort = "S" },
    @{ phase = 10; title = "P10-02 Analytics Aggregation Use Cases"; desc = "Implement GetHabitStatsUseCase and GetOverallAnalyticsUseCase compiling analytics DTOs."; acceptance = "Returns clean analytics DTOs (completion rate, best day, trend, monthly grid)."; priority = "High"; labels = @("usecase", "analytics"); effort = "S" },
    @{ phase = 10; title = "P10-03 Interactive GitHub-Style Heatmap Grid Component"; desc = "Build HabitHeatmapWidget with color-coded contribution grid and tap-to-inspect modal."; acceptance = "Renders color-coded grid matching theme primary tokens with interactive tooltips."; priority = "High"; labels = @("ui", "analytics"); effort = "M" },
    @{ phase = 10; title = "P10-04 Trend & Correlation Charts (CustomPainter)"; desc = "Build TrendChartWidget visualizing target vs actual metrics using Flutter CustomPainter."; acceptance = "Smooth line/bar chart rendering with touch inspection tooltips."; priority = "Medium"; labels = @("ui", "analytics"); effort = "M" },
    @{ phase = 10; title = "P10-05 Analytics Screen Presentation Layer"; desc = "Build AnalyticsScreen assembling stat cards, habit selector, heatmap grid, and trend graphs."; acceptance = "Displays overall analytics dashboard with filter dropdown to inspect habits."; priority = "High"; labels = @("ui"); effort = "M" },
    @{ phase = 10; title = "P10-06 Health Connect & HealthKit Data Bridge"; desc = "Implement HealthIntegrationService connecting to Android Health Connect and iOS HealthKit."; acceptance = "Fetches daily step counts and sleep duration cleanly with permission authorization."; priority = "Medium"; labels = @("analytics", "native"); effort = "M" },
    @{ phase = 10; title = "P10-07 Automated Health Sync Background Worker"; desc = "Build SyncHealthMetricsUseCase auto-completing health habits when fitness targets are met."; acceptance = "Reaching step goals automatically completes linked habit in database."; priority = "Medium"; labels = @("analytics", "usecase"); effort = "S" },
    @{ phase = 10; title = "P10-08 Analytics & Health Integration Tests"; desc = "Write unit tests for SQL aggregations, heatmap mapping, health sync, and widget tests."; acceptance = "100% pass rate across analytics suite."; priority = "High"; labels = @("testing"); effort = "M" },
    @{ phase = 10; title = "P10-09 Release & Verification"; desc = "Run analyze, test, manual QA, update docs, tag v0.8.0-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK built, release v0.8.0-beta published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 11 – Cloud Sync & Authentication (v0.9.0-beta)
    @{ phase = 11; title = "P11-01 Authentication Domain & Security Layer"; desc = "Implement AuthRepository supporting anonymous login, OAuth, and FlutterSecureStorage tokens."; acceptance = "Authenticates user and securely persists JWT session tokens across app restarts."; priority = "High"; labels = @("sync", "security", "domain"); effort = "S" },
    @{ phase = 11; title = "P11-02 Local-First Delta Sync Schema & Tracker"; desc = "Configure local-first database replication tables and sync engine mutation event tracker."; acceptance = "Local DB mutations generate delta payloads ready for remote push."; priority = "High"; labels = @("sync", "database", "architecture"); effort = "M" },
    @{ phase = 11; title = "P11-03 Sync Engine Client & Replication Transport"; desc = "Implement SyncEngineClient streaming delta revision packages between local DB and remote server."; acceptance = "Establishes bi-directional delta streaming transport with connection handling."; priority = "High"; labels = @("sync", "architecture"); effort = "M" },
    @{ phase = 11; title = "P11-04 Conflict Resolution Engine (LWW / CRDT)"; desc = "Implement ConflictResolver using Last-Write-Wins (LWW) and field-level CRDT rules."; acceptance = "Correctly merges simultaneous offline updates without data loss."; priority = "High"; labels = @("sync", "domain", "database"); effort = "M" },
    @{ phase = 11; title = "P11-05 Offline Mutation Queue & Retry Engine"; desc = "Build OfflineMutationQueue with exponential backoff retry mechanism."; acceptance = "Offline mutations queue up locally and auto-flush when connection restores."; priority = "High"; labels = @("sync", "architecture"); effort = "M" },
    @{ phase = 11; title = "P11-06 Sync Status Bar & Connection Indicator UI"; desc = "Build SyncStatusWidget displaying 'Synced', 'Syncing...', or 'Offline Mode' status."; acceptance = "Updates icon and color dynamically based on sync provider state."; priority = "Medium"; labels = @("ui", "sync"); effort = "S" },
    @{ phase = 11; title = "P11-07 Account & Sync Management Settings Screen"; desc = "Build AccountSettingsScreen with login/logout buttons, force sync CTA, and data export."; acceptance = "Allows user to log in/out, view sync status, and trigger manual sync."; priority = "High"; labels = @("ui", "sync"); effort = "S" },
    @{ phase = 11; title = "P11-08 Auth & Sync Integration Unit Tests"; desc = "Write unit tests for conflict resolution, offline queue retries, and auth persistence."; acceptance = "100% pass rate across sync test suite."; priority = "High"; labels = @("testing", "sync"); effort = "M" },
    @{ phase = 11; title = "P11-09 Release & Verification"; desc = "Run analyze, test, manual simulated offline/online QA, tag v0.9.0-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK built, release v0.9.0-beta published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 12 – AI Coach & Smart Features (v0.9.5-beta)
    @{ phase = 12; title = "P12-01 Local Behavioral Friction Analyzer"; desc = "Implement FrictionAnalyzerEngine analyzing completion logs to highlight friction points."; acceptance = "Identifies missed habit patterns locally without external server transmission."; priority = "Medium"; labels = @("ai", "analytics", "usecase"); effort = "S" },
    @{ phase = 12; title = "P12-02 Optimal Reminder Timing Recommendation Engine"; desc = "Implement OptimalTimingEngine computing completion timestamps to suggest ideal reminder times."; acceptance = "Recommends time adjustments to maximize completion probability."; priority = "Medium"; labels = @("ai", "notifications", "usecase"); effort = "S" },
    @{ phase = 12; title = "P12-03 Natural Language Processing (NLP) Habit Parser"; desc = "Implement NlpHabitParser extracting title, frequency, target value, and target time from text."; acceptance = "Accurately parses natural language strings into structured habit fields."; priority = "Medium"; labels = @("ai", "domain"); effort = "M" },
    @{ phase = 12; title = "P12-04 NLP Input Interface in Create Habit Screen"; desc = "Add natural language text/voice bar at top of CreateHabitScreen auto-populating controls."; acceptance = "Typing natural text auto-fills title, frequency, target, and reminder controls."; priority = "Medium"; labels = @("ui", "ai"); effort = "S" },
    @{ phase = 12; title = "P12-05 Monthly AI Coach Insights UI Components"; desc = "Build AiCoachInsightCard displaying actionable behavioral recommendations on Dashboard."; acceptance = "Displays personalized insight cards with dismiss and apply actions."; priority = "Low"; labels = @("ui", "ai"); effort = "S" },
    @{ phase = 12; title = "P12-06 AI Coach Rules & Parser Unit Tests"; desc = "Write unit tests for NLP parsing edge cases, friction rules, and timing optimization."; acceptance = "100% pass rate across AI Coach test suite."; priority = "High"; labels = @("testing", "ai"); effort = "M" },
    @{ phase = 12; title = "P12-07 Release & Verification"; desc = "Run analyze, test, manual QA, update docs, tag v0.9.5-beta, build APK."; acceptance = "0 analyze errors, 100% tests pass, release APK built, release v0.9.5-beta published."; priority = "High"; labels = @("release", "documentation"); effort = "S" },

    # Phase 13 – Performance, Accessibility & Production Release (v1.0.0)
    @{ phase = 13; title = "P13-01 Comprehensive Provider & Use Case Unit Test Suite"; desc = "Expand test suite to ensure 100% code coverage across all domain use cases and state notifiers."; acceptance = "flutter test --coverage passes with 100% coverage on domain and state layers."; priority = "High"; labels = @("testing", "riverpod", "usecase"); effort = "M" },
    @{ phase = 13; title = "P13-02 Golden UI Test Suite for Light & Dark Themes"; desc = "Write golden visual regression tests for Dashboard, Create Habit, Analytics, and Settings screens."; acceptance = "Golden image comparison passes with 0 pixel mismatch across light/dark themes."; priority = "High"; labels = @("testing", "ui"); effort = "M" },
    @{ phase = 13; title = "P13-03 Rendering Performance & RepaintBoundary Optimization"; desc = "Audit widget trees with Flutter Profiler, wrap heavy list items in RepaintBoundary."; acceptance = "Zero dropped frames during fast scrolling on baseline mobile hardware."; priority = "High"; labels = @("performance", "ui"); effort = "M" },
    @{ phase = 13; title = "P13-04 Accessibility & Screen Reader (TalkBack/VoiceOver) Audit"; desc = "Audit UI for WCAG 2.1 AA compliance: TalkBack/VoiceOver compatibility, Semantics labels on custom widgets, minimum 48x48dp touch targets, 4.5:1 color contrast, keyboard focus order."; acceptance = "Full screen reader support, 48x48dp minimum touch target compliance, 4.5:1 contrast, and passing semantics test checklist."; priority = "Medium"; labels = @("accessibility", "ui", "ux"); effort = "S" },
    @{ phase = 13; title = "P13-05 Production Release Configuration & App Bundle Build"; desc = "Configure release signing keys, obfuscation symbols, ProGuard rules, build Android App Bundle."; acceptance = "Generates signed, obfuscated production binaries ready for Play Store & App Store."; priority = "High"; labels = @("architecture", "release"); effort = "M" },
    @{ phase = 13; title = "P13-06 Final Release & Production Launch (v1.0.0)"; desc = "Execute final verification matrix, tag v1.0.0, publish GitHub release, update canonical docs."; acceptance = "05-verify-github.ps1 returns 100% PASS matrix; v1.0.0 published on GitHub."; priority = "High"; labels = @("release", "documentation"); effort = "S" }
)

$CreatedCount = 0
$UpdatedCount = 0
$SkippedCount = 0

foreach ($Item in $Issues) {
    $Title = $Item.title
    $Phase = $Item.phase
    $MilestoneTitle = Get-MilestoneTitle -PhaseNumber $Phase
    
    # Construct issue body
    $Body = @"
## Description
$($Item.desc)

## Acceptance Criteria
$($Item.acceptance)

## Governance Metadata
- **Priority**: $($Item.priority)
- **Effort**: $($Item.effort)
- **Phase**: Phase $Phase
"@

    # Check if issue already exists
    $Match = $ExistingIssues | Where-Object { $_.title -ieq $Title }

    if ($null -ne $Match) {
        $IssueNumber = $Match.number
        Write-Host "  [UPDATE] Issue #$IssueNumber ('$Title') setting Milestone '$MilestoneTitle' & Labels..." -ForegroundColor Cyan
        
        $EditArgs = @("issue", "edit", "$IssueNumber", "--repo", $Repo)
        if ($MilestoneTitle) {
            $EditArgs += "--milestone"
            $EditArgs += $MilestoneTitle
        }
        foreach ($lbl in $Item.labels) {
            $EditArgs += "--add-label"
            $EditArgs += $lbl
        }
        
        gh @EditArgs 2>$null
        $UpdatedCount++
    } else {
        Write-Host "  [CREATE] Creating issue '$Title' (Phase $Phase, Milestone '$MilestoneTitle')..." -ForegroundColor Green
        
        $CreateArgs = @("issue", "create", "--repo", $Repo, "--title", $Title, "--body", $Body)
        if ($MilestoneTitle) {
            $CreateArgs += "--milestone"
            $CreateArgs += $MilestoneTitle
        }
        foreach ($lbl in $Item.labels) {
            $CreateArgs += "--label"
            $CreateArgs += $lbl
        }

        gh @CreateArgs 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [SUCCESS] Created issue '$Title'" -ForegroundColor Green
            $CreatedCount++
        } else {
            Write-Host "  [WARNING] Failed to create issue '$Title'" -ForegroundColor Yellow
        }
    }
}

Write-Host "----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Issues Summary: Created: $CreatedCount, Updated: $UpdatedCount, Skipped: $SkippedCount" -ForegroundColor Green
