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
param(
    [string] $root = "$($Env:USERPROFILE)\Documents\MyProjects"
)
################################# Script start here #################################

    $FunctionFilePath = "$($Env:temp)\Functions.ps1"
    . $FunctionFilePath

    #remove it
    #$OSBit = 64
    Stop-Transcript -ErrorAction SilentlyContinue

    #$root = "$($Env:USERPROFILE)\Documents\MyProjects"

    $TransPath = "$root\MyFrameworkInstaller-$(Get-date -format 'dd.MM.yy HH-mm-ss').log"
    Start-Transcript -Path $TransPath

    if (!$FileCashFolderPath ) {
        $FileCashFolderPath = "$root\install"
    }
    if ( test-path $FileCashFolderPath ){
        [psobject]$InstallConfig = Import-Clixml -path "$FileCashFolderPath\Config.xml"
        foreach ( $item in $InstallConfig.PSObject.Properties ){
            Set-Variable -Name $item.Name -Value $item.Value -Scope global
        }
        write-host "Use cache file ["$FileCashFolderPath\Config.xml"]." -ForegroundColor "Green"
    }
    

    $SettingsPath = "$MyProjectFolderPath\ProjectServices\MyFrameworkInstaller\SETTINGS\Settings.ps1"
    . $SettingsPath

    if (-not (get-command "gsudo" -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy RemoteSigned -Scope Process
        $GSudoInstall = Invoke-WebRequest -UseBasicParsing $Global:GSudoInstallURL
        Invoke-Expression $GSudoInstall
        Update-Environment
    }

    $CodeCommand = Get-Command "Code" -ErrorAction SilentlyContinue
    if ( !$CodeCommand ) {
        $Answer = Get-Answer -Title "Do you want to install VSCode? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
        if ( $Answer -eq "Y" ) {
            write-host "3. Install VSCode."
            $VSCodeURI = (Get-Variable -name "VSCode$($OSBit)URI").Value
            $Global:VSCodeFileName = "$FileCashFolderPath\VSCode.exe"
            If ( $VSCodeURI ) {
                if ( test-path -path $Global:VSCodeFileName ){
                    Remove-Item -Path $Global:VSCodeFileName
                }

                $res = Invoke-WebRequest -Uri $VSCodeURI -OutFile $Global:VSCodeFileName -PassThru
                $OldName = $Global:VSCodeFileName
                $FileName = $res.headers."Content-Disposition".split("`"")[1]
                $Global:VSCodeFileName = "$FileCashFolderPath\$FileName"
                rename-item -Path $OldName -NewName $Global:VSCodeFileName

                if ( test-path -path $Global:VSCodeFileName ){
                    Unblock-File -path $Global:VSCodeFileName
                    $res = Start-Program -Program $Global:VSCodeFileName -Arguments @('/silent', '/MERGETASKS=!runcode') -Description "    Installing VSCode."
                    Update-Environment
                    # if ( $res.ErrorOutput ){
                    #     write-host $res.ErrorOutput -ForegroundColor Red
                    # }
                }
                Else {
                    Write-Host "Error downloading file [$Global:VSCodeFileName]!" -ForegroundColor Red
                }
            }
        }
    }

    $Answer = Get-Answer -Title "Do you want to configure VSCode? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
    if ( $Answer -eq "Y" ) {
        if ( $CodeCommand ) {
            write-host "4. Config VSCode."

            $res = Start-Program -Program "code" -Arguments @('--install-extension', 'ms-vscode.powershell') -Description "    Installing VSCode powershell extention."
            # if ( $res.ErrorOutput ){
            #     write-host $res.ErrorOutput -ForegroundColor Red
            # }

            $res = Start-Program -Program "code" -Arguments @('--install-extension', 'pkief.material-icon-theme') -Description "    Installing VSCode icon pack extention."
            # if ( $res.ErrorOutput ){
            #     write-host $res.ErrorOutput -ForegroundColor Red
            # }

            write-host "   create VSCode user config"
            Set-Content -path $Global:VSCodeConfigFilePath -Value $Global:VSCodeConfig -Force

            write-host "   create MyProject folder"
            New-Item -Path $Global:MyProjectFolderPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

            write-host "   create MyProject\Projects folder"
            New-Item -Path "$($Global:MyProjectFolderPath)\Projects" -ItemType Directory  -ErrorAction SilentlyContinue | Out-Null

            $StartVSCode = $True
        }
        Else {
            Write-Host "Code not found!" -ForegroundColor red
        }
    }

    $ProjectsFolderPath        = "$($Global:MyProjectFolderPath)\Projects"
    if (-not (Test-Path $ProjectsFolderPath) ) {
        New-Item -Path $ProjectsFolderPath  -ItemType Directory -Force | Out-Null
    }

    $ProjectServicesFolderPath = "$($Global:MyProjectFolderPath)\ProjectServices"
    if (-not (Test-Path $ProjectServicesFolderPath) ) {
        New-Item -Path $ProjectServicesFolderPath  -ItemType Directory -Force | Out-Null
    }

    $OtherProjectsFolderPath   = "$($Global:MyProjectFolderPath)\OtherProjects"
    if (-not (Test-Path $OtherProjectsFolderPath) ) {
        New-Item -Path $OtherProjectsFolderPath  -ItemType Directory -Force | Out-Null
    }

    $DisabledProjectsFolderPath = "$($Global:MyProjectFolderPath)\DisabledProjects"
    if (-not (Test-Path $DisabledProjectsFolderPath) ) {
        New-Item -Path $DisabledProjectsFolderPath  -ItemType Directory -Force | Out-Null
    }


    if (-not (test-path "$ProjectsFolderPath\GlobalSettings")){
        Set-Location $ProjectsFolderPath
        $res = Start-Program -Program "git" -Arguments @('clone', $Global:GlobalSettingsURL ) -Description "    Git clone [$Global:GlobalSettingsURL]."
        if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
            Write-host "    Folder already exist." -ForegroundColor yellow
        }
        Else {
            if ( $res.object.exitcode -eq 0 ) {
                Copy-Item -Path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1" -Destination "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings.ps1"
                Remove-Item -path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1"
            }
        }
    }

    $GlobalSettingsScriptPath = "$ProjectsFolderPath\GlobalSettings\SCRIPTS"
    gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkInitScript' , \""$GlobalSettingsScriptPath\Init.ps1\"", [EnvironmentVariableTarget]::Machine )"
    gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkGlobalInitScript' , \""$GlobalSettingsScriptPath\InitGlobal.ps1\"", [EnvironmentVariableTarget]::Machine )"
    Update-Environment

    $ModulePath = $Global:PowershellModulePath
    if ( !(test-path -path $ModulePath) ){
        new-item -path $ModulePath -ItemType Directory | Out-Null
    }

    Install-CustomModule -name "AlexkUtils" -ModulePath $ModulePath -ModuleURI $Global:AlexKUtilsModuleURL -Evaluate
    Install-CustomModule -name "AlexKBuildTools" -ModulePath $ModulePath -ModuleURI $Global:AlexKBuildToolsModuleURL -Evaluate

    if (-not (test-path "$ProjectServicesFolderPath\GitHubRepositoryClone")){
        Set-Location $ProjectServicesFolderPath
        $res = Start-Program -Program "git" -Arguments @('clone', $Global:GitHubRepositoryCloneURL ) -Description "    Git clone [$Global:GitHubRepositoryCloneURL]."
        if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
            Write-host "    Folder already exist." -ForegroundColor yellow
        }
        Else {
            if ( $res.object.exitcode -eq 0 ) {
                Copy-Item -Path "$ProjectServicesFolderPath\GitHubRepositoryClone\SETTINGS\Settings-empty.ps1" -Destination "$ProjectServicesFolderPath\GitHubRepositoryClone\SETTINGS\Settings.ps1"
                Remove-Item -path "$ProjectServicesFolderPath\GitHubRepositoryClone\SETTINGS\Settings-empty.ps1"
            }
        }
    }

    & git.exe config --global user.name  $Global:GitUserName
    & git.exe config --global user.email $Global:GitEmail

    if ( $InstallWMF5 ){
        $Answer = Get-Answer -Title "Computer needed to be restarted. Do you want to restart your computer? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
        if ( $Answer -eq "Y" ){
            write-host "Restarting computer. After restart, run [MyFrameworkInstallerPart2.ps1]." -ForegroundColor Green
            Restart-Computer -delay 10
        }
    }

    $res = Import-Module -name "$ModulePath\AlexkUtils" -Force -PassThru
    if ( !$res){
        write-host "Failed to import module [AlexkUtils]!" -ForegroundColor Red
        exit 1
    }

    $res = Import-Module -name "$ModulePath\AlexKBuildTools" -Force -PassThru
    if ( !$res){
        write-host "Failed to import module [AlexKBuildTools]!" -ForegroundColor Red
        exit 1
    }

    $ProjectsFolderPath  = "$($Global:MyProjectFolderPath)\Projects"
    $GlobalSettingsFilePath = "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings.ps1"

    if ( test-path -path $GlobalSettingsFilePath ) {
        Set-ASTVariableValue -FilePath $GlobalSettingsFilePath -VariableName "Global:gsMyProjectFolderPath" -VariableValue "`"$($Global:MyProjectFolderPath)`""
        . $GlobalSettingsFilePath
    }
    Else {
        write-host "File [$GlobalSettingsFilePath] not found!" -ForegroundColor red
    }

    $GitHubRepositoryCloneSettings = "$($Global:gsProjectServicesFolderPath)\GitHubRepositoryClone\$($Global:gsSETTINGSFolder)\$($Global:gsDefaultSettingsFile)"

    if ( test-path -path $GitHubRepositoryCloneSettings ) {
        Set-ASTVariableValue -FilePath $GitHubRepositoryCloneSettings -VariableName "Global:gsMyProjectFolderPath" -VariableValue "`"$($Global:MyProjectFolderPath)`""
    }
    Else {
        write-host "File [$GitHubRepositoryCloneSettings] not found!" -ForegroundColor red
    }

    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    if ( $StartVSCode ){
        Set-Location -Path $Global:MyProjectFolderPath
        & code "`"$($Global:MyProjectFolderPath)`""
    }

    Remove-FromStartUp -ShortCutName "MyFrameworkInstaller"
    Stop-Transcript

    $Answer = Get-Answer -Title "Do you want to install additional projects? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
    if ( $Answer -eq "Y" ) {
        $GitHubRepositoryCloneScript = "$($Global:gsProjectServicesFolderPath)\GitHubRepositoryClone\$($Global:gsSCRIPTSFolder)\GitHubRepositoryClone.ps1"
        . $GitHubRepositoryCloneScript
    }

    read-host -Prompt "Press enter key..."
    remove-item -path $FileCashFolderPath -Recurse -Force
################################# Script end here ###################################