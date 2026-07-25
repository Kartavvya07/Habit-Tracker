# ==========================================
# GitHub Milestone Creator (ASCII Safe)
# Repository: Kartavvya07/Habit-Tracker
# ==========================================

$ErrorActionPreference = "Stop"

$owner = "Kartavvya07"
$repo  = "Habit-Tracker"

$milestones = @(
    @{
        Title = "Phase 1 - Core Infrastructure"
        Description = "Project setup, dependency injection, routing, theming, Drift initialization, logging."
    },
    @{
        Title = "Phase 2 - Domain & Data Layer"
        Description = "Implement entities, repositories, Drift tables, DAOs, mappers, and tests."
    },
    @{
        Title = "Phase 3 - Habit CRUD & Management"
        Description = "Habit creation, editing, deletion, templates, categories, and NLP parser."
    },
    @{
        Title = "Phase 4 - Dashboard & UI Foundation"
        Description = "Dashboard, habit cards, filtering, Material 3 UI, and responsive layouts."
    },
    @{
        Title = "Phase 5 - Habit Loop & Streak Engine"
        Description = "Habit logging, streak calculations, progress logging modals, and vacation mode."
    },
    @{
        Title = "Phase 6 - Habit Management"
        Description = "Habit edit form, archiving mechanics, deletion, and swipe actions."
    },
    @{
        Title = "Phase 7 - Notification & Reminder Engine"
        Description = "Local exact alarms, snooze, notification action buttons, and reboot recovery."
    },
    @{
        Title = "Phase 8 - Interactive Native Home Screen Widgets"
        Description = "Android Glance widgets and iOS WidgetKit widgets."
    },
    @{
        Title = "Phase 9 - Gamification Engine"
        Description = "XP, levels, quest lines, skill trees, achievements, and rewards."
    },
    @{
        Title = "Phase 10 - Analytics & Health Integrations"
        Description = "Charts, contribution heatmaps, Health Connect, and HealthKit."
    },
    @{
        Title = "Phase 11 - Cloud Sync & Authentication"
        Description = "Local-first delta synchronization, authentication, and CRDT conflict resolution."
    },
    @{
        Title = "Phase 12 - AI Coach & Smart Features"
        Description = "Behavior analysis, reminder optimization, NLP parser, and AI insights."
    },
    @{
        Title = "Phase 13 - Performance, Accessibility & Production Release"
        Description = "Golden tests, 100% provider unit tests, rendering optimization, accessibility audit, and v1.0 release."
    }
)

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Creating GitHub Milestones" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

foreach ($m in $milestones) {

    $title = $m.Title

    try {
        $existing = gh api "repos/$owner/$repo/milestones?state=all" `
            --jq ".[] | select(.title == `"$title`") | .title"

        if ($existing) {
            Write-Host "[SKIP] $title already exists." -ForegroundColor Yellow
            continue
        }

        gh api "repos/$owner/$repo/milestones" `
            --method POST `
            --field title="$title" `
            --field description="$($m.Description)" | Out-Null

        Write-Host "[ OK ] $title" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] $title" -ForegroundColor Red
        Write-Host $_
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " Finished creating milestones" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
