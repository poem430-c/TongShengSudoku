# Mama's Sudoku — Windows setup helper
# Run in PowerShell from the project folder:
#   Set-ExecutionPolicy -Scope Process Bypass
#   .\setup_windows.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

Write-Host "==> Checking for Flutter..." -ForegroundColor Cyan
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
  Write-Host "Flutter is not on PATH." -ForegroundColor Yellow
  Write-Host "Install from: https://docs.flutter.dev/get-started/install/windows"
  Write-Host "Then reopen PowerShell and run this script again."
  exit 1
}

flutter --version
Write-Host ""
Write-Host "==> Creating platform folders (windows/ios/android) if needed..." -ForegroundColor Cyan
flutter create . --project-name mama_sudoku --platforms=windows,android,ios

Write-Host ""
Write-Host "==> Installing packages..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "==> Done. Launch with:" -ForegroundColor Green
Write-Host "    flutter run -d windows"
