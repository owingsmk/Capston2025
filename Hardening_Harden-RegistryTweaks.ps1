function Harden-RegistryTweaks {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  $items = @(
    @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies'; Name='WriteProtect'; Value=1; Type='DWord'; Description='USB write protect' }
  )
  foreach ($i in $items) {
    if ($WhatIf) {
      Write-Output (Write-Log -Message "Would set $($i.Path)\$($i.Name)=$($i.Value)" -Level INFO)
    } else {
      if (-not (Test-Path $i.Path)) { New-Item -Path $i.Path -Force | Out-Null }
      New-ItemProperty -Path $i.Path -Name $i.Name -Value $i.Value -PropertyType $i.Type -Force | Out-Null
      Write-Output (Write-Log -Message "Set $($i.Path)\$($i.Name)=$($i.Value)" -Level INFO)
    }
  }
}
