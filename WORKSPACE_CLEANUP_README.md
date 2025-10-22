# Workspace Cleanup Script

## Overview
This PowerShell script automates the process of cleaning up your Windows workspace and opening your essential work applications in a single Microsoft Edge window.

## What It Does

### 1. Closes All File Explorer Windows
- Restarts Windows Explorer to quickly close all open File Explorer windows
- Explorer is automatically restarted to maintain system functionality

### 2. Closes Other Applications
The script closes all running applications **except**:
- PowerShell/Windows Terminal
- Claude Desktop

### 3. Opens Work Tabs in Edge
Opens the following URLs in a single maximized Microsoft Edge window:
- Gmail Inbox
- Google Calendar
- Duracube Online

### 4. Self-Closes
The script automatically closes the PowerShell window after completing all tasks.

## Usage

### Prerequisites
- Windows 10 or later
- Microsoft Edge installed
- PowerShell 5.1 or later

### How to Run

**Option 1: Right-click and Run**
1. Right-click on `workspace-cleanup.ps1`
2. Select "Run with PowerShell"

**Option 2: From PowerShell**
```powershell
.\workspace-cleanup.ps1
```

**Option 3: From Command Prompt**
```cmd
powershell -ExecutionPolicy Bypass -File workspace-cleanup.ps1
```

### Execution Policy
If you encounter an execution policy error, you may need to temporarily bypass it:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\workspace-cleanup.ps1
```

## Customization

### Modify Kept Applications
Edit the `$keepProcesses` array to change which applications remain open:
```powershell
$keepProcesses = @(
    "powershell",
    "WindowsTerminal",
    "Claude",
    "ClaudeDesktop",
    "Claude Desktop",
    "claude"
)
```

### Modify URLs
Edit the `$urls` array to change which websites open:
```powershell
$urls = @(
    "https://mail.google.com/mail/u/0/#inbox",
    "https://calendar.google.com/calendar/u/0/r",
    "https://duracubeonline.com.au/web#action=menu&cids=1"
)
```

### Change Browser
To use Chrome instead of Edge, change:
```powershell
$edgePath = "chrome.exe"
```

## Safety Notes

- **Save your work**: The script force-closes applications, so save all work before running
- **Claude Desktop protection**: Claude Desktop is protected from being closed
- **Explorer restart**: Windows Explorer briefly restarts, which may cause a momentary screen flicker

## Troubleshooting

### Script doesn't run
- Check PowerShell execution policy
- Run PowerShell as Administrator

### Applications don't close
- Some applications may require administrator privileges to close
- Add specific process names to the `$keepProcesses` array if needed

### Edge doesn't open
- Verify Microsoft Edge is installed
- Check that the `msedge.exe` is in your system PATH

## File Location
- Script: `workspace-cleanup.ps1`
- Documentation: `WORKSPACE_CLEANUP_README.md`
