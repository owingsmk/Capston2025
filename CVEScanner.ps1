function Get-InstalledApplications {
    $apps = @()
    $apps += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue
    $apps += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue
    return $apps | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion -Unique
}
 
function Search-CVEForProduct {
    param(
        [string]$ProductName,
        [string]$Version,
        [string]$ApiKey = ""
    )
    if ($ApiKey) {
        Start-Sleep -Milliseconds 600
    } else {
        Start-Sleep -Milliseconds 6000
    }
    try {
        $searchTerm = "$ProductName $Version" -replace '[^\w\s\.-]', ' '
        $uri = "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$([System.Uri]::EscapeDataString($searchTerm))"
        $headers = @{}
        if ($ApiKey) {
            $headers["apiKey"] = $ApiKey
        }
        if ($headers.Count -gt 0) {
            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop
        }
        if ($response.PSObject.Properties.Name -contains "totalResults" -and $response.totalResults -gt 0) {
            return @{
                Found = $true
                Count = $response.totalResults
                CVEs = $response.vulnerabilities | ForEach-Object {
                    @{
                        ID = $_.cve.id
                        Description = $_.cve.descriptions[0].value.Substring(0, [Math]::Min(200, $_.cve.descriptions[0].value.Length))
                        Published = $_.cve.published
                        Severity = if ($_.cve.metrics.cvssMetricV31) {
                            $_.cve.metrics.cvssMetricV31[0].cvssData.baseSeverity
                        } elseif ($_.cve.metrics.cvssMetricV2) {
                            $_.cve.metrics.cvssMetricV2[0].baseSeverity
                        } else {
                            "N/A"
                        }
                    }
                } | Select-Object -First 5
            }
        } else {
            return @{
                Found = $false
                Count = 0
            }
        }
    }
    catch {
        Write-Warning "Error querying CVE for $ProductName : $_"
        return @{
            Found = $false
            Count = 0
            Error = $_.Exception.Message
        }
    }
}
 
function Check-InstalledApplicationsForCVEs {
    param(
        [string]$ApiKey = "2AE63CED-23AD-F011-8363-0EBF96DE670D",
        [int]$MaxAppsToCheck = 50
    )
    Write-Host "Retrieving installed applications..." -ForegroundColor Cyan
    $apps = Get-InstalledApplications
    Write-Host "Found $($apps.Count) installed applications" -ForegroundColor Green
    Write-Host "Checking first $MaxAppsToCheck applications for CVEs..." -ForegroundColor Yellow
    Write-Host ""
    $results = @()
    $checkedCount = 0
    foreach ($app in ($apps | Select-Object -First $MaxAppsToCheck)) {
        $checkedCount++
        Write-Host "[$checkedCount/$MaxAppsToCheck] Checking: $($app.DisplayName) $($app.DisplayVersion)" -ForegroundColor Gray
        $cveResult = Search-CVEForProduct -ProductName $app.DisplayName -Version $app.DisplayVersion -ApiKey $ApiKey
        if ($cveResult.Found) {
            Write-Host "  Found $($cveResult.Count) CVE(s)!" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Application = $app.DisplayName
                Version = $app.DisplayVersion
                CVECount = $cveResult.Count
                CVEs = $cveResult.CVEs
            }
        } else {
            Write-Host "  No CVEs found" -ForegroundColor Green
        }
    }
    Write-Host ""
    Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
    Write-Host "Applications checked: $checkedCount" -ForegroundColor White
    Write-Host "Applications with CVEs: $($results.Count)" -ForegroundColor White
    return $results
}
 
$vulnerableApps = Check-InstalledApplicationsForCVEs -$MaxAppsToCheck
 