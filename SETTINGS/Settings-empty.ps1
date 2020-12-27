# Rename this file to Settings.ps1
######################### value replacement #####################

######################### no replacement ########################

[uri] $Global:GlobalSettingsURL        = "https://github.com/Alex-0293/GlobalSettings"
[uri] $Global:GitHubRepositoryCloneURL = "https://github.com/Alex-0293/GitHubRepositoryClone"
[uri] $Global:AlexKUtilsModuleURL      = "https://github.com/Alex-0293/AlexKUtils"
[uri] $Global:AlexKBuildToolsModuleURL = "https://github.com/Alex-0293/AlexKBuildTools"

#WMF5.1
[uri]    $Global:WMF5_2012R2_64 = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=54616&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1"
[string] $Global:WMF5FileName   = "$($Env:TEMP)\WMF5.msu"

#VSCode
[uri] $global:VSCode64URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
[uri] $global:VSCode32URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32-user"
[string] $Global:VSCodeFileName = "$($Env:TEMP)\VSCodeInstall.exe"

#Powershell7
[uri] $global:Powershell764URI       = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x64.msi"
[uri] $global:Powershell732URI       = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x86.msi"
[string] $Global:Powershell7FileName = "$($Env:TEMP)\Powershell7Install.exe"

[bool]  $Global:LocalSettingsSuccessfullyLoaded  = $true

#VSCode config

[string] $Global:VSCodeConfig = @"
{
    "files.encoding": "utf8bom"
    "workbench.iconTheme": "material-icon-theme",
    "powershell.integratedConsole.forceClearScrollbackBuffer": true
    "editor.minimap.enabled": false
}
"@

[string] $Global:VSCodeConfigFilePath = "$($env:APPDATA)\Code\User\settings.json"

[uri] $Global:MyFrameworkInstaller = "https://github.com/Alex-0293/MyFrameworkInstaller.git"


# Error trap
    trap {
        $Global:LocalSettingsSuccessfullyLoaded = $False
        exit 1
    }
