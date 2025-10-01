function Harden-System {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  try {
    $findings = @()

    # SMBv1
    $smb = (Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue)
    if ($smb.State -eq 'Enabled') {
      $findings += 'SMBv1 enabled'
    }

    # RDP open to Internet (best-effort): if RDP enabled
    $rdp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections
    if ($rdp -eq 0) { $findings += 'RDP enabled (verify exposure via firewall/NAT)' }

    # Telnet service
    $telnet = Get-Service -Name 'TlntSvr' -ErrorAction SilentlyContinue
    if ($telnet -and $telnet.Status -ne 'Stopped') { $findings += 'Telnet service running' }

    if ($findings.Count -gt 0) {
      $rem = 'Disable SMBv1; restrict/disable RDP; stop/disable Telnet. Use Harden/* scripts for step-by-step.'
      $obj = New-CheckResult -Name 'System Hardening Baseline' -Status 'WARN' -Severity 'Medium' -Details ($findings -join '; ') -Remediation $rem
      Write-Output (Write-Log -Message "Hardening WARN: $($findings -join '; ')" -Level WARN)
      return $obj
    } else {
      $ok = New-CheckResult -Name 'System Hardening Baseline' -Status 'OK' -Severity 'Info' -Details 'No common weak settings detected' -Remediation ''
      Write-Output (Write-Log -Message "Hardening OK" -Level INFO)
      return $ok
    }
  } catch {
    $obj = New-CheckResult -Name 'System Hardening Baseline' -Status 'INFO' -Severity 'Low' -Details "Hardening check error: $_" -Remediation 'Run as admin'
    Write-Output (Write-Log -Message "Hardening error: $_" -Level ERROR)
    return $obj
  }
}
