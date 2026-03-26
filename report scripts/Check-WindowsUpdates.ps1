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

function Check-WindowsUpdates {
  [CmdletBinding()] param()
  try {
    # Query policy via registry (works without external modules)
    $auKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    $mode = if (Test-Path $auKey) { (Get-ItemProperty -Path $auKey -Name NoAutoUpdate -ErrorAction SilentlyContinue).NoAutoUpdate } else { $null }

    $status = if ($mode -eq 1) { 'FAIL' } else { 'WARN' } # default to WARN if unknown
    $sev    = if ($mode -eq 1) { 'High' } else { 'Medium' }
    $details = if ($mode -eq 1) { 'Automatic Updates disabled by policy' } else { 'Policy not found or not enforced; verify Windows Update is active' }
    $remed   = 'Enable Automatic Updates via Group Policy or Settings > Windows Update.'

    # Quick freshness check: last successful update install time (best-effort)
    $last = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install' -ErrorAction SilentlyContinue).LastSuccessTime
    if ($last) { $details += "; LastSuccessTime=$last" }

    $obj = New-CheckResult -Name 'Windows Update Configuration' -Status $status -Severity $sev -Details $details -Remediation $remed
    Write-Output (Write-Log -Message "Windows Update: $details ($status)" -Level INFO)
    return $obj
  } catch {
    $obj = New-CheckResult -Name 'Windows Update Configuration' -Status 'INFO' -Severity 'Low' -Details "Check error: $_" -Remediation 'Run as admin; confirm registry access'
    Write-Output (Write-Log -Message "Windows Update check error: $_" -Level ERROR)
    return $obj
  }
}
Check-WindowsUpdates