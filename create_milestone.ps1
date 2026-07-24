# ==========================================
# GitHub Milestone Creator
# ==========================================

$milestones = @(
    @{
        Title = "Phase 1 – Core Infrastructure"
        Description = "Project setup, dependency injection, routing, theming, Drift initialization, logging."
    },
    @{
        Title = "Phase 2 – Domain & Data Layer"
        Description = "Implement entities, repositories, Drift tables, DAOs, mappers, and tests."
    },
    @{
        Title = "Phase 3 – Habit CRUD & Management"
        Description = "Habit creation, editing, deletion, templates, categories, NLP parser."
    },
    @{
        Title = "Phase 4 – Dashboard & UI Foundation"
        Description = "Dashboard, habit cards, filtering, Material 3 UI, responsive layouts."
    },
    @{
        Title = "Phase 5 – Habit Loop & Streak Engine"
        Description = "Habit logging, streak calculations, vacation mode, completion engine."
    },
    @{
        Title = "Phase 6 – Notifications & Reminder Engine"
        Description = "Local notifications, snooze, action buttons, reboot recovery."
    },
    @{
        Title = "Phase 7 – Interactive Native Widgets"
        Description = "Android Glance widgets and iOS WidgetKit interactive widgets."
    },
    @{
        Title = "Phase 8 – Gamification Engine"
        Description = "XP, levels, quests, achievements, rewards."
    },
    @{
        Title = "Phase 9 – Analytics & Health Integrations"
        Description = "Statistics, charts, heatmaps, Health Connect, HealthKit."
    },
    @{
        Title = "Phase 10 – Cloud Sync & Authentication"
        Description = "Offline-first synchronization, authentication, conflict resolution."
    },
    @{
        Title = "Phase 11 – AI Coach & Smart Features"
        Description = "Behavior analysis, reminder optimization, AI insights."
    },
    @{
        Title = "Phase 12 – Performance, Polish & v1.0 Release"
        Description = "Optimization, accessibility, testing, production release."
    }
)

Write-Host ""
Write-Host "Creating GitHub milestones..."
Write-Host ""

foreach ($m in $milestones) {

    Write-Host "Creating: $($m.Title)"

    gh api repos/:owner/:repo/milestones `
        --method POST `
        --field title="$($m.Title)" `
        --field description="$($m.Description)"

}

Write-Host ""
Write-Host "================================="
Write-Host "All milestones created!"
Write-Host "================================="
