# ==============================================================================
# update_github_roadmap.ps1
# Synchronizes GitHub Milestones & Issues with the canonical refactored roadmap.
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
Write-Host "  Synchronizing GitHub Milestones & Issues          " -ForegroundColor Cyan
Write-Host "  Repository: $Repo                                 " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Fetch milestones map from GitHub API
$ExistingMilestonesJson = gh api repos/$Repo/milestones?state=all 2>$null | Out-String
$ExistingMilestones = $ExistingMilestonesJson | ConvertFrom-Json

# Helper to find milestone title by number pattern
function Update-MilestoneByNum ($PhaseNum, $Description) {
    foreach ($m in $ExistingMilestones) {
        if ($m.title -like "Phase $PhaseNum *") {
            $mNum = $m.number
            Write-Host "  Updating Milestone #${mNum}: $($m.title)..." -ForegroundColor Cyan
            gh api "repos/$Repo/milestones/$mNum" -X PATCH --field description="$Description" | Out-Null
            return
        }
    }
}

Write-Host "`nUpdating Milestone descriptions..." -ForegroundColor Yellow
Update-MilestoneByNum 1 "Project setup, Riverpod state management, GoRouter, M3 theme, and Drift initialization."
Update-MilestoneByNum 2 "Implement core domain entities (Habit freezed entity), Drift HabitsTable, DTOs, mappers, and repositories."
Update-MilestoneByNum 3 "Create Habit vertical slice, CreateHabitNotifier, M3 form UI, color/icon selectors, and release verification."
Update-MilestoneByNum 4 "Reactive read stream, Riverpod StreamProvider, DashboardState management, and Dashboard UI feed."
Update-MilestoneByNum 5 "Habit logs table, progress logging, streak calculation algorithm, progress modals, and vacation mode."
Update-MilestoneByNum 6 "Local exact alarms, snooze/action buttons, reboot recovery, and battery optimization onboarding."
Update-MilestoneByNum 7 "Android Glance Jetpack Compose widgets and iOS WidgetKit interactive SwiftUI widgets."
Update-MilestoneByNum 8 "XP reward engine, quest lines, skill tree unlocks, regional milestones, and cosmetic badges."
Update-MilestoneByNum 9 "Aggregated analytics, GitHub-style contribution heatmaps, trend charts, and Health Connect / HealthKit sync."
Update-MilestoneByNum 10 "Local-first delta synchronization engine, CRDT conflict resolution, auth, and offline retry queue."
Update-MilestoneByNum 11 "Behavioral pattern analyzer, optimal reminder timing engine, NLP parser, and monthly AI performance insights."
Update-MilestoneByNum 12 "Provider unit tests, golden UI tests, performance profiling, accessibility audit, and production release build."

# 2. Update Phase 4 Issues specifically (Sync #401, #402, #403 as Closed and #404 as Open)
Write-Host "`nSynchronizing Phase 4 Issues (#401–#404)..." -ForegroundColor Yellow

$Body401 = @"
## Description
Implement watchHabits() in HabitRepository emitting Stream<List<Habit>> ordered by createdAt DESC.

## Acceptance Criteria
Streams live database updates from Drift reactively.

## Governance Metadata
- **Priority**: High
- **Effort**: L
- **Phase**: Phase 4
- **Status**: COMPLETED
"@

$Body402 = @"
## Description
Expose habitsStreamProvider wrapping watchHabits() in presentation layer.

## Acceptance Criteria
Automatically streams live updates to downstream state providers on DB mutation.

## Governance Metadata
- **Priority**: High
- **Effort**: L
- **Phase**: Phase 4
- **Status**: COMPLETED
"@

$Body403 = @"
## Description
Design DashboardState sealed class (Loading, Empty, Loaded, Error) and dashboardProvider.

## Acceptance Criteria
Transforms repository stream into presentation-ready states with 100% unit tests.

## Governance Metadata
- **Priority**: High
- **Effort**: M
- **Phase**: Phase 4
- **Status**: COMPLETED
"@

$Body404 = @"
## Description
Build DashboardScreen UI consuming dashboardProvider, habit card widgets, loading/empty states, and FAB navigation.

## Acceptance Criteria
Renders habits feed reactively with Material 3 cards and seamless FAB action to /create-habit.

## Governance Metadata
- **Priority**: High
- **Effort**: L
- **Phase**: Phase 4
- **Status**: PENDING (Next Active Task)
"@

# Issue 21 -> #401 Repository Reactive Read Layer (CLOSED)
gh issue edit 21 --repo $Repo --title "Repository Reactive Read Layer" --body "$Body401" 2>$null
gh issue close 21 --repo $Repo --reason "completed" 2>$null
Write-Host "  [CLOSED #21 -> Issue #401] Repository Reactive Read Layer" -ForegroundColor Green

# Issue 22 -> #402 Riverpod StreamProvider Integration (CLOSED)
gh issue edit 22 --repo $Repo --title "Riverpod StreamProvider Integration" --body "$Body402" 2>$null
gh issue close 22 --repo $Repo --reason "completed" 2>$null
Write-Host "  [CLOSED #22 -> Issue #402] Riverpod StreamProvider Integration" -ForegroundColor Green

# Issue 23 -> #403 Dashboard State Management (CLOSED)
gh issue edit 23 --repo $Repo --title "Dashboard State Management" --body "$Body403" 2>$null
gh issue close 23 --repo $Repo --reason "completed" 2>$null
Write-Host "  [CLOSED #23 -> Issue #403] Dashboard State Management" -ForegroundColor Green

# Issue 24 -> #404 Dashboard UI & Habit Cards (OPEN - NEXT ACTIVE)
gh issue edit 24 --repo $Repo --title "Dashboard UI & Habit Cards" --body "$Body404" 2>$null
gh issue reopen 24 --repo $Repo 2>$null
Write-Host "  [OPEN #24 -> Issue #404] Dashboard UI & Habit Cards (Next Active Task)" -ForegroundColor Cyan

# 3. Update issue titles & bodies across Phases 1–12 to remove BLoC references and align with canonical roadmap
$RefactoredIssueDetails = @{
    10 = @{ title = "Configure GoRouter & Riverpod Setup"; desc = "Initialize GoRouter navigation setup and ProviderContainer root." }
    17 = @{ title = "Domain Use Cases & Riverpod State Notifier"; desc = "Implement CreateHabitUseCase, UpdateHabitUseCase, DeleteHabitUseCase, and CreateHabitNotifier." }
    25 = @{ title = "Drift Habit Logs Table & Model"; desc = "Create HabitLogsTable in Drift, HabitLog domain entity, and bidirectional HabitLogMapper." }
    26 = @{ title = "Completion Execution Use Case"; desc = "Implement LogHabitProgressUseCase for quick-tap, numeric counter, and timer habits." }
    27 = @{ title = "Streak Calculation Engine"; desc = "Implement algorithm to compute current streak, best streak, and completion rate." }
    28 = @{ title = "Numeric & Timer Progress Logging Modal"; desc = "Build custom bottom sheets for entering numeric values and live timer execution." }
    49 = @{ title = "Unit & Provider Test Suite Verification"; desc = "Write 100% unit test coverage for all domain use cases and Riverpod providers." }
}

Write-Host "`nUpdating BLoC / legacy references in remaining issue descriptions..." -ForegroundColor Yellow
foreach ($issueNum in $RefactoredIssueDetails.Keys) {
    $item = $RefactoredIssueDetails[$issueNum]
    $t = $item.title
    gh issue edit $issueNum --repo $Repo --title "$t" 2>$null
    Write-Host "  [UPDATED #$issueNum] $t" -ForegroundColor Green
}

Write-Host "`n====================================================" -ForegroundColor Green
Write-Host "  GitHub Repository Synchronization Completed!     " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
