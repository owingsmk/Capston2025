<#
.SYNOPSIS
    Checks the status of Windows Firewall across all network profiles.

.DESCRIPTION
    Verifies that Windows Firewall is enabled for all network profiles (Domain, Private, Public).
    A disabled firewall represents a critical security gap that leaves the system vulnerable to
    network-based attacks. This audit helps ensure firewall protection is active.

.FUNCTIONALITY
    - Retrieves status of all firewall profiles
    - Identifies which profiles are disabled
    - Returns detailed audit results with remediation
    - Handles errors gracefully with appropriate reporting

.FIREWALL PROFILES CHECKED
    - Domain Profile: Corporate/managed networks
    - Private Profile: Home/trusted networks
    - Public Profile: Public/untrusted networks

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'Firewall Status'
    - Status: 'OK', 'FAIL', or 'INFO' (depends on findings and errors)
    - Details: List of disabled profiles or error description
    - Remediation: Recommended actions to address issues
    - Severity: Info, High (for failures), or Low (for errors)

.SECURITY IMPLICATIONS
    OK Status:
    - All firewall profiles are enabled
    - System has network perimeter protection
    - Network-based attack vectors are mitigated

    FAIL Status:
    - One or more firewall profiles are disabled
    - Critical security vulnerability
    - System is exposed to network attacks
    - Immediate remediation recommended

.NOTES
    Requires: PowerShell 5+, NetSecurity module, Admin privileges
    Firewall should be enabled on all profiles regardless of network type
    Use in conjunction with antivirus and other defense-in-depth controls.
#>

function Check-FirewallStatus {
  [CmdletBinding()] param()
  try {
    # Retrieve firewall status for all network profiles
    $profiles = Get-NetFirewallProfile
    
    # Identify any disabled firewall profiles
    $disabled = $profiles | Where-Object { -not $_.Enabled }
    
    if ($disabled) {
      # Firewall is disabled on one or more profiles - critical issue
      $names = ($disabled.Name -join ', ')
      $remed = 'Open Windows Defender Firewall settings and enable for Domain, Private, and Public profiles.'
      $details = "Disabled profiles: $names"
      $obj = New-CheckResult -Name 'Firewall Status' -Status 'FAIL' -Severity 'High' -Details $details -Remediation $remed
      Write-Output (Write-Log -Message "Firewall FAIL: $names" -Level WARN)
      return $obj
    } else {
      # All firewall profiles are enabled - pass the check
      $obj = New-CheckResult -Name 'Firewall Status' -Status 'OK' -Severity 'Info' -Details 'All profiles enabled' -Remediation ''
      Write-Output (Write-Log -Message "Firewall OK (all profiles enabled)" -Level INFO)
      return $obj
    }
  } catch {
    # Error occurred during check - return informational result
    $obj = New-CheckResult -Name 'Firewall Status' -Status 'INFO' -Severity 'Low' -Details "Check error: $_" -Remediation 'Verify firewall cmdlets available'
    Write-Output (Write-Log -Message "Firewall check error: $_" -Level ERROR)
    return $obj
  }
}
