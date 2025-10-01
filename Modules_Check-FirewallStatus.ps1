function Check-FirewallStatus {
  [CmdletBinding()] param()
  try {
    $profiles = Get-NetFirewallProfile
    $disabled = $profiles | Where-Object { -not $_.Enabled }
    if ($disabled) {
      $names = ($disabled.Name -join ', ')
      $remed = 'Open Windows Defender Firewall settings and enable for Domain, Private, and Public profiles.'
      $details = "Disabled profiles: $names"
      $obj = New-CheckResult -Name 'Firewall Status' -Status 'FAIL' -Severity 'High' -Details $details -Remediation $remed
      Write-Output (Write-Log -Message "Firewall FAIL: $names" -Level WARN)
      return $obj
    } else {
      $obj = New-CheckResult -Name 'Firewall Status' -Status 'OK' -Severity 'Info' -Details 'All profiles enabled' -Remediation ''
      Write-Output (Write-Log -Message "Firewall OK (all profiles enabled)" -Level INFO)
      return $obj
    }
  } catch {
    $obj = New-CheckResult -Name 'Firewall Status' -Status 'INFO' -Severity 'Low' -Details "Check error: $_" -Remediation 'Verify firewall cmdlets available'
    Write-Output (Write-Log -Message "Firewall check error: $_" -Level ERROR)
    return $obj
  }
}
