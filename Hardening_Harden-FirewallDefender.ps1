function Harden-FirewallDefender {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  if ($WhatIf) {
    Write-Output (Write-Log -Message 'Would enable all firewall profiles & Defender real-time protection' -Level INFO)
    return
  }
  Set-NetFirewallProfile -All -Enabled True
  Set-MpPreference -DisableRealtimeMonitoring $false
  Write-Output (Write-Log -Message 'Enabled firewall (all profiles) and Defender RTP' -Level INFO)
}
