<# 
.SYNOPSIS
  Entry point for the Windows Security Toolkit
.PARAMETER NoGui
  Run in console (no WinForms)
#>

[CmdletBinding()]
param(
  [switch]$NoGui
)

$ErrorActionPreference = 'Stop'

# --- Resolve paths ---
$Script:Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:Shared  = Join-Path $Root 'Shared'
$Script:Modules = Join-Path $Root 'Modules'
$Script:Config  = Join-Path $Root 'Config'
$Script:LogsDir = Join-Path $Root 'Logs'
$Script:LogPath = Join-Path $LogsDir 'SecurityToolkit.log'

# --- Ensure logs folder exists ---
if (-not (Test-Path $LogsDir)) { New-Item -Path $LogsDir -ItemType Directory | Out-Null }

# --- Load common + settings ---
. (Join-Path $Shared 'Common-Functions.ps1')
. (Join-Path $Config 'settings.ps1')

Write-Output (Write-Log -Message "Toolkit starting..." -Level INFO)

# --- Load modules (dot-source so functions are available) ---
Get-ChildItem -Path $Modules -Filter *.ps1 | ForEach-Object {
  . $_.FullName
  Write-Output (Write-Log -Message "Loaded module: $($_.Name)" -Level DEBUG)
}

if ($NoGui) {
  # Console run: execute all checks and print a quick table
  $results = @()
  $results += Check-FirewallStatus
  $results += Check-WindowsUpdates
  $results += Audit-UserAccounts
  $results += Enforce-PasswordPolicy -AuditOnly  # audit mode by default
  $results += Control-USBAccess -AuditOnly
  $results += Monitor-EventLogs   -AuditOnly
  $results += Harden-System       -AuditOnly

  Write-Output ($results | Sort-Object Severity -Descending | Format-Table -AutoSize | Out-String)
  Write-Output (Write-Log -Message "Toolkit finished (console)." -Level INFO)
}
else {
  # GUI launcher
  $guiPath = Join-Path (Join-Path $Root 'GUI') 'SecurityToolkitGUI.ps1'
  . $guiPath
  Start-SecurityToolkitGUI
}
