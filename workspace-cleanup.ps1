# ============================================
# CLOSE ALL WINDOWS EXCEPT POWERSHELL & CLAUDE
# ============================================
Write-Host "=== Starting Complete Cleanup ===" -ForegroundColor Green

# Processes to KEEP OPEN
$keepProcesses = @(
    "powershell",
    "WindowsTerminal",
    "Claude",
    "ClaudeDesktop",
    "Claude Desktop",
    "claude"
)

# STEP 1: QUICK RESTART EXPLORER TO CLOSE ALL ITS WINDOWS
Write-Host "Restarting Explorer to close all File Explorer windows..." -ForegroundColor Red
# Save current Explorer PID
$explorerPID = (Get-Process explorer).Id
# Kill Explorer
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 1
# Restart Explorer immediately
Start-Process explorer
Start-Sleep -Seconds 2
Write-Host "Explorer restarted - all File Explorer windows closed" -ForegroundColor Green

# STEP 2: CLOSE ALL OTHER WINDOWS
Write-Host "Closing all other applications..." -ForegroundColor Yellow
$processes = Get-Process | Where-Object { $_.MainWindowTitle -ne "" }
foreach ($proc in $processes) {
    if ($proc.ProcessName -notin $keepProcesses -and $proc.ProcessName -ne "explorer") {
        try {
            Write-Host "Closing: $($proc.ProcessName) - $($proc.MainWindowTitle)" -ForegroundColor Yellow
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Could not close: $($proc.ProcessName)" -ForegroundColor Red
        }
    }
}

# Wait for everything to settle
Start-Sleep -Seconds 2

# STEP 3: OPEN ALL 3 TABS IN ONE EDGE WINDOW (MAXIMIZED)
Write-Host "Opening your work tabs in one window..." -ForegroundColor Cyan

# Build the Edge command with all 3 URLs to open in one window
$edgePath = "msedge.exe"
$urls = @(
    "https://mail.google.com/mail/u/0/#inbox",
    "https://calendar.google.com/calendar/u/0/r",
    "https://duracubeonline.com.au/web#action=menu&cids=1"
)

# Start Edge with all URLs (opens in tabs) and maximize
$edgeProcess = Start-Process $edgePath -ArgumentList $urls -PassThru
Start-Sleep -Seconds 3

# Maximize the Edge window
$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $sig -Name NativeMethods -Namespace Win32
$edgeWindows = Get-Process -Name "msedge" | Where-Object {$_.MainWindowHandle -ne 0}
foreach ($window in $edgeWindows) {
    [Win32.NativeMethods]::ShowWindowAsync($window.MainWindowHandle, 3) | Out-Null
}

Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host "Opened in one window (3 tabs):" -ForegroundColor Green
Write-Host "  - Gmail Inbox" -ForegroundColor White
Write-Host "  - Google Calendar" -ForegroundColor White
Write-Host "  - Duracube Online" -ForegroundColor White
Write-Host "Kept Open:" -ForegroundColor Green
Write-Host "  - Claude Desktop" -ForegroundColor White

# Wait a moment to show completion message
Start-Sleep -Seconds 2

# STEP 4: FORCE CLOSE POWERSHELL
Write-Host "Closing PowerShell..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

# Force close PowerShell by killing its own process
Stop-Process -Id $PID -Force
