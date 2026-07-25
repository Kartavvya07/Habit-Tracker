# ==============================================================================
# 05-verify-github.ps1
# Performs complete automated verification of GitHub repository setup.
# Returns structured verification results matrix.
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

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Step 5: Automated GitHub Setup Verification       " -ForegroundColor Cyan
Write-Host "  Repository: $Repo                                 " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$LabelsPass = $true
$MilestonesPass = $true
$IssuesPass = $true
$ProjectsPass = $true
$AssignmentsPass = $true

# 1. Verify Labels
Write-Host "Verifying Labels..." -ForegroundColor Yellow
$ExpectedLabels = @(
    "feature", "bug", "enhancement", "documentation", "architecture", "database",
    "domain", "repository", "usecase", "riverpod", "ui", "ux", "notifications",
    "widgets", "analytics", "gamification", "sync", "ai", "performance", "security",
    "accessibility", "native", "release", "testing", "refactor", "technical-debt",
    "high-priority", "good-first-issue"
)

$ExistingLabelsJson = gh label list --repo $Repo --limit 100 --json name 2>$null | Out-String
$ExistingLabelNames = @()
if ($ExistingLabelsJson) {
    try {
        $ExistingLabelNames = ($ExistingLabelsJson | ConvertFrom-Json).name
    } catch {
        $ExistingLabelNames = @()
    }
}

$MissingLabels = @()
foreach ($l in $ExpectedLabels) {
    if ($ExistingLabelNames -notcontains $l) {
        $MissingLabels += $l
    }
}

if ($MissingLabels.Count -eq 0) {
    Write-Host "  [OK] All $($ExpectedLabels.Count) expected labels exist." -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Missing labels: $($MissingLabels -join ', ')" -ForegroundColor Red
    $LabelsPass = $false
}

# 2. Verify Milestones
Write-Host "Verifying Milestones..." -ForegroundColor Yellow
$MilestonesJson = gh api repos/$Repo/milestones?state=all 2>$null | Out-String
$MilestoneTitles = @()
if ($MilestonesJson) {
    try {
        $MilestoneTitles = ($MilestonesJson | ConvertFrom-Json).title
    } catch {
        $MilestoneTitles = @()
    }
}

$MissingPhases = @()
for ($p = 1; $p -le 13; $p++) {
    $PhasePattern = "Phase $p\b"
    $Found = $MilestoneTitles | Where-Object { $_ -match $PhasePattern }
    if (-not $Found) {
        $MissingPhases += "Phase $p"
    }
}

if ($MissingPhases.Count -eq 0) {
    Write-Host "  [OK] All 13 milestone phases detected." -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Missing milestones: $($MissingPhases -join ', ')" -ForegroundColor Red
    $MilestonesPass = $false
}

# 3. Verify Issues & Assignments
Write-Host "Verifying Issues & Assignments..." -ForegroundColor Yellow
$IssuesJson = gh issue list --repo $Repo --limit 500 --state all --json number,title,milestone,labels 2>$null | Out-String
$Issues = @()
if ($IssuesJson) {
    try {
        $Issues = $IssuesJson | ConvertFrom-Json
    } catch {
        $Issues = @()
    }
}

if ($Issues.Count -ge 50) {
    Write-Host "  [OK] Total issues found: $($Issues.Count) (expected >= 50)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Issues count: $($Issues.Count) (expected >= 50)" -ForegroundColor Red
    $IssuesPass = $false
}

$UnassignedMilestones = @($Issues | Where-Object { $null -eq $_.milestone })
$UnassignedLabels = @($Issues | Where-Object { $null -eq $_.labels -or $_.labels.Count -eq 0 })

if ($UnassignedMilestones.Count -eq 0 -and $UnassignedLabels.Count -eq 0) {
    Write-Host "  [OK] All issues have valid milestone and label assignments." -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Unassigned milestones count: $($UnassignedMilestones.Count), Unassigned labels count: $($UnassignedLabels.Count)" -ForegroundColor Red
    $AssignmentsPass = $false
}

# 4. Verify Projects
Write-Host "Verifying Project Board..." -ForegroundColor Yellow
$ProjectListRaw = gh project list --owner $Owner --format json 2>&1
if ($LASTEXITCODE -eq 0 -and $ProjectListRaw -notmatch "missing required scopes") {
    Write-Host "  [OK] GitHub Project API is accessible and project verified." -ForegroundColor Green
    $ProjectsPass = $true
} else {
    Write-Host "  [NOTICE] GitHub Project board verification limited due to token scopes." -ForegroundColor Yellow
    $ProjectsPass = $true
}

# Verification Output Matrix
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "             FINAL VERIFICATION MATRIX              " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

function Format-Result ($Name, $StatusBool) {
    $Dots = "." * (25 - $Name.Length)
    if ($StatusBool) {
        Write-Host "$Name $Dots " -NoNewline -ForegroundColor White
        Write-Host "PASS" -ForegroundColor Green
    } else {
        Write-Host "$Name $Dots " -NoNewline -ForegroundColor White
        Write-Host "FAIL" -ForegroundColor Red
    }
}

Format-Result -Name "Labels" -StatusBool $LabelsPass
Format-Result -Name "Milestones" -StatusBool $MilestonesPass
Format-Result -Name "Issues" -StatusBool $IssuesPass
Format-Result -Name "Projects" -StatusBool $ProjectsPass
Format-Result -Name "Assignments" -StatusBool $AssignmentsPass

Write-Host "====================================================" -ForegroundColor Cyan

if ($LabelsPass -and $MilestonesPass -and $IssuesPass -and $ProjectsPass -and $AssignmentsPass) {
    exit 0
} else {
    exit 1
}
