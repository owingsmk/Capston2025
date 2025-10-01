Uses Write-Output only (no Write-Host).

Dot-sources modules, centralizes logging, and supports GUI or CLI.

Every check returns a simple object you can render in HTML later: Name, Status, Severity, Details, Remediation.


Notes / How to extend

Add more checks as separate Modules/*.ps1 files that return New-CheckResult objects so the GUI/CLI can aggregate consistently.

“Enforcement” paths are gated behind -AuditOnly:$false or -WhatIf:$false to keep things safe for demos.

For HTML output, pipe the results to a small renderer later; the uniform object makes that easy.
