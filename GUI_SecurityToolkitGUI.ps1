<#
.SYNOPSIS
    Windows Security Toolkit GUI - A graphical interface for security checks and audits.

.DESCRIPTION
    Creates a Windows Forms-based GUI that allows users to run multiple security checks
    and audits on the system. Displays results in a data grid for easy review.

.FUNCTIONALITY
    - Firewall status verification
    - Windows updates check
    - User account audit
    - Password policy enforcement verification
    - USB access control status
    - Event logs monitoring
    - System hardening audit

.NOTES
    Requires System.Windows.Forms assembly for GUI components.
#>

Add-Type -AssemblyName System.Windows.Forms

function Start-SecurityToolkitGUI {
  # Create main GUI form window with specified dimensions
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Windows Security Toolkit'
  $form.Width = 900; $form.Height = 600

  # Create "Run Checks" button positioned at top-left of form
  $btnRun = New-Object System.Windows.Forms.Button
  $btnRun.Text = 'Run Checks'
  $btnRun.Top = 10; $btnRun.Left = 10; $btnRun.Width = 120

  # Create data grid view to display results of security checks
  $grid = New-Object System.Windows.Forms.DataGridView
  $grid.Top = 50; $grid.Left = 10; $grid.Width = 860; $grid.Height = 500
  $grid.AutoSizeColumnsMode = 'Fill'

  # Add click event handler to button - executes all security checks when clicked
  $btnRun.Add_Click({
    $results = @()
    # Run all security audit functions and collect results
    $results += Check-FirewallStatus
    $results += Check-WindowsUpdates
    $results += Audit-UserAccounts
    $results += Enforce-PasswordPolicy -AuditOnly
    $results += Control-USBAccess -AuditOnly
    $results += Monitor-EventLogs   -AuditOnly
    $results += Harden-System       -AuditOnly

    # Display results in the grid and log completion
    $grid.DataSource = $results
    Write-Output (Write-Log -Message "GUI run completed." -Level INFO)
  })

  # Add button and grid controls to the form
  $form.Controls.Add($btnRun)
  $form.Controls.Add($grid)
  
  # Display the form as a modal dialog
  [void]$form.ShowDialog()
}
