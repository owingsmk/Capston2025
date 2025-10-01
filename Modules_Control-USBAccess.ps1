function Control-USBAccess {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly,
    [ValidateSet('Allow','Block')]
    [string]$Desired = 'Allow'
  )

  try {
    # Audit via storage driver start type (USBSTOR)
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR'
    $start = if (Test-Path $key) { (Get-ItemProperty -Path $key -Name Start -ErrorAction SilentlyContinue).Start } else { $null }

    $blocked = ($start -eq 4) # 4 = Disabled
    $details = if ($blocked) { 'USB storage currently blocked' } else { 'USB storage allowed' }
    $status  = New-CheckResult -Name 'USB Storage Access' -Status 'INFO' -Severity 'Low' -Details $details -Remediation 'Set HKLM:\...\USBSTOR\Start=4 to block (policy controlled).'

    Write-Output (Write-Log -Message "USB audit: $details" -Level INFO)

    if (-not $AuditOnly) {
      if ($Desired -eq 'Block' -and -not $blocked) {
        # For safety: *show* what to change instead of changing silently.
        $status.Remediation = 'To block: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name Start -Value 4'
      }
    }
    return $status
  } catch {
    $obj = New-CheckResult -Name 'USB Storage Access' -Status 'INFO' -Severity 'Low' -Details "USB audit error: $_" -Remediation 'Run as admin'
    Write-Output (Write-Log -Message "USB audit error: $_" -Level ERROR)
    return $obj
  }
}
