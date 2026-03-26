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
Check-FirewallStatus