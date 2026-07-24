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
        if ($m.title -like "Phase $PhaseNumber - *") {
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
    Write-Host "  [UPDATE LEGACY] Assigning issue #$legId to Phase $($legItem.phase)..." -ForegroundColor Cyan
    if ($mTitle) {
        gh issue edit $legId --repo $Repo --milestone $mTitle --add-label $lbl 2>$null
    } else {
        gh issue edit $legId --repo $Repo --add-label $lbl 2>$null
    }
}

# Master Issue Definition List
$Issues = @(
    # Phase 1
    @{ phase = 1; title = "Initialize Flutter Project & Architecture"; desc = "Set up Clean Architecture feature-first folders and pubspec constraints."; acceptance = "Builds cleanly across platforms."; priority = "High"; labels = @("architecture"); effort = "S" },
    @{ phase = 1; title = "Implement Design Tokens & M3 Theme"; desc = "Create AppColors, AppRadius, AppSpacing, AppTypography, and AppTheme."; acceptance = "Themes validate M3 specs and token colors."; priority = "High"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 1; title = "Configure GoRouter & Dependency Injection"; desc = "Initialize GetIt, injectable, and GoRouter navigation setup."; acceptance = "Router and DI singletons resolve error-free."; priority = "High"; labels = @("architecture"); effort = "M" },
    @{ phase = 1; title = "Initialize Drift SQLite Engine & Logging"; desc = "Create AppDatabase, platform connection, and ProductionLogger."; acceptance = "SQLite opens and BLoC observer logs lifecycle events."; priority = "High"; labels = @("database"); effort = "M" },

    # Phase 2
    @{ phase = 2; title = "Define Core Domain Entities"; desc = "Create Habit and HabitLog immutable models using freezed."; acceptance = "Enforces value types, default values & equality."; priority = "High"; labels = @("architecture"); effort = "M" },
    @{ phase = 2; title = "Implement Drift Database Tables"; desc = "Define HabitsTable and HabitLogsTable schemas in Drift."; acceptance = "Schema generates cleanly with indexes & foreign keys."; priority = "High"; labels = @("database"); effort = "L" },
    @{ phase = 2; title = "Implement Data Mappers & DTOs"; desc = "Write bidirectional mappers between Drift rows and Domain entities."; acceptance = "100% test coverage on entity-row transformation."; priority = "High"; labels = @("database"); effort = "M" },
    @{ phase = 2; title = "Implement Habit Repository"; desc = "Implement HabitRepository interface wrapping Drift DAOs."; acceptance = "Reactive streams emit live updates upon database mutations."; priority = "High"; labels = @("database", "architecture"); effort = "L" },
    @{ phase = 2; title = "Repository Unit & Integration Tests"; desc = "Write mock and in-memory SQLite unit tests for all repository methods."; acceptance = "All CRUD operations pass integration tests."; priority = "High"; labels = @("testing", "database"); effort = "L" },

    # Phase 3
    @{ phase = 3; title = "Habit Creation BLoC & Use Cases"; desc = "Implement CreateHabitUseCase, UpdateHabitUseCase, DeleteHabitUseCase, and BLoC."; acceptance = "Handles state management for all habit types (Boolean, Numeric, Timer)."; priority = "High"; labels = @("architecture"); effort = "L" },
    @{ phase = 3; title = "Habit Creation Form UI"; desc = "Build interactive habit form with color/icon picker and frequency controls."; acceptance = "Responsive UI conforming to Material 3 design tokens."; priority = "High"; labels = @("ui"); effort = "L" },
    @{ phase = 3; title = "Habit Templates Engine"; desc = "Implement pre-configured habit templates catalog (Health, Focus, Mindfulness)."; acceptance = "One-tap instantiation of template habits into local database."; priority = "Medium"; labels = @("feature", "ui"); effort = "M" },
    @{ phase = 3; title = "NLP Habit Parsing Engine"; desc = "Integrate lightweight regex/NLP parser for inputs like 'Read 20 mins every morning'."; acceptance = "Correctly extracts title, frequency, target value, and target unit."; priority = "Medium"; labels = @("feature", "ai"); effort = "L" },

    # Phase 4
    @{ phase = 4; title = "Dashboard Shell & Navigation"; desc = "Implement primary bottom navigation and dashboard page layout."; acceptance = "One-handed navigation with sub-second page transitions."; priority = "High"; labels = @("ui", "ux"); effort = "L" },
    @{ phase = 4; title = "Today's Habit Feed BLoC & Widget"; desc = "Create dynamic habit feed displaying active habits for current date."; acceptance = "List updates reactively when habits are completed."; priority = "High"; labels = @("ui", "architecture"); effort = "L" },
    @{ phase = 4; title = "Habit Card Interactive Component"; desc = "Design habit list item with progress ring, swipe actions, and status indicators."; acceptance = "Smooth 60fps swipe animations with tactile haptic feedback."; priority = "High"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 4; title = "Category & Frequency Filtering"; desc = "Add filter chips for category (Health, Work) and frequency views (Daily, Weekly)."; acceptance = "Instant UI filtering without database re-queries."; priority = "Medium"; labels = @("ui"); effort = "M" },

    # Phase 5
    @{ phase = 5; title = "Habit Completion Execution Logic"; desc = "Implement LogHabitProgressUseCase for quick-tap, numeric counter, and timer habits."; acceptance = "Atomically records HabitLog entry and updates daily status."; priority = "High"; labels = @("architecture"); effort = "L" },
    @{ phase = 5; title = "Streak Calculation Engine"; desc = "Implement algorithm to compute current streak, best streak, and freeze protections."; acceptance = "Handles complex completion patterns (every N days, custom days)."; priority = "High"; labels = @("architecture", "testing"); effort = "L" },
    @{ phase = 5; title = "Numeric & Timer Logging Modal"; desc = "Build custom bottom sheet for entering numeric values and live timer execution."; acceptance = "Timer runs in background with precise tick handling."; priority = "High"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 5; title = "Vacation Mode Engine"; desc = "Implement global Vacation Mode toggle to freeze streaks without penalty."; acceptance = "Active vacation pauses streak decay across all habits."; priority = "Medium"; labels = @("feature"); effort = "M" },

    # Phase 6
    @{ phase = 6; title = "Notification Service Abstraction"; desc = "Implement platform-native wrapper around flutter_local_notifications."; acceptance = "Schedules exact time notifications across Android & iOS."; priority = "High"; labels = @("notifications"); effort = "L" },
    @{ phase = 6; title = "Notification Action Handlers"; desc = "Add interactive action buttons ('Complete', 'Snooze 15m') directly in notification payload."; acceptance = "Tapping notification action logs habit without launching full app."; priority = "High"; labels = @("notifications", "ux"); effort = "L" },
    @{ phase = 6; title = "Boot & Timezone Recovery Receiver"; desc = "Register BOOT_COMPLETED broadcast receiver and timezone update listener."; acceptance = "Alarm schedules auto-restore upon device reboot."; priority = "High"; labels = @("notifications", "architecture"); effort = "M" },
    @{ phase = 6; title = "Battery Optimization Onboarding"; desc = "Build user guidance dialog for disabling manufacturer battery restrictions."; acceptance = "Detects OEM ROMs (Xiaomi, Samsung) and opens settings."; priority = "Medium"; labels = @("notifications", "ux"); effort = "M" },

    # Phase 7
    @{ phase = 7; title = "Platform Channel Data Exporter"; desc = "Expose local Drift database updates to shared App Group / SharedPreferences storage."; acceptance = "Native widget reads updated habit states in real-time."; priority = "High"; labels = @("widgets", "architecture"); effort = "L" },
    @{ phase = 7; title = "Android Glance Quick-Complete Widget"; desc = "Create Android Glance Jetpack Compose widget with toggle checkboxes."; acceptance = "Completing habit on widget syncs instantly to SQLite."; priority = "High"; labels = @("widgets"); effort = "XL" },
    @{ phase = 7; title = "iOS WidgetKit Interactive Widget"; desc = "Create iOS WidgetKit SwiftUI interactive widget for iOS 17+."; acceptance = "Interactive AppIntents log habit progress cleanly."; priority = "High"; labels = @("widgets"); effort = "XL" },
    @{ phase = 7; title = "Dashboard Heatmap Widget"; desc = "Design medium/large widget displaying 30-day completion heatmap grid."; acceptance = "Renders visual completion intensity matching theme primary color."; priority = "Medium"; labels = @("widgets", "ui"); effort = "L" },

    # Phase 8
    @{ phase = 8; title = "Experience & Leveling Logic"; desc = "Implement XP reward engine based on consistency, streaks, and target completions."; acceptance = "Calculates levels, progress thresholds, and level-up events."; priority = "Medium"; labels = @("gamification", "architecture"); effort = "M" },
    @{ phase = 8; title = "Quest Lines & Challenge System"; desc = "Create daily, weekly, and special event quest definitions and progress trackers."; acceptance = "Completing quest triggers XP gains and unlock notifications."; priority = "Medium"; labels = @("gamification"); effort = "L" },
    @{ phase = 8; title = "Skill Trees & Unlocks"; desc = "Build visual Skill Tree screen where users allocate points for custom icons and themes."; acceptance = "Unlocked nodes persist and alter app cosmetic theme tokens."; priority = "Low"; labels = @("gamification", "ui"); effort = "XL" },
    @{ phase = 8; title = "Regional Milestones & Badges"; desc = "Implement achievement badges for long-term consistency milestones (e.g. 100-day streak)."; acceptance = "Badges render with custom vector artwork and shareable cards."; priority = "Low"; labels = @("gamification", "ui"); effort = "M" },

    # Phase 9
    @{ phase = 9; title = "Habit Analytics Engine"; desc = "Implement aggregation use cases calculating completion rate, monthly distribution, and trends."; acceptance = "Efficient SQL grouping queries execute in <50ms."; priority = "High"; labels = @("analytics", "database"); effort = "L" },
    @{ phase = 9; title = "Interactive Heatmap Grid"; desc = "Build custom GitHub-style annual/monthly habit contribution heatmap widget."; acceptance = "Supports tap-to-inspect daily details and smooth zooming."; priority = "High"; labels = @("analytics", "ui"); effort = "L" },
    @{ phase = 9; title = "Trend & Correlation Charts"; desc = "Implement charts visualizing target vs actual metrics over week/month/year spans."; acceptance = "Custom animated chart components using Flutter CustomPainter."; priority = "Medium"; labels = @("analytics", "ui"); effort = "L" },
    @{ phase = 9; title = "Health Connect & HealthKit Integration"; desc = "Integrate native health SDKs to automatically complete health-linked habits (e.g., steps, sleep)."; acceptance = "Background sync pulls health metrics and marks habits done."; priority = "Medium"; labels = @("analytics", "feature"); effort = "XL" },

    # Phase 10
    @{ phase = 10; title = "Sync Engine Implementation"; desc = "Replace NoOpSyncEngine with production local-first synchronization worker."; acceptance = "Automatically streams delta changes to/from backend server."; priority = "High"; labels = @("sync", "architecture"); effort = "XL" },
    @{ phase = 10; title = "Conflict Resolution Manager"; desc = "Implement last-write-wins (LWW) and deterministic CRDT conflict resolution rules."; acceptance = "Resolves simultaneous multi-device offline edits seamlessly."; priority = "High"; labels = @("sync", "database"); effort = "L" },
    @{ phase = 10; title = "Anonymous & Social Authentication"; desc = "Implement Supabase/Firebase Auth supporting anonymous login and OAuth providers."; acceptance = "User session tokens persist securely in FlutterSecureStorage."; priority = "High"; labels = @("sync", "security"); effort = "L" },
    @{ phase = 10; title = "Offline Change Queue & Retry"; desc = "Build persistent mutation queue ensuring zero data loss when offline."; acceptance = "Retries failed network mutations with exponential backoff."; priority = "High"; labels = @("sync"); effort = "L" },

    # Phase 11
    @{ phase = 11; title = "Behavioral Pattern Analyzer"; desc = "Implement local rule engine detecting habit failure patterns (e.g. consistently missing Sunday evening habits)."; acceptance = "Highlights high-friction habits in weekly summaries."; priority = "Medium"; labels = @("ai", "analytics"); effort = "L" },
    @{ phase = 11; title = "Optimal Reminder Timing Engine"; desc = "Calculate optimal notification times based on historical completion velocity."; acceptance = "Suggests time adjustments to maximize completion probability."; priority = "Medium"; labels = @("ai", "notifications"); effort = "L" },
    @{ phase = 11; title = "Smart Habit Recommendation Engine"; desc = "Implement contextual habit recommendation engine based on user goals."; acceptance = "Generates tailored habit stacks (e.g., Morning Routine stack)."; priority = "Low"; labels = @("ai"); effort = "M" },
    @{ phase = 11; title = "Monthly AI Insight Cards"; desc = "Generate monthly performance insight summaries highlighting progress and focus areas."; acceptance = "Renders interactive insight cards on dashboard UI."; priority = "Low"; labels = @("ai", "ui"); effort = "M" },

    # Phase 12
    @{ phase = 12; title = "BLoC & Use Case Unit Test Suite"; desc = "Write 100% unit test coverage for all BLoCs, state transitions, and domain use cases."; acceptance = "flutter test --coverage passes 100% of domain tests."; priority = "High"; labels = @("testing"); effort = "L" },
    @{ phase = 12; title = "Golden UI Test Suite"; desc = "Create golden tests across light and dark themes for core screens."; acceptance = "Validates pixel-perfect UI rendering on multiple device sizes."; priority = "High"; labels = @("testing", "ui"); effort = "L" },
    @{ phase = 12; title = "Performance Optimization & Profiling"; desc = "Audit repaints using RepaintBoundary, reduce build overhead, and optimize frame times."; acceptance = "60/120fps performance with zero dropped frames during scroll."; priority = "High"; labels = @("performance"); effort = "L" },
    @{ phase = 12; title = "Accessibility & Semantics Audit"; desc = "Ensure full screen reader (TalkBack/VoiceOver) support and dynamic font scaling."; acceptance = "Passes WCAG 2.1 AA accessibility guidelines."; priority = "Medium"; labels = @("ui", "ux"); effort = "M" },
    @{ phase = 12; title = "App Store & Play Store Release Build"; desc = "Configure app signing, obfuscation (--obfuscate), app bundles (.aab), and store metadata."; acceptance = "Production builds compile cleanly for iOS App Store and Google Play."; priority = "High"; labels = @("architecture"); effort = "L" }
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
        
        # Single-shot edit call
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
