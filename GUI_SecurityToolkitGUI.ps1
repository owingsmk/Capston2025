Add-Type -AssemblyName System.Windows.Forms

function Start-SecurityToolkitGUI {
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Windows Security Toolkit'
  $form.Width = 900; $form.Height = 600

  $btnRun = New-Object System.Windows.Forms.Button
  $btnRun.Text = 'Run Checks'
  $btnRun.Top = 10; $btnRun.Left = 10; $btnRun.Width = 120

  $grid = New-Object System.Windows.Forms.DataGridView
  $grid.Top = 50; $grid.Left = 10; $grid.Width = 860; $grid.Height = 500
  $grid.AutoSizeColumnsMode = 'Fill'

  $btnRun.Add_Click({
    $results = @()
    $results += Check-FirewallStatus
    $results += Check-WindowsUpdates
    $results += Audit-UserAccounts
    $results += Enforce-PasswordPolicy -AuditOnly
    $results += Control-USBAccess -AuditOnly
    $results += Monitor-EventLogs   -AuditOnly
    $results += Harden-System       -AuditOnly

    $grid.DataSource = $results
    Write-Output (Write-Log -Message "GUI run completed." -Level INFO)
  })

  $form.Controls.Add($btnRun)
  $form.Controls.Add($grid)
  [void]$form.ShowDialog()
}
