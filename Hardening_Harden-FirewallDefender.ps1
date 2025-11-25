<#
.SYNOPSIS
    Enables Windows Firewall and Windows Defender real-time protection for enhanced security.

.DESCRIPTION
    Hardens system security by ensuring Windows Firewall is enabled across all network
    profiles and activates Windows Defender's real-time malware monitoring and protection.
    This provides multiple layers of defense against network-based attacks and malicious software.

.PARAMETERS
    -WhatIf [switch]
        When $true (default), shows what would be changed without applying.
        When $false, enables firewall and Defender protection immediately.

.FUNCTIONALITY
    - Enables Windows Firewall for all network profiles (Domain, Private, Public)
    - Enables Windows Defender real-time monitoring (RTP)
    - Provides network perimeter defense and malware protection
    - Supports audit mode for testing before applying changes

.FIREWALL PROFILES
    - Domain Profile: For corporate/managed networks
    - Private Profile: For home/trusted networks
    - Public Profile: For public/untrusted networks

.SECURITY IMPACT
    - Blocks unauthorized inbound connections
    - Allows outbound traffic based on rules
    - Real-time scanning of files and processes for malware
    - Provides signature-based and behavioral detection

.NOTES
    Requires admin privileges. Both Windows Firewall and Defender should be enabled
    for comprehensive defense. Use in conjunction with other security hardening measures.
#>

function Harden-FirewallDefender {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  
  if ($WhatIf) {
    # Audit mode: Report what would be changed
    Write-Output (Write-Log -Message 'Would enable all firewall profiles & Defender real-time protection' -Level INFO)
    return
  }
  
  # Enable Windows Firewall for all network profiles (Domain, Private, Public)
  Set-NetFirewallProfile -All -Enabled True
  
  # Enable Windows Defender real-time monitoring (RTP) for active malware protection
  Set-MpPreference -DisableRealtimeMonitoring $false
  
  Write-Output (Write-Log -Message 'Enabled firewall (all profiles) and Defender RTP' -Level INFO)
}
