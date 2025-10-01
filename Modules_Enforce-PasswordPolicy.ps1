function Enforce-PasswordPolicy {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  $cfg = $Global:ToolkitSettings
  try {
    # Read local policy via secedit export
    $tmp = Join-Path $env:TEMP 'secpol.inf'
    secedit /export /cfg $tmp | Out-Null
    $content = Get-Content $tmp

    $currentMinLen = ($content | Where-Object { $_ -match '^MinimumPasswordLength\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1
    $complexity    = ($content | Where-Object { $_ -match '^PasswordComplexity\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1
    $maxAge        = ($content | Where-Object { $_ -match '^MaximumPasswordAge\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1

    $issues = @()
    if ($currentMinLen -lt $cfg.MinimumPasswordLength) { $issues += "MinLength=$currentMinLen (< $($cfg.MinimumPasswordLength))" }
    if ($cfg.PasswordComplexityEnabled -and $complexity -ne 1) { $issues += "Complexity disabled" }
    if ($maxAge -gt $cfg.MaxPasswordAgeDays) { $issues += "MaxAge=$maxAge (> $($cfg.MaxPasswordAgeDays))" }

    if ($issues.Count -gt 0) {
      $rem = "Set MinimumPasswordLength=$($cfg.MinimumPasswordLength); enable Complexity; set MaximumPasswordAge<=$($cfg.MaxPasswordAgeDays). Use Local Security Policy or 'secedit' to apply."
      $status = New-CheckResult -Name 'Password Policy' -Status 'FAIL' -Severity 'High' -Details ($issues -join '; ') -Remediation $rem
      Write-Output (Write-Log -Message "Password policy FAIL: $($issues -join '; ')" -Level WARN)

      if (-not $AuditOnly) {
        Write-Output (Write-Log -Message "Enforcement requested; exporting guidance only (no silent changes)." -Level INFO)
        # For capstone safety, provide guidance rather than direct change.
      }
      return $status
    } else {
      $ok = New-CheckResult -Name 'Password Policy' -Status 'OK' -Severity 'Info' -Details 'Meets baseline' -Remediation ''
      Write-Output (Write-Log -Message "Password policy OK" -Level INFO)
      return $ok
    }
  } catch {
    $obj = New-CheckResult -Name 'Password Policy' -Status 'INFO' -Severity 'Low' -Details "Policy check error: $_" -Remediation 'Run as admin; secedit available'
    Write-Output (Write-Log -Message "Password policy error: $_" -Level ERROR)
    return $obj
  }
}
