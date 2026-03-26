function Write-Log {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Message,
    [ValidateSet('INFO','WARN','ERROR','DEBUG')]
    [string]$Level = 'INFO'
  )
  $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $line = "$timestamp [$Level] $Message"
  # Persist to file (uses $Script:LogPath from StartToolkit)
  try { Add-Content -Path $Script:LogPath -Value $line } catch {}
  # Return the line so caller can Write-Output it
  return $line
}

function Harden-RegistryTweaks {
  #Requires -RunAsAdministrator
  #Enables USB Write Protection when set to false
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
Harden-RegistryTweaks