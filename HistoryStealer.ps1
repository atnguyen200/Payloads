# Safe copy of Chrome/Edge History DB to %TEMP%
# Run elevated only if required. Do NOT run on production machines without written authorization.

$now = Get-Date -Format "yyyy-MM-dd_HH-mm"
$tmp = $env:TEMP

# Define source paths (use LOCALAPPDATA for user-local apps)
$chromeHistory = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\History"
$edgeHistory   = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\History"

function Copy-HistoryIfPresent {
    param(
        [string]$SourcePath,
        [string]$Prefix
    )

    if (-not (Test-Path -Path $SourcePath -PathType Leaf)) {
        Write-Host "$Prefix history not found: $SourcePath"
        return
    }

    $destName = "$($env:USERNAME)-$now-$Prefix-history"
    $destPath = Join-Path $tmp $destName

    try {
        # Attempt to copy. If browser has file locked, this may fail.
        Copy-Item -Path $SourcePath -Destination $destPath -Force -ErrorAction Stop
        Write-Host "Copied $Prefix history to: $destPath"
    } catch {
        Write-Warning "Failed to copy $Prefix History (file may be in use by browser). Error: $($_.Exception.Message)"
        # Optional: we can attempt to make a shadow copy or advise to close the browser.
    }
}

Copy-HistoryIfPresent -SourcePath $chromeHistory -Prefix "chrome"
Copy-HistoryIfPresent -SourcePath $edgeHistory   -Prefix "edge"

# Optional visual confirmation (simple)
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("History copy attempt completed. Check $tmp for results.","OMGCABLE DEMO", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
