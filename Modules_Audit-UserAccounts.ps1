<#
.SYNOPSIS
    Audits local user accounts and administrator group membership for security risks.

.DESCRIPTION
    Analyzes the Administrators group to identify unexpected or excessive privileged accounts.
    Checks for accounts beyond the standard built-in administrators and domain admin groups.
    Helps enforce the principle of least privilege by identifying unnecessary admin accounts.

.FUNCTIONALITY
    - Retrieves all members of the local Administrators group
    - Filters out standard system accounts (Administrator, Domain Admins, Enterprise Admins)
    - Detects unexpected privileged accounts
    - Returns audit results with remediation recommendations
    - Handles errors gracefully with detailed reporting

.OUTPUT
    Returns a CheckResult object containing:
    - Name: 'Local Admin Accounts'
    - Status: 'OK', 'WARN', or 'INFO' (depends on findings and errors)
    - Details: List of unexpected admins or error description
    - Remediation: Recommended actions to address issues
    - Severity: Info, Medium, or Low

.SECURITY IMPLICATIONS
    OK Status:
    - Only standard system admin accounts present
    - Good practice of least privilege maintained

    WARN Status:
    - Extra administrator accounts detected
    - Potential security risk if not properly documented
    - Should review and remove unnecessary elevated accounts

.NOTES
    Requires: PowerShell 5+, Get-LocalGroupMember cmdlet
    Standard excluded accounts: Administrator, Domain Admins, Enterprise Admins, Administrators
    Use in conjunction with other audit functions for comprehensive security assessment.
#>

function Audit-UserAccounts {
  [CmdletBinding()] param()
  try {
    # Retrieve all members of the local Administrators group
    $admins = Get-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue
    
    # Filter out standard system accounts - keep only unexpected admins
    $extra  = $admins | Where-Object { $_.Name -notmatch 'Administrator|Domain Admins|Enterprise Admins|Administrators' }

    if ($extra) {
      # Unexpected administrator accounts found - flag as warning
      $list  = ($extra.Name -join ', ')
      $rem   = 'Remove unnecessary local admin accounts; use least privilege and unique admin credentials.'
      $obj   = New-CheckResult -Name 'Local Admin Accounts' -Status 'WARN' -Severity 'Medium' -Details "Extra admins: $list" -Remediation $rem
      Write-Output (Write-Log -Message "Admins audit WARN: $list" -Level WARN)
      return $obj
    } else {
      # Only standard admin accounts present - pass the audit
      $obj = New-CheckResult -Name 'Local Admin Accounts' -Status 'OK' -Severity 'Info' -Details 'No unexpected admins found' -Remediation ''
      Write-Output (Write-Log -Message "Admins audit OK" -Level INFO)
      return $obj
    }
  } catch {
    # Error occurred during audit - return informational result with error details
    $obj = New-CheckResult -Name 'Local Admin Accounts' -Status 'INFO' -Severity 'Low' -Details "Audit error: $_" -Remediation 'Ensure PowerShell 5+ and LocalAccounts module available'
    Write-Output (Write-Log -Message "Admins audit error: $_" -Level ERROR)
    return $obj
  }
}
