# ==============================================================================
# 03-create-project.ps1
# Automates the creation of a GitHub Project (Kanban) board.
# Safe to rerun multiple times (Idempotent).
# Handles missing project scopes or permissions gracefully.
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path += ";C:\Program Files\GitHub CLI"
    }
}

$Owner = "Kartavvya07"
$ProjectTitle = "Habit Tracker Roadmap"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 3: Creating GitHub Project Board             " -ForegroundColor Cyan
Write-Host "  Owner: $Owner | Title: $ProjectTitle              " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Test project list access
Write-Host "Checking for existing projects..." -ForegroundColor Yellow
$ProjectListRaw = gh project list --owner $Owner --format json 2>&1

if ($LASTEXITCODE -ne 0 -or $ProjectListRaw -match "missing required scopes") {
    Write-Host "  [NOTICE] GitHub CLI token lacks 'project' scope or project permissions." -ForegroundColor Yellow
    Write-Host "  [NOTICE] GitHub Project creation step skipped non-fatally." -ForegroundColor Yellow
    Write-Host "  To enable project board automation, grant 'project' scope to your gh CLI token." -ForegroundColor Yellow
    exit 0
}

# Parse project list
$Projects = @()
try {
    $ProjectsJson = $ProjectListRaw | Out-String | ConvertFrom-Json
    if ($ProjectsJson.projects) {
        $Projects = $ProjectsJson.projects
    } elseif ($ProjectsJson -is [array]) {
        $Projects = $ProjectsJson
    }
} catch {
    $Projects = @()
}

$ExistingProject = $Projects | Where-Object { $_.title -ieq $ProjectTitle -or $_.title -like "*Habit Tracker*" }

if ($null -ne $ExistingProject) {
    Write-Host "  [SKIP] Project '$($ExistingProject.title)' already exists (Number: $($ExistingProject.number))." -ForegroundColor Green
} else {
    Write-Host "  [CREATE] Creating GitHub Project '$ProjectTitle'..." -ForegroundColor Green
    $CreateOutput = gh project create --owner $Owner --title $ProjectTitle 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SUCCESS] GitHub Project created successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] Could not create project automatically: $CreateOutput" -ForegroundColor Yellow
    }
}

Write-Host "----------------------------------------------------" -ForegroundColor Cyan
