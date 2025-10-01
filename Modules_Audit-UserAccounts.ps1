function Audit-UserAccounts {
  [CmdletBinding()] param()
  try {
    $admins = Get-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue
    $extra  = $admins | Where-Object { $_.Name -notmatch 'Administrator|Domain Admins|Enterprise Admins|Administrators' }

    if ($extra) {
      $list = ($extra.Name -join ', ')
      $rem  = 'Remove unnecessary local admin accounts; use least privilege and unique admin credentials.'
      $obj  = New-CheckResult -Name 'Local Admin Accounts' -Status 'WARN' -Severity 'Medium' -Details "Extra admins: $list" -Remediation $rem
      Write-Output (Write-Log -Message "Admins audit WARN: $list" -Level WARN)
      return $obj
    } else {
      $obj = New-CheckResult -Name 'Local Admin Accounts' -Status 'OK' -Severity 'Info' -Details 'No unexpected admins found' -Remediation ''
      Write-Output (Write-Log -Message "Admins audit OK" -Level INFO)
      return $obj
    }
  } catch {
    $obj = New-CheckResult -Name 'Local Admin Accounts' -Status 'INFO' -Severity 'Low' -Details "Audit error: $_" -Remediation 'Ensure PowerShell 5+ and LocalAccounts module available'
    Write-Output (Write-Log -Message "Admins audit error: $_" -Level ERROR)
    return $obj
  }
}
