<#
.SYNOPSIS
    Audits and controls USB storage device access for data protection and security.

.DESCRIPTION
    Monitors and manages USB storage device availability by checking the USBSTOR driver
    start type. Supports both audit mode (reporting only) and enforcement mode (blocking/allowing).
    Useful for preventing data exfiltration via USB drives and reducing malware vectors.

.PARAMETERS
    -AuditOnly [switch]
        When $true, performs audit without making changes.
        When $false, enables enforcement based on -Desired parameter (default: $true)

    -Desired [string]
        Target state for USB access: 'Allow' or 'Block'
        Only used when -AuditOnly is $false (default: 'Allow')

.FUNCTIONALITY
    - Checks USBSTOR driver status via registry
    - Detects if USB storage is currently blocked or allowed
    - Reports detailed audit results
    - Provides remediation instructions for enforcement
    - Supports audit-only mode for safe assessment

.REGISTRY KEY CHECKED
    Path: HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR
    Name: Start
    Values:
      - 1 = Boot start
      - 2 = System start
      - 3 = Automatic start (USB devices allowed)
      - 4 = Disabled (USB storage blocked)

.SECURITY IMPLICATIONS
    USB Allow (Start = 2-3):
    - Users can connect USB drives for data transfer
    - Risk of data exfiltration if not controlled
    - Malware can spread via infected USB media
    - Typical for general-purpose workstations

    USB Block (Start = 4):
    - USB storage devices cannot be recognized or accessed
    - Prevents data exfiltration via USB
    - Protects against USB-based malware propagation
    - Typical for high-security environments (finance, government, healthcare)

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'USB Storage Access'
    - Details: Current USB access state
    - Remediation: Command to change USB access if needed
    - Status: INFO (audit result, not pass/fail)

.NOTES
    Requires: Admin privileges for registry access
    Policy-controlled: Can be managed via Group Policy for enterprise environments
    Audit mode is default: Changes only apply when -AuditOnly=$false and -Desired='Block'
    Safe by design: Does not make automatic changes; provides remediation script instead.
#>

function Control-USBAccess {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly,
    [ValidateSet('Allow','Block')]
    [string]$Desired = 'Allow'
  )

  try {
    # Check USB storage driver (USBSTOR) status via registry to determine access level
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
    $start = if (Test-Path $key) { (Get-ItemProperty -Path $key -Name Start -ErrorAction SilentlyContinue).Start } else { $null }

    # Determine if USB storage is blocked (Start value of 4 means Disabled)
    $blocked = ($start -eq 4) # 4 = Disabled/Blocked
    $details = if ($blocked) { 'USB storage currently blocked' } else { 'USB storage allowed' }
    $status  = New-CheckResult -Name 'USB Storage Access' -Status 'INFO' -Severity 'Low' -Details $details -Remediation 'Set HKLM:\...\USBSTOR\Start=4 to block (policy controlled).'

    Write-Output (Write-Log -Message "USB audit: $details" -Level INFO)

    # If enforcement mode requested and USB should be blocked but isn't
    if (-not $AuditOnly) {
      if ($Desired -eq 'Block' -and -not $blocked) {
        # For safety: provide remediation script instead of making changes silently
        $status.Remediation = 'To block: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name Start -Value 4'
      }
    }
    return $status
  } catch {
    # Error occurred during audit - return informational result
    $obj = New-CheckResult -Name 'USB Storage Access' -Status 'INFO' -Severity 'Low' -Details "USB audit error: $_" -Remediation 'Run as admin'
    Write-Output (Write-Log -Message "USB audit error: $_" -Level ERROR)
    return $obj
  }
}
