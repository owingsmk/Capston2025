# Logging + helpers (no Write-Host)

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

function Test-IsAdmin {
  try {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  } catch {
    Write-Output (Write-Log -Message "Admin check failed: $_" -Level ERROR)
    return $false
  }
}
