<#
.SYNOPSIS
    Entry point for the Windows Security Toolkit - comprehensive security audit and hardening tool.

.DESCRIPTION
    Initializes the Security Toolkit by loading shared utilities, configuration, and audit modules.
    Supports two execution modes: console (command-line) for quick audit output, or GUI (Windows Forms)
    for interactive interface. All audit results are logged to file for compliance and review.

.PARAMETER NoGui
    When specified, runs in console mode showing audit results in a formatted table.
    When omitted (default), launches the GUI interface for interactive use.

.FUNCTIONALITY
    - Initializes logging infrastructure with timestamped audit trail
    - Loads shared utility functions (logging, result formatting, privilege checking)
    - Loads configuration baseline settings
    - Dynamically loads all audit and hardening modules
    - Executes security audit checks
    - Displays results in console or GUI based on parameter
    - Logs all activities for audit trail

.CONSOLE MODE (NoGui)
    Executes all security checks and displays results in table format:
    - Firewall Status
    - Windows Updates Configuration
    - User Account Audit
    - Password Policy Compliance
    - USB Access Control
    - Security Event Log Monitoring
    - System Hardening Baseline
    Results are sorted by severity (highest first) for priority assessment.

.GUI MODE (Default)
    Launches interactive Windows Forms interface for:
    - Manual check execution
    - Detailed result viewing
    - System information and reports
    - Setup and configuration guidance

.LOG LOCATION
    Logs directory: [ToolkitRoot]\Logs\
    Log file: SecurityToolkit.log
    Format: timestamp [LEVEL] message

.EXAMPLES
    # Run with GUI (default)
    PS> .\StartToolKit.ps1

    # Run console audit only
    PS> .\StartToolKit.ps1 -NoGui

.REQUIREMENTS
    - Administrator privileges required for most audit functions
    - PowerShell 5.0 or higher
    - Windows 10/Server 2016 or later
    - Shared utilities and configuration files must be present

.NOTES
    Toolkit modules are dynamically loaded via dot-sourcing from Modules directory.
    Logs are created in Logs directory for audit trail and troubleshooting.
    Configuration settings loaded from Config\settings.ps1 and $Global:ToolkitSettings.
#>

[CmdletBinding()]
param(
  [switch]$NoGui
)

$ErrorActionPreference = 'Stop'

# --- Resolve toolkit directory structure ---
# These variables establish the standard folder layout for the toolkit
$Script:Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:Shared  = Join-Path $Root 'Shared'     # Shared utility functions
$Script:Modules = Join-Path $Root 'Modules'    # Audit and check modules
$Script:Config  = Join-Path $Root 'Config'     # Configuration and settings
$Script:LogsDir = Join-Path $Root 'Logs'       # Log file directory
$Script:LogPath = Join-Path $LogsDir 'SecurityToolkit.log'  # Main log file

# --- Ensure logs folder exists ---
# Create Logs directory if it doesn't exist to ensure file logging works
if (-not (Test-Path $LogsDir)) { New-Item -Path $LogsDir -ItemType Directory | Out-Null }

# --- Load common functions and configuration ---
# Load shared utilities (logging, result formatting, admin checks)
. (Join-Path $Shared 'Common-Functions.ps1')
# Load baseline security settings and requirements
. (Join-Path $Config 'settings.ps1')

Write-Output (Write-Log -Message "Toolkit starting..." -Level INFO)

# --- Dynamically load all audit and hardening modules ---
# Dot-source all .ps1 files in Modules directory to make functions available
Get-ChildItem -Path $Modules -Filter *.ps1 | ForEach-Object {
  . $_.FullName
  Write-Output (Write-Log -Message "Loaded module: $($_.Name)" -Level DEBUG)
}

if ($NoGui) {
  # --- Console Mode: Execute all security checks and display results in table ---
  # Run audit checks (most in audit-only mode for safety)
  $results = @()
  $results += Check-FirewallStatus
  $results += Check-WindowsUpdates
  $results += Audit-UserAccounts
  $results += Enforce-PasswordPolicy -AuditOnly  # audit mode by default
  $results += Control-USBAccess -AuditOnly       # audit mode by default
  $results += Monitor-EventLogs   -AuditOnly     # audit mode by default
  $results += Harden-System       -AuditOnly     # audit mode by default

  # Display results sorted by severity (highest first) for quick prioritization
  Write-Output ($results | Sort-Object Severity -Descending | Format-Table -AutoSize | Out-String)
  Write-Output (Write-Log -Message "Toolkit finished (console)." -Level INFO)
}
else {
  # --- GUI Mode: Launch interactive Windows Forms interface ---
  # Load and execute GUI module for interactive security toolkit
  $guiPath = Join-Path (Join-Path $Root 'GUI') 'SecurityToolkitGUI.ps1'
  . $guiPath
  Start-SecurityToolkitGUI
}
