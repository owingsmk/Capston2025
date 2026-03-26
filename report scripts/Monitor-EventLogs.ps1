function Write-Log {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Message,
    [ValidateSet('INFO','WARN','ERROR','DEBUG')]
    [string]$Level = 'INFO'
  )
  $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $line = "$timestamp [$Level] $Message"
  # Persist to file (uses $Script:LogPath from StartToolkit)
  try { Add-Content -Path $Script:LogPath -Value $line } catch {}
  # Return the line so caller can Write-Output it
  return $line
}

function New-CheckResult {
  param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Status,     # "OK","WARN","FAIL","INFO"
    [ValidateSet('Low','Medium','High','Info')]
    [string]$Severity = 'Info',
    [string]$Details  = '',
    [string]$Remediation = ''
  )
  [PSCustomObject]@{
    Name        = $Name
    Status      = $Status
    Severity    = $Severity
    Details     = $Details
    Remediation = $Remediation
  }
}
function Monitor-EventLogs {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  try {
    $days = 7 #Set to 7 days in config file
    $since = (Get-Date).AddDays(-$days)

    $failedLogons = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4625; StartTime=$since } -ErrorAction SilentlyContinue
    $adminAdds    = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4728; StartTime=$since } -ErrorAction SilentlyContinue

    $detail = "FailedLogons(last $days d)=$($failedLogons.Count); AdminGroupChanges=$($adminAdds.Count)"
    $sev = if ($failedLogons.Count -gt 5 -or $adminAdds.Count -gt 0) { 'Medium' } else { 'Low' }
    $status = if ($sev -eq 'Medium') { 'WARN' } else { 'OK' }

    $rem = 'Investigate repeated failed logons and unexpected admin group changes; enable Sysmon for richer telemetry.'
    $obj = New-CheckResult -Name 'Security Events Summary' -Status $status -Severity $sev -Details $detail -Remediation $rem
    Write-Output (Write-Log -Message "EventLog summary: $detail ($status)" -Level INFO)
    return $obj
  } catch {
    $obj = New-CheckResult -Name 'Security Events Summary' -Status 'INFO' -Severity 'Low' -Details "Log query error: $_" -Remediation 'Ensure Security log access; run as admin'
    Write-Output (Write-Log -Message "EventLog error: $_" -Level ERROR)
    return $obj
  }
}
Monitor-EventLogs