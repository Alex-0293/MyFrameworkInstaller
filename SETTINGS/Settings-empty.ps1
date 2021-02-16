# Rename this file to Settings.ps1
######################### value replacement #####################

######################### no replacement ########################

[uri] $Global:GlobalSettingsURL        = "https://github.com/Alex-0293/GlobalSettings"
[uri] $Global:GitHubRepositoryCloneURL = "https://github.com/Alex-0293/GitHubRepositoryClone"
[uri] $Global:AlexKUtilsModuleURL      = "https://github.com/Alex-0293/AlexKUtils"
[uri] $Global:AlexKBuildToolsModuleURL = "https://github.com/Alex-0293/AlexKBuildTools"

#VSCode
[uri] $global:VSCode64URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
[uri] $global:VSCode32URI       = "https://code.visualstudio.com/sha/download?build=stable&os=win32"

[bool]  $Global:LocalSettingsSuccessfullyLoaded  = $true

#VSCode config

[string] $Global:VSCodeConfig = @"
{
    "files.encoding": "utf8bom"
    "workbench.iconTheme": "material-icon-theme",
    "powershell.integratedConsole.forceClearScrollbackBuffer": true,
    "editor.minimap.enabled": false,
    "sync.gist": "77bf85c28cd3bd32ee4b00442c6dbdeb"
}
"@

[string] $Global:VSCodeConfigFilePath = "$($env:APPDATA)\Code\User\settings.json"

[uri] $Global:MyFrameworkInstaller = "https://github.com/Alex-0293/MyFrameworkInstaller.git"

[uri] $Global:GSudoInstallURL      = "https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1"

[string] $Global:PowershellModulePath  = "c:\program files\powershell\7\Modules"

# Error trap
    trap {
        $Global:LocalSettingsSuccessfullyLoaded = $False
        exit 1
    }
