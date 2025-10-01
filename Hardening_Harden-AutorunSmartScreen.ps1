function Harden-AutorunSmartScreen {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  $items = @(
    @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name='NoDriveTypeAutoRun'; Value=255; Type='DWord'; Description='Disable AutoRun' }
  )
  foreach ($i in $items) {
    if ($WhatIf) {
      Write-Output (Write-Log -Message "Would set $($i.Description)" -Level INFO)
    } else {
      if (-not (Test-Path $i.Path)) { New-Item -Path $i.Path -Force | Out-Null }
      New-ItemProperty -Path $i.Path -Name $i.Name -Value $i.Value -PropertyType $i.Type -Force | Out-Null
      Write-Output (Write-Log -Message "Applied: $($i.Description)" -Level INFO)
    }
  }
}
