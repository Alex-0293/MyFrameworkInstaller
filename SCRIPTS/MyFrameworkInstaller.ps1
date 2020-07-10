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

$MyProjectFolderPath = "D:\DATA\DOCUMENTS\MyProjects"

if (-not (Test-Path $MyProjectFolderPath) ) {
    New-Item -Path $MyProjectFolderPath  -ItemType Directory -Force
}

$ProjectsFolderPath        = "$MyProjectFolderPath\PROJECTS"
if (-not (Test-Path $ProjectsFolderPath) ) {
    New-Item -Path $ProjectsFolderPath  -ItemType Directory -Force
}

$ProjectServicesFolderPath = "$MyProjectFolderPath\ProjectServices"
if (-not (Test-Path $ProjectServicesFolderPath) ) {
    New-Item -Path $ProjectServicesFolderPath  -ItemType Directory -Force
}

$OtherProjectsFolderPath   = "$MyProjectFolderPath\OtherProjects"
if (-not (Test-Path $OtherProjectsFolderPath) ) {
    New-Item -Path $OtherProjectsFolderPath  -ItemType Directory -Force
}

$GlobalSettingsURL = "https://github.com/Alex-0293/GlobalSettings"
Set-Location $ProjectsFolderPath
$ git.exe clone $GlobalSettingsURL

$GlobalSettingsEmptyFile = Get-Content -Path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1"
$ToReplace               = '[string] $Global:MyProjectFolderPath = ""'
$ReplaceBy               = '[string] $Global:MyProjectFolderPath = ' + $MyProjectFolderPath
$GlobalSettingsEmptyFile = $GlobalSettingsEmptyFile.Replace($ToReplace, $ReplaceBy)
$GlobalSettingsEmptyFile | Out-File -FilePath "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1" -Force

$GlobalSettingsScriptPath = "$ProjectsFolderPath\GlobalSettings\SCRIPTS"

$Res = Import-Module -Name Sudo -PassThru -Force
if (-not $Res) {
    Set-ExecutionPolicy RemoteSigned -Scope Process
    $SudoInstall = Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1"
    Invoke-Expression $SudoInstall
    $Res = Import-Module -Name Sudo -PassThru -Force 
}

if ($Res) { 
    gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkInitScript' , \""$GlobalSettingsScriptPath\Init.ps1\"", [EnvironmentVariableTarget]::Machine )"    
    gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkGlobalInitScript' , \""$GlobalSettingsScriptPath\InitGlobal.ps1\"", [EnvironmentVariableTarget]::Machine )"  
}

################################# Script end here ###################################

