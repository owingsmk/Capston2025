<#
.SYNOPSIS
    Audits password policy compliance against organizational security baselines.

.DESCRIPTION
    Verifies that local password policies meet minimum security standards for password
    length, complexity requirements, and password age limits. Uses secedit to export
    current policies for analysis. Supports audit-only mode for safe assessment.

.PARAMETERS
    -AuditOnly [switch]
        When $true (default), performs audit without making changes.
        When $false, provides remediation guidance only (no automatic changes for safety).

.FUNCTIONALITY
    - Exports current password policy using secedit
    - Parses policy file to extract key settings
    - Compares against $Global:ToolkitSettings baseline requirements
    - Identifies policy gaps and provides remediation steps
    - Returns detailed audit results
    - Supports audit-only mode

.POLICY SETTINGS CHECKED
    MinimumPasswordLength:
    - Minimum characters required for all passwords
    - Baseline typically: 12+ characters
    - Longer passwords = stronger against brute force

    PasswordComplexity:
    - Requires: uppercase, lowercase, digits, special characters
    - Baseline: Must be enabled (value = 1)
    - Prevents weak/dictionary passwords

    MaximumPasswordAge:
    - Forces password changes within X days
    - Baseline typically: 90 days or less
    - Limits exposure if password is compromised

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'Password Policy'
    - Status: 'OK', 'FAIL', or 'INFO' (depends on findings and errors)
    - Details: List of policy gaps or error description
    - Remediation: Step-by-step instructions to fix issues
    - Severity: High (for failures), Info (for passes), or Low (for errors)

.SECURITY IMPLICATIONS
    OK Status:
    - All policies meet organizational baseline
    - Strong password requirements enforced
    - Reduces risk of credential compromise

    FAIL Status:
    - One or more policies below baseline
    - Weak password requirements allowed
    - Increased risk of account compromise
    - Requires immediate remediation

.NOTES
    Requires: Admin privileges, secedit command available
    Configuration source: $Global:ToolkitSettings
    Safety feature: Provides remediation guidance only; does not silently modify policies
    Use in conjunction with Group Policy for enterprise policy management.
#>

function Enforce-PasswordPolicy {
  [CmdletBinding()]
  param(
    [switch]$AuditOnly
  )
  
  # Load toolkit configuration baseline
  $cfg = $Global:ToolkitSettings
  try {
    # Export current password policy using secedit tool
    $tmp = Join-Path $env:TEMP 'secpol.inf'
    secedit /export /cfg $tmp | Out-Null
    $content = Get-Content $tmp

    # Parse policy file to extract minimum password length
    $currentMinLen = ($content | Where-Object { $_ -match '^MinimumPasswordLength\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1
    
    # Parse policy file to extract password complexity requirement (1 = enabled, 0 = disabled)
    $complexity    = ($content | Where-Object { $_ -match '^PasswordComplexity\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1
    
    # Parse policy file to extract maximum password age (in days)
    $maxAge        = ($content | Where-Object { $_ -match '^MaximumPasswordAge\s*=\s*(\d+)$' } | ForEach-Object { [int]($Matches[1]) }) | Select-Object -First 1

    # Identify policy gaps compared to baseline configuration
    $issues = @()
    if ($currentMinLen -lt $cfg.MinimumPasswordLength) { $issues += "MinLength=$currentMinLen (< $($cfg.MinimumPasswordLength))" }
    if ($cfg.PasswordComplexityEnabled -and $complexity -ne 1) { $issues += "Complexity disabled" }
    if ($maxAge -gt $cfg.MaxPasswordAgeDays) { $issues += "MaxAge=$maxAge (> $($cfg.MaxPasswordAgeDays))" }

    if ($issues.Count -gt 0) {
      # Policy gaps found - provide detailed remediation
      $rem = "Set MinimumPasswordLength=$($cfg.MinimumPasswordLength); enable Complexity; set MaximumPasswordAge<=$($cfg.MaxPasswordAgeDays). Use Local Security Policy or 'secedit' to apply."
      $status = New-CheckResult -Name 'Password Policy' -Status 'FAIL' -Severity 'High' -Details ($issues -join '; ') -Remediation $rem
      Write-Output (Write-Log -Message "Password policy FAIL: $($issues -join '; ')" -Level WARN)

      if (-not $AuditOnly) {
        # Enforcement requested - provide guidance only (no silent changes for safety)
        Write-Output (Write-Log -Message "Enforcement requested; exporting guidance only (no silent changes)." -Level INFO)
      }
      return $status
    } else {
      # All policies meet baseline - pass the audit
      $ok = New-CheckResult -Name 'Password Policy' -Status 'OK' -Severity 'Info' -Details 'Meets baseline' -Remediation ''
      Write-Output (Write-Log -Message "Password policy OK" -Level INFO)
      return $ok
    }
  } catch {
    # Error occurred during audit - return informational result
    $obj = New-CheckResult -Name 'Password Policy' -Status 'INFO' -Severity 'Low' -Details "Policy check error: $_" -Remediation 'Run as admin; secedit available'
    Write-Output (Write-Log -Message "Password policy error: $_" -Level ERROR)
    return $obj
  }
}
