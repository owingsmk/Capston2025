function Write-Log {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$Message,
    [ValidateSet('INFO','WARN','ERROR','DEBUG')]
    [string]$Level = 'INFO'
  )
  $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $line = "$timestamp [$Level] $Message"
  # Persist to file (uses $Script:LogPath from StartToolkit)
  try { Add-Content -Path $Script:LogPath -Value $line } catch {}
  # Return the line so caller can Write-Output it
  return $line
}

function New-CheckResult {
  param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Status,     # "OK","WARN","FAIL","INFO"
    [ValidateSet('Low','Medium','High','Info')]
    [string]$Severity = 'Info',
    [string]$Details  = '',
    [string]$Remediation = ''
  )
  [PSCustomObject]@{
    Name        = $Name
    Status      = $Status
    Severity    = $Severity
    Details     = $Details
    Remediation = $Remediation
  }
}
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
Audit-UserAccounts