# ==============================================================================
# 04-populate-project.ps1
# Automates adding all repository issues to the GitHub Project board.
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

$Repo = "Kartavvya07/Habit-Tracker"
$Owner = "Kartavvya07"
$ProjectTitle = "Habit Tracker Roadmap"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 4: Populating Project with Issues            " -ForegroundColor Cyan
Write-Host "  Repository: $Repo                                 " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Check for existing project
Write-Host "Finding GitHub Project..." -ForegroundColor Yellow
$ProjectListRaw = gh project list --owner $Owner --format json 2>&1

if ($LASTEXITCODE -ne 0 -or $ProjectListRaw -match "missing required scopes") {
    Write-Host "  [NOTICE] GitHub CLI token lacks 'project' scope or project permissions." -ForegroundColor Yellow
    Write-Host "  [NOTICE] Project population skipped non-fatally." -ForegroundColor Yellow
    exit 0
}

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

$TargetProject = $Projects | Where-Object { $_.title -ieq $ProjectTitle -or $_.title -like "*Habit Tracker*" }

if ($null -eq $TargetProject) {
    Write-Host "  [WARNING] Target project '$ProjectTitle' not found. Skipping population." -ForegroundColor Yellow
    exit 0
}

$ProjectNumber = $TargetProject.number
Write-Host "Found Project #$ProjectNumber ('$($TargetProject.title)')." -ForegroundColor Green

# Fetch all issues
Write-Host "Fetching issues from repository..." -ForegroundColor Yellow
$IssuesJson = gh issue list --repo $Repo --limit 500 --state all --json url,number,title 2>$null | Out-String
$Issues = @()
if ($IssuesJson) {
    try {
        $Issues = $IssuesJson | ConvertFrom-Json
    } catch {
        $Issues = @()
    }
}

Write-Host "Adding $($Issues.Count) issues to Project #$ProjectNumber..." -ForegroundColor Yellow
$AddedCount = 0
$SkippedCount = 0

foreach ($Issue in $Issues) {
    $Url = $Issue.url
    $Num = $Issue.number
    
    $AddResult = gh project item-add $ProjectNumber --owner $Owner --url $Url 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [SUCCESS] Added Issue #$Num to Project" -ForegroundColor Green
        $AddedCount++
    } else {
        Write-Host "  [SKIP/WARNING] Issue #${Num} - $AddResult" -ForegroundColor Gray
        $SkippedCount++
    }
}

Write-Host "----------------------------------------------------" -ForegroundColor Cyan
Write-Host "Population Summary: Added/Verified: $AddedCount, Skipped/Existing: $SkippedCount" -ForegroundColor Green
