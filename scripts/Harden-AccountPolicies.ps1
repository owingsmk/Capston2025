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

function Harden-AccountPolicies {
  #Requires -RunAsAdministrator
  [CmdletBinding()] param([switch]$WhatIf = $true)
  # Provide guidance rather than silent changes; export secedit template when true
  # If false applies template
  $cfg = @{MinimumPasswordLength     = 12
    PasswordComplexityEnabled = $true
    MaxPasswordAgeDays        = 365
    AuditLogDaysBack          = 7
    FlagTelnetService         = $true
    AuditOnlyDefault          = $true}
  $template = @"
[System Access]
MinimumPasswordLength = $($cfg.MinimumPasswordLength)
PasswordComplexity = 1
MaximumPasswordAge = $($cfg.MaxPasswordAgeDays)
"@
  $out = Join-Path $env:TEMP 'toolkit-account-baseline.inf'
  $template | Set-Content -Path $out -Encoding ASCII
  if ($WhatIf) {
    Write-Output (Write-Log -Message "Prepared baseline template at $out (WhatIf mode)" -Level INFO)
  } else {
    secedit /configure /db secedit.sdb /cfg $out /quiet
    Write-Output (Write-Log -Message "Applied account policy baseline from $out" -Level INFO)
  }
}
Harden-AccountPolicies