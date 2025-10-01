# Central knobs for thresholds / behavior
$Global:ToolkitSettings = @{
  MinimumPasswordLength     = 12
  PasswordComplexityEnabled = $true
  MaxPasswordAgeDays        = 365
  AuditLogDaysBack          = 7
  FlagTelnetService         = $true
  AuditOnlyDefault          = $true
}
