# Rename this file to Settings.ps1
######################### value replacement #####################

######################### no replacement ########################

[uri] $Global:GlobalSettingsURL        = "https://github.com/Alex-0293/GlobalSettings"
[uri] $Global:GitHubRepositoryCloneURL = "https://github.com/Alex-0293/GitHubRepositoryClone"
[uri] $Global:AlexKUtilsModuleURL      = "https://github.com/Alex-0293/AlexKUtils"
[uri] $Global:AlexKBuildToolsModuleURL = "https://github.com/Alex-0293/AlexKBuildTools"

#WMF5.1
[uri]    $Global:WMF5_2012R2_64 = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"

#VSCode
[uri] $global:VSCode64URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
[uri] $global:VSCode32URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32-user"

#Powershell7
[uri] $global:Powershell764URI       = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x64.msi"
[uri] $global:Powershell732URI       = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x86.msi"

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
