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

function Harden-AutorunSmartScreen {
  #Requires -RunAsAdministrator
  [CmdletBinding()] param([switch]$WhatIf = $true)
  $items = @(
    @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name='NoDriveTypeAutoRun'; Value=255; Type='DWord'; Description='Disable AutoRun' }
  )
  foreach ($i in $items) {
    if ($WhatIf) {
      Write-Output (Write-Log -Message "Would $($i.Description)" -Level INFO)
    } else {
      if (-not (Test-Path $i.Path)) { New-Item -Path $i.Path -Force | Out-Null }
      New-ItemProperty -Path $i.Path -Name $i.Name -Value $i.Value -PropertyType $i.Type -Force | Out-Null
      Write-Output (Write-Log -Message "Applied: $($i.Description)" -Level INFO)
    }
  }
}
Harden-AutorunSmartScreen