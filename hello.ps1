# **1. Create a new directory**
$directoryPath = "C:\Temp\MyPowerShellScripts"
if (-not (Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath
    Write-Host "Directory created at $directoryPath"
} else {
    Write-Host "Directory already exists at $directoryPath"
}

# **2. Create and write to a text file**
$filePath = "$directoryPath\SampleFile.txt"
"Hello, this is a sample file created by PowerShell!" | Out-File -FilePath $filePath -Encoding UTF8
Write-Host "File created and written to: $filePath"

# **3. Retrieve system information**
$systemInfo = Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsArchitecture

# **4. Export system information to a CSV file**
$csvPath = "$directoryPath\SystemInfo.csv"
$systemInfo | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "System information exported to: $csvPath"

# **5. Display a success message**
Write-Host "All tasks completed successfully!"
