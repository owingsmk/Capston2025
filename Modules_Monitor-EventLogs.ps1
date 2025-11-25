<#
.SYNOPSIS
    Monitors Windows Security event logs for suspicious authentication and privilege activity.

.DESCRIPTION
    Analyzes recent Security event logs to detect indicators of compromise and suspicious behavior.
    Tracks failed login attempts and unauthorized administrative group changes. Helps identify
    brute force attacks, unauthorized access attempts, and privilege escalation activity.

.PARAMETERS
    -AuditOnly [switch]
        When $true (default), performs audit without making changes.
        When $false, reserved for future enforcement actions.

.FUNCTIONALITY
    - Queries Security event log for recent events
    - Counts failed login attempts (Event ID 4625)
    - Counts administrative group membership changes (Event ID 4728)
    - Calculates activity summary over configurable time period
    - Determines risk level based on event thresholds
    - Returns detailed audit results with investigation guidance

.EVENT IDS MONITORED
    Event ID 4625 - Failed Login Attempt:
    - Indicates authentication failure on account
    - Multiple failures = brute force attack attempt
    - May indicate compromised credentials being tested
    - Baseline threshold: > 5 in time period = elevated risk

    Event ID 4728 - User Added to Local Group:
    - Indicates privilege modification
    - Adding users to admin group = privilege escalation
    - Should only occur during planned admin provisioning
    - Any unexpected change = immediate investigation

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'Security Events Summary'
    - Status: 'OK' or 'WARN' (depends on event counts)
    - Details: Failed logon count and admin group change count
    - Remediation: Investigation guidance and monitoring recommendations
    - Severity: Low (normal), or Medium (suspicious activity detected)

.SECURITY IMPLICATIONS
    OK Status:
    - Few failed logons (<=5 in period)
    - No unexpected admin group changes
    - System appears secure from auth/privilege attacks

    WARN Status:
    - High volume of failed logons (possible brute force)
    - Admin group changes detected (possible escalation)
    - Requires immediate investigation and response

.CONFIGURATION
    Time period: $Global:ToolkitSettings.AuditLogDaysBack (days to look back)
    Default: Typically 7-30 days depending on baseline

.NOTES
    Requires: Admin privileges, Security event log access
    Built-in logs: Security event log is always available
    Advanced monitoring: Recommend enabling Sysmon for deeper visibility into system activity
    Investigation tools: Use Event Viewer or PowerShell to examine individual events
    Log retention: Ensure Security log retention is configured (min 30 days recommended).
#>

function Monitor-EventLogs {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  try {
    # Load audit lookback period from configuration
    $days = $Global:ToolkitSettings.AuditLogDaysBack
    $since = (Get-Date).AddDays(-$days)

    # Query Event ID 4625 (Failed Login) - indicates brute force or auth issues
    $failedLogons = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4625; StartTime=$since } -ErrorAction SilentlyContinue
    
    # Query Event ID 4728 (User Added to Local Group) - indicates privilege changes
    $adminAdds    = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4728; StartTime=$since } -ErrorAction SilentlyContinue

    # Create summary of findings
    $detail = "FailedLogons(last $days d)=$($failedLogons.Count); AdminGroupChanges=$($adminAdds.Count)"
    
    # Determine severity: Medium if high failed logons or any admin changes; Low otherwise
    $sev = if ($failedLogons.Count -gt 5 -or $adminAdds.Count -gt 0) { 'Medium' } else { 'Low' }
    $status = if ($sev -eq 'Medium') { 'WARN' } else { 'OK' }

    # Provide investigation and monitoring recommendations
    $rem = 'Investigate repeated failed logons and unexpected admin group changes; enable Sysmon for richer telemetry.'
    $obj = New-CheckResult -Name 'Security Events Summary' -Status $status -Severity $sev -Details $detail -Remediation $rem
    Write-Output (Write-Log -Message "EventLog summary: $detail ($status)" -Level INFO)
    return $obj
  } catch {
    # Error occurred during log query - return informational result
    $obj = New-CheckResult -Name 'Security Events Summary' -Status 'INFO' -Severity 'Low' -Details "Log query error: $_" -Remediation 'Ensure Security log access; run as admin'
    Write-Output (Write-Log -Message "EventLog error: $_" -Level ERROR)
    return $obj
  }
}
