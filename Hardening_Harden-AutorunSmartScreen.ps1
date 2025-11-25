<#
.SYNOPSIS
    Disables AutoRun functionality to prevent automatic execution of media content.

.DESCRIPTION
    Hardens system security by disabling Windows AutoRun feature which automatically
    executes programs from removable media (USB drives, CDs, DVDs). This prevents
    potential malware distribution via infected media.

.PARAMETERS
    -WhatIf [switch]
        When $true (default), shows what would be changed without applying.
        When $false, applies the registry changes to disable AutoRun.

.FUNCTIONALITY
    - Disables AutoRun for all drive types (fixed, removable, network, CD-ROM)
    - Modifies registry key: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer
    - Sets NoDriveTypeAutoRun registry value to 255 (disable all drive types)
    - Supports audit mode for testing before applying changes

.SECURITY IMPACT
    Prevents malicious programs on removable media from auto-executing when connected
    to the system, reducing infection vectors from compromised USB devices or media.

.NOTES
    Requires admin privileges. Sets registry value to 255 which disables AutoRun for:
    - Removable media (USB drives, floppy drives)
    - Fixed drives (internal hard drives)
    - Network drives
    - CD/DVD drives
#>

function Harden-AutorunSmartScreen {
  [CmdletBinding()] param([switch]$WhatIf = $true)
  
  # Define registry settings to disable AutoRun on all drive types
  $items = @(
    @{ 
      Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
      Name='NoDriveTypeAutoRun'
      Value=255  # 255 disables AutoRun for all drive types (binary: 11111111)
      Type='DWord'
      Description='Disable AutoRun for all drive types'
    }
  )
  
  # Process each registry configuration item
  foreach ($i in $items) {
    if ($WhatIf) {
      # Audit mode: Report what would be changed
      Write-Output (Write-Log -Message "Would set $($i.Description)" -Level INFO)
    } else {
      # Apply mode: Create registry path if needed and set the value
      if (-not (Test-Path $i.Path)) { New-Item -Path $i.Path -Force | Out-Null }
      New-ItemProperty -Path $i.Path -Name $i.Name -Value $i.Value -PropertyType $i.Type -Force | Out-Null
      Write-Output (Write-Log -Message "Applied: $($i.Description)" -Level INFO)
    }
  }
}
