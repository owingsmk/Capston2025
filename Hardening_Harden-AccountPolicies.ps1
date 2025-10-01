function Harden-AccountPolicies {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  # Provide guidance rather than silent changes; export secedit template
  $cfg = $Global:ToolkitSettings
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
