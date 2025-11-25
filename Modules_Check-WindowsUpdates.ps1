<#
.SYNOPSIS
    Checks Windows Update configuration and automatic updates status.

.DESCRIPTION
    Verifies that Windows Update automatic updates are enabled and configured correctly.
    Missing security patches represent a critical vulnerability as they prevent timely
    remediation of known exploits and security issues. This audit checks both policy
    configuration and installation history.

.FUNCTIONALITY
    - Checks AutoUpdate policy via registry (no external modules required)
    - Detects if automatic updates are disabled
    - Retrieves last successful update installation time
    - Returns detailed audit results with remediation guidance
    - Handles errors gracefully with appropriate reporting

.REGISTRY CHECKS
    Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    Key: NoAutoUpdate
    Values:
      - 1 = Automatic Updates disabled (CRITICAL)
      - 0 or missing = Automatic Updates enabled (GOOD)

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'Windows Update Configuration'
    - Status: 'FAIL', 'WARN', or 'INFO' (depends on findings and errors)
    - Details: Policy status and last update time
    - Remediation: Instructions to enable automatic updates
    - Severity: High (if disabled), Medium (if uncertain), or Low (if error)

.SECURITY IMPLICATIONS
    FAIL Status (NoAutoUpdate = 1):
    - Automatic updates are disabled by policy
    - Critical security risk - system lacks latest patches
    - Vulnerable to known exploits in the wild
    - Immediate remediation required

    WARN Status (Policy not found):
    - Policy not configured via Group Policy
    - Updates may be disabled through other means
    - Requires manual verification of update settings

.NOTES
    Requires: Admin privileges for registry access
    Registry-based check: works without Windows Update PowerShell module
    LastSuccessTime: Provides visibility into patch deployment cadence
    Use in conjunction with other security checks for defense-in-depth assessment.
#>

function Check-WindowsUpdates {
  [CmdletBinding()] param()
  try {
    # Query Windows Update AutoUpdate policy via registry (no external modules needed)
    $auKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    
    # Check if automatic updates are disabled (NoAutoUpdate = 1 means disabled)
    $mode = if (Test-Path $auKey) { (Get-ItemProperty -Path $auKey -Name NoAutoUpdate -ErrorAction SilentlyContinue).NoAutoUpdate } else { $null }

    # Determine status and severity based on policy setting
    $status = if ($mode -eq 1) { 'FAIL' } else { 'WARN' } # default to WARN if unknown
    $sev    = if ($mode -eq 1) { 'High' } else { 'Medium' }
    $details = if ($mode -eq 1) { 'Automatic Updates disabled by policy' } else { 'Policy not found or not enforced; verify Windows Update is active' }
    $remed   = 'Enable Automatic Updates via Group Policy or Settings > Windows Update.'

    # Get last successful update installation time for additional context (best-effort)
    $last = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install' -ErrorAction SilentlyContinue).LastSuccessTime
    if ($last) { $details += "; LastSuccessTime=$last" }

    # Return comprehensive check result
    $obj = New-CheckResult -Name 'Windows Update Configuration' -Status $status -Severity $sev -Details $details -Remediation $remed
    Write-Output (Write-Log -Message "Windows Update: $details ($status)" -Level INFO)
    return $obj
  } catch {
    # Error occurred during check - return informational result
    $obj = New-CheckResult -Name 'Windows Update Configuration' -Status 'INFO' -Severity 'Low' -Details "Check error: $_" -Remediation 'Run as admin; confirm registry access'
    Write-Output (Write-Log -Message "Windows Update check error: $_" -Level ERROR)
    return $obj
  }
}
