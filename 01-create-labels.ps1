# ==============================================================================
# 01-create-labels.ps1
# Automates the creation and updating of GitHub repository labels.
# Safe to rerun multiple times (Idempotent).
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Ensure gh executable is in PATH
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path += ";C:\Program Files\GitHub CLI"
    }
}

$Repo = "Kartavvya07/Habit-Tracker"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 1: Creating & Updating GitHub Labels         " -ForegroundColor Cyan
Write-Host "  Repository: $Repo                                 " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Comprehensive label definitions array
$Labels = @(
    @{ name = "feature"; color = "a2eeef"; description = "Work Type: New feature implementation" },
    @{ name = "bug"; color = "d73a4a"; description = "Work Type: Problem or unexpected failure in existing code" },
    @{ name = "enhancement"; color = "a2eeef"; description = "Work Type: Improvement to an existing capability" },
    @{ name = "documentation"; color = "0075ca"; description = "Work Type: Improvements or additions to documentation" },
    @{ name = "architecture"; color = "0052cc"; description = "Domain: Clean Architecture structural decisions and abstractions" },
    @{ name = "database"; color = "bfd4f2"; description = "Domain: Drift SQLite schema, migrations, DTOs and query performance" },
    @{ name = "domain"; color = "0e8a16"; description = "Domain: Immutable domain entities, value objects, and pure use cases" },
    @{ name = "repository"; color = "1d76db"; description = "Domain: Repository interfaces and Drift data access implementations" },
    @{ name = "usecase"; color = "5319e7"; description = "Domain: Business logic use cases executing core application rules" },
    @{ name = "riverpod"; color = "fbca04"; description = "Domain: Riverpod state providers, stream providers, and state notifiers" },
    @{ name = "ui"; color = "f9d0c4"; description = "Domain: Presentation layer pages, layouts and Material Design 3" },
    @{ name = "ux"; color = "e99695"; description = "Domain: Micro-animations, transitions and interactive design tokens" },
    @{ name = "notifications"; color = "d4c5f9"; description = "Domain: Local exact alarms, action buttons, and system triggers" },
    @{ name = "widgets"; color = "bfdadc"; description = "Domain: Android Glance and iOS WidgetKit native home screen widgets" },
    @{ name = "analytics"; color = "c2e0c6"; description = "Domain: Data visualizations, heatmaps and HealthKit/Health Connect" },
    @{ name = "gamification"; color = "fef2c0"; description = "Domain: Quest lines, skill trees, milestones and cosmetic unlocks" },
    @{ name = "sync"; color = "fbca04"; description = "Domain: Local-first cloud sync engine (PowerSync/ElectricSQL)" },
    @{ name = "ai"; color = "bfd4f2"; description = "Domain: AI Coach behavioral insights and habit recommendations" },
    @{ name = "performance"; color = "c5def5"; description = "Governance: Memory efficiency, RepaintBoundary and zero-latency target" },
    @{ name = "security"; color = "b60205"; description = "Governance: Encryption, secure storage and privacy compliance" },
    @{ name = "accessibility"; color = "d4c5f9"; description = "Governance: WCAG 2.1 AA compliance, semantics, screen readers, touch targets" },
    @{ name = "native"; color = "0052cc"; description = "Platform: Native Kotlin Glance and Swift WidgetKit integration" },
    @{ name = "release"; color = "0075ca"; description = "Governance: Milestone release verification, git tag, and APK bundle build" },
    @{ name = "testing"; color = "d4c5f9"; description = "Quality: Unit, Riverpod, repository and golden UI automated tests" },
    @{ name = "refactor"; color = "1d76db"; description = "Quality: Code improvements without behavior changes" },
    @{ name = "technical-debt"; color = "961501"; description = "Quality: Deferred refactoring or structural enhancements" },
    @{ name = "high-priority"; color = "b60205"; description = "Priority: Critical blocker for current milestone completion" },
    @{ name = "good-first-issue"; color = "7057ff"; description = "Onboarding: Well-scoped entry task for new contributors" }
)

# Fetch existing labels from GitHub repository
Write-Host "Fetching existing labels..." -ForegroundColor Yellow
$ExistingJson = gh label list --repo $Repo --limit 100 --json name,color,description 2>$null | Out-String
$ExistingLabels = @()
if ($ExistingJson) {
    try {
        $ExistingLabels = $ExistingJson | ConvertFrom-Json
    } catch {
        $ExistingLabels = @()
    }
}

$CreatedCount = 0
$UpdatedCount = 0
$SkippedCount = 0

foreach ($L in $Labels) {
    $Name = $L.name
    $Color = $L.color
    $Desc = $L.description
    
    $Match = $ExistingLabels | Where-Object { $_.name -ieq $Name }
    
    if ($null -ne $Match) {
        $MatchColor = $Match.color.TrimStart('#')
        if ($MatchColor -ieq $Color -and $Match.description -eq $Desc) {
            Write-Host "  [SKIP] Label '$Name' already up-to-date" -ForegroundColor Gray
            $SkippedCount++
        } else {
            Write-Host "  [UPDATE] Updating label '$Name'..." -ForegroundColor Cyan
            gh label edit $Name --color $Color --description $Desc --repo $Repo 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [SUCCESS] Updated '$Name'" -ForegroundColor Green
                $UpdatedCount++
            } else {
                Write-Host "  [WARNING] Failed to update '$Name'" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  [CREATE] Creating label '$Name'..." -ForegroundColor Green
        gh label create $Name --color $Color --description $Desc --repo $Repo 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [SUCCESS] Created '$Name'" -ForegroundColor Green
            $CreatedCount++
        } else {
            Write-Host "  [WARNING] Failed to create '$Name'" -ForegroundColor Yellow
        }
    }
}

Write-Host "----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Labels Summary: Created: $CreatedCount, Updated: $UpdatedCount, Skipped: $SkippedCount" -ForegroundColor Green
