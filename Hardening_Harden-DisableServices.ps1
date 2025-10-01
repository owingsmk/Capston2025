function Harden-DisableServices {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  $targets = @('TlntSvr')  # Telnet Server
  foreach ($svc in $targets) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
      if ($WhatIf) {
        Write-Output (Write-Log -Message "Would disable service: $svc" -Level INFO)
      } else {
        Set-Service -Name $svc -StartupType Disabled
        Stop-Service -Name $svc -ErrorAction SilentlyContinue
        Write-Output (Write-Log -Message "Disabled service: $svc" -Level INFO)
      }
    }
  }
}
