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
function Disable-Services {
  #Requires -RunAsAdministrator
  [CmdletBinding()] param([switch]$WhatIf = $true)
  $targets = @("TlntSvr", "LanmanServer", "LanmanWorkstation")  # Telnet Server
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
    } else {Write-Output (Write-Log -Message "$svc service does not exist" -Level INFO)}
  }
}
Disable-Services -WhatIf:$false