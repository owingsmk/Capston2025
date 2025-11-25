<#
.SYNOPSIS
    Shared utility functions for logging, result formatting, and privilege checking.

.DESCRIPTION
    Provides common helper functions used throughout the toolkit for consistent
    logging, security check result formatting, and administrative privilege verification.
    These functions enable standardized audit output and logging across all modules.

.NOTES
    This module contains foundational utilities used by all other toolkit scripts.
    Functions support structured logging and standardized security audit results.
#>

# Logging + helpers (no Write-Host)

<#
.SYNOPSIS
    Logs messages to file with timestamp and severity level.

.DESCRIPTION
    Creates timestamped log entries with severity levels (INFO, WARN, ERROR, DEBUG).
    Logs are written to a file specified in $Script:LogPath. Returns the formatted
    log line for piping to Write-Output to display in console.

.PARAMETERS
    -Message [string] (Mandatory)
        The message text to log

    -Level [string]
        Severity level: INFO, WARN, ERROR, or DEBUG (default: INFO)

.EXAMPLE
    Write-Output (Write-Log -Message "System check complete" -Level INFO)

.NOTES
    File logging uses $Script:LogPath set by StartToolkit.
    Returns the log line so it can be piped to Write-Output for console display.
    Implements fail-safe: if file write fails, message is still returned to console.
#>
function Write-Log {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Message,
    [ValidateSet('INFO','WARN','ERROR','DEBUG')]
    [string]$Level = 'INFO'
  )
  
  # Format log line with timestamp and severity level
  $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $line = "$timestamp [$Level] $Message"
  
  # Persist to log file (uses $Script:LogPath from StartToolkit)
  # Wrapped in try/catch for resilience if file is inaccessible
  try { Add-Content -Path $Script:LogPath -Value $line } catch {}
  
  # Return the formatted line so caller can Write-Output it to console
  return $line
}

<#
.SYNOPSIS
    Creates a standardized security check result object.

.DESCRIPTION
    Formats audit check results into a consistent PSCustomObject with Name, Status,
    Severity, Details, and Remediation fields. Used by all audit functions to return
    structured results for display and reporting.

.PARAMETERS
    -Name [string] (Mandatory)
        The name of the security check (e.g., 'Firewall Status')

    -Status [string] (Mandatory)
        The check result status: OK, WARN, FAIL, or INFO

    -Severity [string]
        Risk severity level: Low, Medium, High, or Info (default: Info)

    -Details [string]
        Detailed description of the finding or current state

    -Remediation [string]
        Recommended actions to address the issue or maintain security

.EXAMPLE
    $result = New-CheckResult -Name 'Firewall Status' -Status 'OK' -Severity 'Info' -Details 'All profiles enabled' -Remediation ''

.NOTES
    All audit functions return CheckResult objects for standardized output.
    Status values: OK (compliant), WARN (warning), FAIL (critical), INFO (informational).
    Severity: High requires immediate attention, Medium should be addressed soon, Low is informational.
#>
function New-CheckResult {
  param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Status,     # "OK","WARN","FAIL","INFO"
    [ValidateSet('Low','Medium','High','Info')]
    [string]$Severity = 'Info',
    [string]$Details  = '',
    [string]$Remediation = ''
  )
  
  # Create standardized result object with audit information
  [PSCustomObject]@{
    Name        = $Name
    Status      = $Status
    Severity    = $Severity
    Details     = $Details
    Remediation = $Remediation
  }
}

<#
.SYNOPSIS
    Checks if the current PowerShell session is running with administrative privileges.

.DESCRIPTION
    Verifies that the script is running in an elevated (Administrator) context.
    Required for most security configuration and audit operations that need
    registry access, service management, or policy modifications.

.OUTPUT
    [bool] $true if running as admin, $false otherwise

.EXAMPLE
    if (-not (Test-IsAdmin)) {
        Write-Output "This script requires administrator privileges."
        exit 1
    }

.NOTES
    Uses Windows Identity and Principal classes for privilege verification.
    Returns $false and logs error if privilege check fails.
    Most toolkit functions require admin privileges to function correctly.
#>
function Test-IsAdmin {
  try {
    # Get current user identity
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    
    # Create principal object and check for Administrator role
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  } catch {
    # Error checking privileges - log and return false for safety
    Write-Output (Write-Log -Message "Admin check failed: $_" -Level ERROR)
    return $false
  }
}
