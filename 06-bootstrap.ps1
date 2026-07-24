# ==============================================================================
# 06-bootstrap.ps1
# Master Orchestration Bootstrap Script for GitHub Automation Setup.
# Executes 01 through 05 sequentially, reporting status and final results.
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  HABIT TRACKER - GITHUB AUTOMATION BOOTSTRAP      " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Starting automation execution sequence..." -ForegroundColor Yellow
Write-Host ""

$StepScripts = @(
    "01-create-labels.ps1",
    "02-create-issues.ps1",
    "03-create-project.ps1",
    "04-populate-project.ps1",
    "05-verify-github.ps1"
)

$SuccessCount = 0
$FailedCount = 0

foreach ($Script in $StepScripts) {
    $FullPath = Join-Path $ScriptDir $Script
    Write-Host ">>> Executing: $Script ..." -ForegroundColor Cyan
    
    if (Test-Path $FullPath) {
        & $FullPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host ">>> [SUCCESS] $Script completed successfully." -ForegroundColor Green
            $SuccessCount++
        } else {
            Write-Host ">>> [WARNING/ERROR] $Script returned non-zero code ($LASTEXITCODE)." -ForegroundColor Yellow
            $FailedCount++
        }
    } else {
        Write-Host ">>> [ERROR] Script not found: $Script" -ForegroundColor Red
        $FailedCount++
    }
    Write-Host ""
}

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "           BOOTSTRAP EXECUTION COMPLETE             " -ForegroundColor Cyan
Write-Host "  Completed Steps: $SuccessCount / $($StepScripts.Count)                           " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
