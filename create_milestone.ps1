# ==============================================================================
# create_milestone.ps1 (Strictly Idempotent)
# Repository: Kartavvya07/Habit-Tracker
# Safe to rerun multiple times without creating duplicate milestones.
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path += ";C:\Program Files\GitHub CLI"
    }
}

$owner = "Kartavvya07"
$repo  = "Habit-Tracker"

$milestones = @(
    @{ Phase = 1;  Title = "Phase 1 - Core Infrastructure"; Description = "Project setup, dependency injection, routing, theming, Drift initialization, logging." },
    @{ Phase = 2;  Title = "Phase 2 - Domain & Data Layer"; Description = "Implement entities, repositories, Drift tables, DAOs, mappers, and tests." },
    @{ Phase = 3;  Title = "Phase 3 - Habit CRUD & Management"; Description = "Habit creation, editing, deletion, templates, categories, and NLP parser." },
    @{ Phase = 4;  Title = "Phase 4 - Habit Dashboard"; Description = "Dashboard, habit cards, filtering, Material 3 UI, and responsive layouts." },
    @{ Phase = 5;  Title = "Phase 5 - Habit Loop & Streak Engine"; Description = "Habit logs table, progress logging, streak calculation algorithm, progress modals, and vacation mode." },
    @{ Phase = 6;  Title = "Phase 6 - Habit Management"; Description = "Habit edit form, archiving mechanics, deletion, and swipe actions." },
    @{ Phase = 7;  Title = "Phase 7 - Notification & Reminder Engine"; Description = "Local exact alarms, snooze, notification action buttons, and reboot recovery." },
    @{ Phase = 8;  Title = "Phase 8 - Interactive Native Home Screen Widgets"; Description = "Android Glance widgets and iOS WidgetKit widgets." },
    @{ Phase = 9;  Title = "Phase 9 - Gamification Engine"; Description = "XP, levels, quest lines, skill trees, achievements, and rewards." },
    @{ Phase = 10; Title = "Phase 10 - Analytics & Health Integrations"; Description = "Charts, contribution heatmaps, Health Connect, and HealthKit." },
    @{ Phase = 11; Title = "Phase 11 - Cloud Sync & Authentication"; Description = "Local-first delta synchronization, authentication, and CRDT conflict resolution." },
    @{ Phase = 12; Title = "Phase 12 - AI Coach & Smart Features"; Description = "Behavior analysis, reminder optimization, NLP parser, and AI insights." },
    @{ Phase = 13; Title = "Phase 13 - Performance, Accessibility & Production Release"; Description = "Golden tests, 100% provider unit tests, rendering optimization, accessibility audit, and v1.0 release." }
)

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Creating / Updating GitHub Milestones" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Fetch all existing milestones (open and closed)
$ExistingJson = gh api "repos/$owner/$repo/milestones?state=all&per_page=100" 2>$null | Out-String
$ExistingList = @()
if ($ExistingJson) {
    try {
        $ExistingList = $ExistingJson | ConvertFrom-Json
    } catch {
        $ExistingList = @()
    }
}

foreach ($m in $milestones) {
    $pNum = $m.Phase
    $title = $m.Title
    $desc = $m.Description

    # Match by exact title or phase number boundary pattern
    $match = $null
    foreach ($ex in $ExistingList) {
        if ($ex.title -eq $title -or $ex.title -match "^Phase ${pNum}\b") {
            $match = $ex
            break
        }
    }

    if ($null -ne $match) {
        # Milestone exists - check if update is needed
        if ($match.title -eq $title -and $match.description -eq $desc) {
            Write-Host "[SKIP] '$title' (ID #$($match.number)) already exists and is up to date." -ForegroundColor Yellow
        } else {
            Write-Host "[UPDATE] Updating milestone #$($match.number) to '$title'..." -ForegroundColor Cyan
            gh api "repos/$owner/$repo/milestones/$($match.number)" `
                --method PATCH `
                --field title="$title" `
                --field description="$desc" | Out-Null
            Write-Host "[ OK ] Milestone #$($match.number) updated successfully." -ForegroundColor Green
        }
    } else {
        # Create new milestone
        Write-Host "[CREATE] Creating milestone '$title'..." -ForegroundColor Green
        gh api "repos/$owner/$repo/milestones" `
            --method POST `
            --field title="$title" `
            --field description="$desc" | Out-Null
        Write-Host "[ OK ] Created '$title'" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " Finished processing milestones" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
