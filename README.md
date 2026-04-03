Supports GUI or CLI.
To install the GUI, please download the Toolkit Installer.exe file.

Scripts run from the Script Center in the GUI must be run with administrator account as they make system changes.
Reports run from the Reports Center in the GUI do not need to be run with an administrator account and do not make any system changes.

Script Explanations: 
Audit & Disable Services – Checks if Telnet Service, Trivial File Transfer Protocol, and  Remote Registry are running on your system and disables them if they are.
Harden Accounts – Sets minimum password length of 12, enables password complexity, and sets a maximum password age of 365 days for users.
Disable Autorun - Disables AutoRun on your system.
Harden Firewall - Enables all Windows firewall profiles & Windows Defender real-time protection.
Harden Registry – Enables USB Write Protection on your system.

Report Explanations:
Audit Users – Identifies all administrator accounts on your system and suggests remediation steps depending on the account.
Check Firewall – Identifies all Windows Firewall profiles and detects if any are disabled.
Check Updates – Checks if automatic updates are enabled, identifies when the last successful update was installed.
Check USB Access – Identifies whether or not USB access is allowed or blocked.
CVE Scanner – Checks all installed applications against the National Vulnerability Database and returns any identified apps with CVEs (Common Vulnerabilities and Exposures).
Password Policy – Checks to see if all account passwords meet these standards and warns you if they do not. Standards: Minimum Password Length: 12, Password Complexity: Enabled, and Maximum Password Age: ≤ 365 days.
Harden System – Checks to see if SMBv1 enabled , RDP enabled, and if Telnet service is running on your system, if they are it suggests remediation. 
Monitor Event Logs – Returns security related events from the last seven days and determines their severity.


The Windows Security Toolkit is a University of Cincinnati student capstone project.
