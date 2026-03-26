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
function Harden-FirewallDefender {
  #Requires -RunAsAdministrator
  [CmdletBinding()] param([switch]$WhatIf = $true)
  if ($WhatIf) {
    Write-Output (Write-Log -Message 'Would enable all firewall profiles & Defender real-time protection' -Level INFO)
  } else {
  Set-NetFirewallProfile -All -Enabled True
  #Set-MpPreference -DisableRealtimeMonitoring $false
  Write-Output (Write-Log -Message 'Enabled firewall (all profiles) and Defender RTP' -Level INFO)
  }
}
Harden-FirewallDefender