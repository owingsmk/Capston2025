<#
.SYNOPSIS
    Hardens Windows account policies to enforce strong password requirements and security standards.

.DESCRIPTION
    Configures critical account policies including minimum password length, password complexity
    requirements, and maximum password age. Supports audit mode (WhatIf) for testing before
    applying changes to the system.

.PARAMETERS
    -WhatIf [switch]
        When $true (default), shows what would be changed without actually applying policies.
        When $false, applies the security policies to the system.

.FUNCTIONALITY
    - Sets minimum password length
    - Enforces password complexity requirements
    - Sets maximum password age
    - Uses secedit to apply security template
    - Operates in audit mode by default for safety

.NOTES
    Requires admin privileges to apply policies. Configuration values come from $Global:ToolkitSettings.
#>

function Harden-AccountPolicies {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  
  # Load toolkit configuration settings
  $cfg = $Global:ToolkitSettings
  
  # Create Security Configuration Editor (secedit) template with hardened account policies
  # MinimumPasswordLength: Requires minimum password length (e.g., 12 characters)
  # PasswordComplexity: Enforces uppercase, lowercase, digits, and special characters
  # MaximumPasswordAge: Forces password changes within specified days (e.g., 90 days)
  $template = @"
[System Access]
MinimumPasswordLength = $($cfg.MinimumPasswordLength)
PasswordComplexity = 1
MaximumPasswordAge = $($cfg.MaxPasswordAgeDays)
"@
  
  # Write template to temporary file for secedit to process
  $out = Join-Path $env:TEMP 'toolkit-account-baseline.inf'
  $template | Set-Content -Path $out -Encoding ASCII
  
  if ($WhatIf) {
    # Audit mode: Report what would be changed without applying
    Write-Output (Write-Log -Message "Prepared baseline template at $out (WhatIf mode)" -Level INFO)
  } else {
    # Apply mode: Use secedit to configure the security policy database
    secedit /configure /db secedit.sdb /cfg $out /quiet
    Write-Output (Write-Log -Message "Applied account policy baseline from $out" -Level INFO)
  }
}
