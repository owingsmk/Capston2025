<#
.SYNOPSIS
    Global configuration settings for the Windows Security Toolkit.

.DESCRIPTION
    Defines baseline security thresholds and audit parameters used across all
    toolkit modules. These settings establish organizational security standards
    for password policies, audit logging, and service monitoring.

.CONFIGURATION PARAMETERS

    MinimumPasswordLength (integer)
    - Minimum required password length for all accounts
    - Default: 12 characters
    - Used by: Harden-AccountPolicies, Enforce-PasswordPolicy
    - Security best practice: 12+ characters recommended for strong passwords
    - Baseline: NIST recommends minimum 8, industry standard 12-16

    PasswordComplexityEnabled (boolean)
    - Requires passwords to include multiple character types
    - Default: $true (enabled)
    - Character types: uppercase, lowercase, digits, special characters
    - Used by: Harden-AccountPolicies, Enforce-PasswordPolicy
    - Impact: Prevents weak/dictionary passwords

    MaxPasswordAgeDays (integer)
    - Maximum days before password must be changed
    - Default: 365 days (1 year)
    - Used by: Harden-AccountPolicies, Enforce-PasswordPolicy
    - Security implication: Forces periodic password rotation
    - Limits exposure window if password is compromised
    - Note: NIST now recommends 90 days or no expiration with monitoring

    AuditLogDaysBack (integer)
    - Lookback period for security event log analysis
    - Default: 7 days
    - Used by: Monitor-EventLogs
    - Affects: Failed login detection, privilege change detection
    - Longer period = more comprehensive but slower analysis

    FlagTelnetService (boolean)
    - Flag if Telnet service is running (plaintext remote access)
    - Default: $true (enabled)
    - Used by: Harden-System audit
    - Telnet should never be enabled (use SSH instead)

    AuditOnlyDefault (boolean)
    - Default behavior for modules supporting enforcement
    - Default: $true (audit mode by default)
    - Used by: Enforcement modules (Harden-*, Control-*)
    - Safety feature: Modules report issues but don't modify system by default
    - Explicit enforcement required by administrator

.USAGE
    All toolkit modules access settings via: $Global:ToolkitSettings.SettingName
    Example: $cfg.MinimumPasswordLength returns 12

.SECURITY CONSIDERATIONS
    - These are baseline values; adjust based on organizational policy
    - Stricter settings recommended for high-security environments
    - Review and update settings during security audits
    - Document any deviations from baseline with business justification

.NOTES
    Loaded at toolkit startup via Config_settings.ps1
    Global scope allows access from all modules
    Centralized configuration enables easy policy updates
#>

# Central knobs for thresholds and behavior
$Global:ToolkitSettings = @{
  # Password Policy Settings
  MinimumPasswordLength     = 12      # Minimum 12 characters for strong passwords
  PasswordComplexityEnabled = $true   # Require mixed case, digits, special characters
  MaxPasswordAgeDays        = 365     # Force password change every 365 days (1 year)
  
  # Audit Settings
  AuditLogDaysBack          = 7       # Look back 7 days for security event analysis
  
  # Service Monitoring
  FlagTelnetService         = $true   # Flag if insecure Telnet service is running
  
  # Enforcement Behavior
  AuditOnlyDefault          = $true   # Default to audit mode (no silent system changes)
}
