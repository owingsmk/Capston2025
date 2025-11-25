<#
.SYNOPSIS
    Disables unnecessary and potentially dangerous Windows services.

.DESCRIPTION
    Hardens system security by disabling services that are not required for normal
    operation but pose security risks if exploited. Currently disables Telnet Server,
    which transmits credentials in plaintext and is rarely needed in modern environments.

.PARAMETERS
    -WhatIf [switch]
        When $true (default), shows what would be changed without applying.
        When $false, disables the targeted services and stops them immediately.

.FUNCTIONALITY
    - Identifies target services to disable (currently: Telnet Server)
    - Sets service startup type to Disabled
    - Stops the service if it's currently running
    - Supports audit mode for testing before applying changes

.SECURITY IMPACT
    Telnet Server (TlntSvr):
    - Transmits all traffic including passwords in plaintext
    - No encryption or secure authentication
    - Largely obsolete; replaced by SSH
    - Disabling eliminates this attack vector

.NOTES
    Requires admin privileges. Can be expanded to disable additional services
    by adding service names to the $targets array.
#>

function Harden-DisableServices {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  
  # Define list of services to disable (security risk services)
  $targets = @('TlntSvr')  # Telnet Server - transmits credentials in plaintext
  
  # Process each target service
  foreach ($svc in $targets) {
    # Check if service exists on the system
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
      if ($WhatIf) {
        # Audit mode: Report what would be changed
        Write-Output (Write-Log -Message "Would disable service: $svc" -Level INFO)
      } else {
        # Apply mode: Disable startup and stop the service
        Set-Service -Name $svc -StartupType Disabled
        Stop-Service -Name $svc -ErrorAction SilentlyContinue
        Write-Output (Write-Log -Message "Disabled service: $svc" -Level INFO)
      }
    }
  }
}
