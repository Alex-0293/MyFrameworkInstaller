<#
    .NOTE
        .AUTHOR AlexK (1928311@tuta.io)
        .DATE   10.07.2020
        .VER    1
        .LANG   En
        
    .LINK
        https://github.com/Alex-0293/MyFrameworkInstaller.git
    
    .COMPONENT
        

    .SYNOPSIS 

    .DESCRIPTION
        Install my framework and setup environment 

    .PARAMETER

    .EXAMPLE
        MyFrameworkInstaller.ps1

#>
################################# Script start here #################################

$SettingsPath = "$(split-path (split-path $PSCommandPath -Parent) -Parent)\SETTINGS\Settings.ps1"
. $SettingsPath

if (-not (Test-Path $Global:MyProjectFolderPath) ) {
    New-Item -Path $Global:MyProjectFolderPath  -ItemType Directory -Force
}

$ProjectsFolderPath        = "$($Global:MyProjectFolderPath)\Projects"
if (-not (Test-Path $ProjectsFolderPath) ) {
    New-Item -Path $ProjectsFolderPath  -ItemType Directory -Force
}

$ProjectServicesFolderPath = "$($Global:MyProjectFolderPath)\ProjectServices"
if (-not (Test-Path $ProjectServicesFolderPath) ) {
    New-Item -Path $ProjectServicesFolderPath  -ItemType Directory -Force
}

$OtherProjectsFolderPath   = "$($Global:MyProjectFolderPath)\OtherProjects"
if (-not (Test-Path $OtherProjectsFolderPath) ) {
    New-Item -Path $OtherProjectsFolderPath  -ItemType Directory -Force
}


if (-not (test-path "$ProjectsFolderPath\GlobalSettings")){    
    Set-Location $ProjectsFolderPath
    & git.exe clone $Global:GlobalSettingsURL
    $GlobalSettingsEmptyFile = Get-Content -Path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1"
    $ToReplace               = '[string] $Global:MyProjectFolderPath = ""'
    $ReplaceBy               = '[string] $Global:MyProjectFolderPath = "' + $Global:MyProjectFolderPath + '"'
    $GlobalSettingsEmptyFile = $GlobalSettingsEmptyFile.Replace($ToReplace, $ReplaceBy)
    $GlobalSettingsEmptyFile | Out-File -FilePath "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings.ps1" -Force
} 



$GlobalSettingsScriptPath = "$ProjectsFolderPath\GlobalSettings\SCRIPTS"

if (-not (get-command "gsudo")) {
    Set-ExecutionPolicy RemoteSigned -Scope Process
    $GSudoInstall = Invoke-WebRequest -UseBasicParsing $Global:GSudoInstallURL
    Invoke-Expression $GSudoInstall
}

gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkInitScript' , \""$GlobalSettingsScriptPath\Init.ps1\"", [EnvironmentVariableTarget]::Machine )"    
gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkGlobalInitScript' , \""$GlobalSettingsScriptPath\InitGlobal.ps1\"", [EnvironmentVariableTarget]::Machine )"  

if (-not (test-path "$ModulePath\AlexkUtils")){
    Set-Location -path $ModulePath
    gsudo git.exe clone $AlexKUtilsModuleURL 
}

if (-not (test-path "$ProjectServicesFolderPath\GitHubRepositoryClone")){    
    Set-Location $ProjectServicesFolderPath
    & git.exe clone $Global:GitHubRepositoryCloneURL
} 

& git.exe config --global user.name  $Global:GitUserName
& git.exe config --global user.email "1928311@tuta.io" 

write-host "Restart VSCode to refresh environments." -ForegroundColor Green

. "$ProjectServicesFolderPath\GitHubRepositoryClone\SCRIPTS\GitHubRepositoryClone.ps1"

################################# Script end here ###################################

