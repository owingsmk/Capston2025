<#
.SYNOPSIS
    Audits system hardening baseline for common security vulnerabilities.

.DESCRIPTION
    Checks for frequently exploited weak configurations that leave systems vulnerable.
    Identifies enabled legacy protocols, dangerous remote access methods, and outdated
    services. Provides remediation guidance for each finding.

.FUNCTIONALITY
    - Checks if SMBv1 (legacy file sharing) is enabled
    - Verifies RDP (Remote Desktop) enablement status
    - Detects if Telnet service is running
    - Aggregates findings with severity ratings
    - Provides remediation recommendations
    - Supports audit-only mode

.SECURITY CHECKS

    1. SMBv1 (Server Message Block v1):
       - Legacy file sharing protocol with known critical vulnerabilities
       - Vulnerable to WannaCry, NotPetya ransomware attacks
       - Should be disabled on all modern systems
       - Replaced by SMBv2/v3 with better security

    2. RDP (Remote Desktop Protocol):
       - Remote access service often exposed to brute force attacks
       - Should be restricted to trusted networks
       - Verify firewall and NAT rules prevent internet exposure
       - Monitor for unauthorized access attempts

    3. Telnet Service:
       - Plaintext remote access protocol
       - Transmits all traffic (including credentials) unencrypted
       - No authentication protection
       - Should always be stopped and disabled

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'System Hardening Baseline'
    - Status: 'OK', 'WARN', or 'INFO' (depends on findings and errors)
    - Details: List of vulnerable settings detected
    - Remediation: Step-by-step instructions to harden system
    - Severity: Info (pass), Medium (warnings), or Low (errors)

.SECURITY IMPLICATIONS
    OK Status:
    - No common weak settings detected
    - System follows hardening baseline
    - Reduces attack surface

    WARN Status:
    - One or more weak configurations found
    - System exposed to known attack vectors
    - Should remediate immediately

.NOTES
    Requires: Admin privileges, Get-WindowsOptionalFeature cmdlet
    Best-effort check for RDP: Checks registry; verify firewall rules separately
    Related scripts: Use Harden/* scripts for step-by-step remediation
    Use in conjunction with other audit functions for comprehensive assessment.
#>

function Harden-System {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  try {
    $findings = @()

    # Check if SMBv1 (legacy file sharing protocol) is enabled
    # SMBv1 is vulnerable to WannaCry and other ransomware; should always be disabled
    $smb = (Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue)
    if ($smb.State -eq 'Enabled') {
      $findings += 'SMBv1 enabled'
    }

    # Check if RDP (Remote Desktop) is enabled
    # RDP is frequently targeted for brute force attacks; verify firewall protection
    # fDenyTSConnections: 0 = RDP enabled (allowed), 1 = RDP disabled (denied)
    $rdp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections
    if ($rdp -eq 0) { $findings += 'RDP enabled (verify exposure via firewall/NAT)' }

    # Check if Telnet service is running
    # Telnet transmits credentials in plaintext; should always be stopped and disabled
    $telnet = Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue
    if ($telnet -and $telnet.Status -ne 'Stopped') { $findings += 'Telnet service running' }

    if ($findings.Count -gt 0) {
      # Vulnerabilities found - provide detailed remediation
      $rem = 'Disable SMBv1; restrict/disable RDP; stop/disable Telnet. Use Harden/* scripts for step-by-step.'
      $obj = New-CheckResult -Name 'System Hardening Baseline' -Status 'WARN' -Severity 'Medium' -Details ($findings -join '; ') -Remediation $rem
      Write-Output (Write-Log -Message "Hardening WARN: $($findings -join '; ')" -Level WARN)
      return $obj
    } else {
      # No weak settings detected - pass the audit
      $ok = New-CheckResult -Name 'System Hardening Baseline' -Status 'OK' -Severity 'Info' -Details 'No common weak settings detected' -Remediation ''
      Write-Output (Write-Log -Message "Hardening OK" -Level INFO)
      return $ok
    }
  } catch {
    # Error occurred during audit - return informational result
    $obj = New-CheckResult -Name 'System Hardening Baseline' -Status 'INFO' -Severity 'Low' -Details "Hardening check error: $_" -Remediation 'Run as admin'
    Write-Output (Write-Log -Message "Hardening error: $_" -Level ERROR)
    return $obj
  }
}
