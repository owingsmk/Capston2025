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
