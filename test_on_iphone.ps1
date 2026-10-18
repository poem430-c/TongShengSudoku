# 喺 iPhone Safari 測試（port 8000）
# 用法：右鍵 → 用 PowerShell 執行

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

$env:PATH = "C:\src\flutter\bin;$env:PATH"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Mama's Sudoku - iPhone 測試伺服器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 搵 Wi-Fi IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -and $_.IPAddress -notlike "169.254.*" } |
  Select-Object -First 1).IPAddress

if (-not $ip) {
  $ip = "（請用 ipconfig 搵 IP）"
}

Write-Host "你部電腦 IP：" -NoNewline
Write-Host " $ip" -ForegroundColor Green
Write-Host ""
Write-Host "iPhone Safari 打開：" -ForegroundColor Yellow
Write-Host "  http://${ip}:8000" -ForegroundColor White
Write-Host ""
Write-Host "電腦 Chrome 測試：" -ForegroundColor Yellow
Write-Host "  http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "伺服器啟動中... 唔好關呢個視窗！" -ForegroundColor Cyan
Write-Host ""

flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000
