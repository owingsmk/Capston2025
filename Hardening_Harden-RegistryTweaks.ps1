<#
.SYNOPSIS
    Applies hardening registry tweaks to improve system security.

.DESCRIPTION
    Modifies Windows registry settings to enforce security policies. Currently implements
    USB write protection to prevent unauthorized data writes to removable media and
    protect against malware propagation via USB devices.

.PARAMETERS
    -WhatIf [switch]
        When $true (default), shows what would be changed without applying.
        When $false, applies the registry modifications to harden the system.

.FUNCTIONALITY
    - Enables USB write protection via registry configuration
    - Creates necessary registry paths if they don't exist
    - Applies DWord registry values for system-level security
    - Supports audit mode for testing before applying changes

.REGISTRY MODIFICATIONS
    Path: HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies
    Name: WriteProtect
    Value: 1 (enabled - makes USB devices read-only)
    Type: DWord

.SECURITY IMPACT
    USB Write Protection:
    - Prevents unauthorized data writes to USB drives and removable media
    - Protects against malware infection via USB propagation
    - Allows reading from USB but blocks write operations
    - Useful in highly restricted environments (government, healthcare, finance)

.NOTES
    Requires admin privileges. May impact workflow if users need to write to USB devices.
    Can be expanded to include additional registry security tweaks by adding items to $items array.
    Some restrictions may be bypassed on systems with physical access.
#>

function Harden-RegistryTweaks {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  
  # Define registry settings to apply for security hardening
  $items = @(
    @{ 
      Path='HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies'
      Name='WriteProtect'
      Value=1  # 1 = enabled (write-protect); 0 = disabled (allow writes)
      Type='DWord'
      Description='USB write protect'
    }
  )
  
  # Process each registry configuration item
  foreach ($i in $items) {
    if ($WhatIf) {
      # Audit mode: Report what would be changed
      Write-Output (Write-Log -Message "Would set $($i.Path)\$($i.Name)=$($i.Value)" -Level INFO)
    } else {
      # Apply mode: Create registry path if needed and set the value
      if (-not (Test-Path $i.Path)) { New-Item -Path $i.Path -Force | Out-Null }
      New-ItemProperty -Path $i.Path -Name $i.Name -Value $i.Value -PropertyType $i.Type -Force | Out-Null
      Write-Output (Write-Log -Message "Set $($i.Path)\$($i.Name)=$($i.Value)" -Level INFO)
    }
  }
}
