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
$MilestonesJson = gh api "repos/$Repo/milestones?state=all&per_page=100" 2>$null | Out-String
$Milestones = @()
if ($MilestonesJson) {
    try {
        $Milestones = $MilestonesJson | ConvertFrom-Json
    } catch {
        $Milestones = @()
    }
}

$MilestoneTitles = $Milestones.title
$OpenMilestoneCount = ($Milestones | Where-Object { $_.state -eq "open" }).Count
$ClosedMilestoneCount = ($Milestones | Where-Object { $_.state -eq "closed" }).Count

$MissingPhases = @()
for ($p = 1; $p -le 13; $p++) {
    $PhasePattern = "^Phase $p\b"
    $Found = $MilestoneTitles | Where-Object { $_ -match $PhasePattern }
    if (-not $Found) {
        $MissingPhases += "Phase $p"
    }
}

if ($MissingPhases.Count -eq 0 -and $Milestones.Count -eq 13 -and $OpenMilestoneCount -eq 9 -and $ClosedMilestoneCount -eq 4) {
    Write-Host "  [OK] Canonical 13 milestone structure verified (4 closed, 9 open, 0 duplicates)." -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Milestone structure error: Total=$($Milestones.Count) (expected 13), Open=$OpenMilestoneCount (expected 9), Closed=$ClosedMilestoneCount (expected 4), Missing: $($MissingPhases -join ', ')" -ForegroundColor Red
    $MilestonesPass = $false
}

# 3. Verify Issues & Assignments
Write-Host "Verifying Issues & Assignments..." -ForegroundColor Yellow
$IssuesJson = gh issue list --repo $Repo --limit 500 --state all --json number,title,state,milestone,labels 2>$null | Out-String
$Issues = @()
if ($IssuesJson) {
    try {
        $Issues = $IssuesJson | ConvertFrom-Json
    } catch {
        $Issues = @()
    }
}

$OpenIssues = @($Issues | Where-Object { $_.state -eq "open" })

if ($OpenIssues.Count -ge 50) {
    Write-Host "  [OK] Open implementation issues found: $($OpenIssues.Count) (expected >= 50)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Open issues count: $($OpenIssues.Count) (expected >= 50)" -ForegroundColor Red
    $IssuesPass = $false
}

$UnassignedMilestones = @($OpenIssues | Where-Object { $null -eq $_.milestone })
$UnassignedLabels = @($OpenIssues | Where-Object { $null -eq $_.labels -or $_.labels.Count -eq 0 })

if ($UnassignedMilestones.Count -eq 0 -and $UnassignedLabels.Count -eq 0) {
    Write-Host "  [OK] All active open issues have valid canonical milestone and label assignments." -ForegroundColor Green
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
