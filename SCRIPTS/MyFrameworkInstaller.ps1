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
    Function Install-VSCode {
    <#
        .DESCRIPTION
            Install VSCode latest version.
    #>
        [OutputType([bool])]
        [CmdletBinding()]
        Param(        
        
        )
        begin {
            write-host "5. Install VSCode." -ForegroundColor "Blue"
        }
        process {            
            $Res = Install-Program -ProgramName "code" -Description "VSCode" -DownloadURIx32 $global:VSCode32URI -DownloadURIx64 $global:VSCode64URI -OSBit $OSBit -RunAs -force -TempFileFolder $FileCashFolderPath -DontRemoveTempFiles -InstallerArguments @("/VERYSILENT", "/MERGETASKS=!runcode")
        }
        end {
            return $res
        }
    }  
    Function Initialize-VSCode {
        <#
            .DESCRIPTION
                Initialize VSCode parameters.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(        
            
            )
            begin {
                $Res = $false
            }
            process {
                $CodeCommand = Get-Command "Code" -ErrorAction SilentlyContinue
                $Answer = Get-Answer -Title "Do you want to configure VSCode? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
                if ( $Answer -eq "Y" ) {
                    if ( $CodeCommand ) {
                        write-host "6. Config VSCode." -ForegroundColor "Blue"

                        $res = Start-ProgramNew -Program "code" -Arguments @('--install-extension', 'shan.code-settings-sync') -Description "    Installing VSCode settings sync [shan.code-settings-sync] extention."
                        # if ( $res.ErrorOutput ){
                        #     write-host $res.ErrorOutput -ForegroundColor Red
                        # }

                        $res = Start-ProgramNew -Program "code" -Arguments @('--install-extension', 'ms-vscode.powershell') -Description "    Installing VSCode powershell [ms-vscode.powershell] extention."
                        # if ( $res.ErrorOutput ){
                        #     write-host $res.ErrorOutput -ForegroundColor Red
                        # }

                        $res = Start-ProgramNew -Program "code" -Arguments @('--install-extension', 'pkief.material-icon-theme') -Description "    Installing VSCode icon pack [pkief.material-icon-theme] extention."
                        # if ( $res.ErrorOutput ){
                        #     write-host $res.ErrorOutput -ForegroundColor Red
                        # }

                        write-host "    create VSCode user config" -ForegroundColor "Green"
                        Set-Content -path $Global:VSCodeConfigFilePath -Value $Global:VSCodeConfig -Force

                        write-host "    create MyProject folder" -ForegroundColor "Green"
                        New-Item -Path $Global:MyProjectFolderPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

                        write-host "    create MyProject\Projects folder" -ForegroundColor "Green"
                        New-Item -Path "$($Global:MyProjectFolderPath)\Projects" -ItemType Directory  -ErrorAction SilentlyContinue | Out-Null
                        
                        $res = $True
                    }
                    Else {
                        Write-Host "Code not found!" -ForegroundColor red
                        $res = $false
                    }
                }
            }
            end {
                return $res
            }
    }
    Function Initialize-Folders {
        <#
            .DESCRIPTION
                Initialize framework folder structure.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(        
            
            )
            begin {
                write-host "7. Initialize framework folders." -ForegroundColor "Blue"
                $res = $false
            }
            process {            
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

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Initialize-GlobalSettings {
        <#
            .DESCRIPTION
                Initialize framework folder structure.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(
                [string] $ProjectsFolderPath
            )
            begin {
                write-host "8. Initialize global settings." -ForegroundColor "Blue"
                $res = $false
            }
            process {         
                if (-not (test-path "$ProjectsFolderPath\GlobalSettings")){
                    $res = Start-ProgramNew -Program "git" -Arguments @('clone', $Global:GlobalSettingsURL ) -Description "    Git clone [$Global:GlobalSettingsURL]." -WorkDir $ProjectsFolderPath
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
                #$res1 = Start-ProgramNew -Command "[Environment]::SetEnvironmentVariable('AlexKFrameworkInitScript', `"$GlobalSettingsScriptPath\Init.ps1`", [EnvironmentVariableTarget]::Machine)" -RunAs
                #$res2 = Start-ProgramNew -Command "[Environment]::SetEnvironmentVariable('AlexKFrameworkGlobalInitScript',`"$GlobalSettingsScriptPath\InitGlobal.ps1\`",[EnvironmentVariableTarget]::Machine)" -RunAs
                gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkInitScript' , \""$GlobalSettingsScriptPath\Init.ps1\"", [EnvironmentVariableTarget]::Machine )"
                gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkGlobalInitScript' , \""$GlobalSettingsScriptPath\InitGlobal.ps1\"", [EnvironmentVariableTarget]::Machine )"
                Update-Environment
                $ProjectsFolderPath  = "$($Global:MyProjectFolderPath)\Projects"
                $GlobalSettingsFilePath = "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings.ps1"

                if ( test-path -path $GlobalSettingsFilePath ) {
                    Set-ASTVariableValue -FilePath $GlobalSettingsFilePath -VariableName "Global:gsMyProjectFolderPath" -VariableValue "`"$($Global:MyProjectFolderPath)`""
                    . $GlobalSettingsFilePath
                }
                Else {
                    write-host "File [$GlobalSettingsFilePath] not found!" -ForegroundColor red
                }

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Install-PowershellModules {
        <#
            .DESCRIPTION
                Install powershell modules.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(

            )
            begin {
                write-host "9. Install powershell modules." -ForegroundColor "Blue"
                $res = $false
            }
            process {
                $ModulePath = $Global:PowershellModulePath
                if ( !(test-path -path $ModulePath) ){
                    new-item -path $ModulePath -ItemType Directory | Out-Null
                }

                Install-CustomModule -name "AlexkUtils" -ModulePath $ModulePath -ModuleURI $Global:AlexKUtilsModuleURL -Evaluate
                Install-CustomModule -name "AlexKBuildTools" -ModulePath $ModulePath -ModuleURI $Global:AlexKBuildToolsModuleURL -Evaluate

                if (-not (test-path "$ProjectServicesFolderPath\GitHubRepositoryClone")){
                    $res = Start-ProgramNew -Program "git" -Arguments @('clone', $Global:GitHubRepositoryCloneURL ) -Description "    Git clone [$Global:GitHubRepositoryCloneURL]." -WorkDir $ProjectServicesFolderPath
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

                Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    
                #$res = Start-ProgramNew -Program "powershell" -Arguments @("Install-Module","-Name `"posh-git`"","-Scope `"AllUsers`"") -Evaluate
                #$res = Start-ProgramNew -Command "Install-Module -Name `"oh-my-posh`" -Scope `"AllUsers`"" -Evaluate
                $res = Start-ProgramNew -Command "Install-Module -Name `"PSReadLine`" -Scope `"AllUsers`" -Force -SkipPublisherCheck" -Evaluate

                Install-Module "posh-git" -Scope CurrentUser
                Install-Module "oh-my-posh" -Scope CurrentUser
                Update-Environment

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Import-PowershellModules {
        <#
            .DESCRIPTION
                Install powershell modules.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(

            )
            begin {
                write-host "10. Import powershell modules." -ForegroundColor "Blue"
                $res = $false
            }
            process {
                $ModulePath = $Global:PowershellModulePath
                
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
                
                Import-Module posh-git
                Import-Module oh-my-posh
                
                set-theme "Paradox"

                $NewProfile = @"
                Import-Module posh-git
                Import-Module oh-my-posh
                Set-Theme Paradox
"@

                $NewProfile | Set-Content -path $profile

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Initialize-GitHubRepositoryClone {
        <#
            .DESCRIPTION
                Install powershell modules.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(

            )
            begin {
                write-host "11. Initialize GitHubRepositoryClone project settings." -ForegroundColor "Blue"
                $res = $false
            }
            process {
                $ModulePath = $Global:PowershellModulePath
                
                $GitHubRepositoryCloneSettings = "$($Global:gsProjectServicesFolderPath)\GitHubRepositoryClone\$($Global:gsSETTINGSFolder)\$($Global:gsDefaultSettingsFile)"

                if ( test-path -path $GitHubRepositoryCloneSettings ) {
                    Set-ASTVariableValue -FilePath $GitHubRepositoryCloneSettings -VariableName "Global:gsMyProjectFolderPath" -VariableValue "`"$($Global:MyProjectFolderPath)`""
                }
                Else {
                    write-host "File [$GitHubRepositoryCloneSettings] not found!" -ForegroundColor red
                }

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Remove-TempFiles {
        <#
            .DESCRIPTION
                Clean up environment.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(

            )
            begin {
                write-host "12. Cleanup environment." -ForegroundColor "Blue"
                $res = $false
            }
            process {
                Remove-FromStartUp -ShortCutName "MyFrameworkInstaller"
                Stop-Transcript
                $Answer = Get-Answer -Title "Do you want to remove install folder? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
                if ( $Answer -eq "Y" ) {
                    remove-item -path $FileCashFolderPath -Recurse -Force
                }

                $res = $true
            }
            end {
                return $res
            }
    }
    Function Install-Font {
        write-host "4.2. Install font." -ForegroundColor "Blue"
        $Release = Get-LatestGitHubRelease -Program "microsoft/cascadia-code" -Stable
    
        [uri] $global:FontURI     = ($Release.assets | Where-Object {$_.name -like "CascadiaCode*"}).browser_download_url
        [string] $Global:FileName = "$($Global:FileCashFolderPath)\$($Release.assets.name)"
    
        if ( test-path -path $Global:FileName ){
            # Remove-Item -Path $Global:GitFileName
        }
        Else {
           Invoke-WebRequest -Uri $FontURI -OutFile $Global:FileName
        }
    
        
        if ( test-path -path $Global:FileName ){
            Unblock-File -path $Global:FileName
            $FontArchivePath = $Global:FileName.replace(".zip","")
            if ( !(test-path -path $FontArchivePath) ){
                Expand-Archive -path $Global:FileName -DestinationPath $FontArchivePath
            }
            
            $Res = Install-Fonts -FontFile "$FontArchivePath\TTF\CascadiaCodePL.ttf"

            # if (!$res){
            #     exit 1
            # }
            Update-Environment
            return $true
        }
        Else {
            Write-Host "Error downloading file [$Global:FileName]!" -ForegroundColor Red
            return $false
        }
    
        
    
        
    }
    Function Install-Gsudo {
        <#
            .DESCRIPTION
                Install gsudo utility for evaluate.
        #>
            [OutputType([bool])]
            [CmdletBinding()]
            Param(

            )
            begin {
                write-host "4.1 Install Gsudo." -ForegroundColor "Blue"
                $res = $false
            }
            process {
                if (-not (get-command "gsudo" -ErrorAction SilentlyContinue)) {
                    Set-ExecutionPolicy RemoteSigned -Scope Process
                    $GSudoInstall = Invoke-WebRequest -UseBasicParsing $Global:GSudoInstallURL
                    Invoke-Expression $GSudoInstall
                    Update-Environment
                }

                $res = $true
            }
            end {
                return $res
            }
    }
    
    #remove it
    #$OSBit = 64
    #Stop-Transcript -ErrorAction SilentlyContinue

    #$root = "$($Env:USERPROFILE)\Documents\MyProjects"

    $TransPath = "$root\MyFrameworkInstaller-$(Get-date -format 'dd.MM.yy HH-mm-ss').log"
    Start-Transcript -Path $TransPath
    $ScriptVer = "Version 1.8"    
    $FunctionFilePath = "$($Env:temp)\Functions.ps1"
    . $FunctionFilePath
    Write-host -object $ScriptVer -ForegroundColor "Cyan"

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


    $SettingsPath      = "$MyProjectFolderPath\ProjectServices\MyFrameworkInstaller\SETTINGS\Settings.ps1"
    $EmptySettingsPath = "$MyProjectFolderPath\ProjectServices\MyFrameworkInstaller\SETTINGS\Settings-empty.ps1"
    Copy-Item -Path $EmptySettingsPath -Destination $SettingsPath
    . $SettingsPath    

    $Step41 = Install-Gsudo
    if ( $Step41 ) {
        $Step42 = Install-Font
        if ( $step42 ){
            $step5 = install-VSCode
            if ( $step5 ){
                Update-Environment
                $step6 = Initialize-VSCode
                if ( $step6 ){
                    $Step7 = Initialize-Folders
                    if ( $Step7 ){
                        $Step8 = Initialize-GlobalSettings -ProjectsFolderPath "$MyProjectFolderPath\Projects"
                        if ( $step8 ){
                            $step9 = Install-PowershellModules
                            if ( $step9 ){
                                $step10 = Import-PowershellModules
                                if ( $step10 ){
                                    $step11 = Initialize-GitHubRepositoryClone
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    $ModulePath = $Global:PowershellModulePath

    if ( $InstallWMF5 ){
        $Answer = Get-Answer -Title "Computer needed to be restarted. Do you want to restart your computer? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
        if ( $Answer -eq "Y" ){
            write-host "Restarting computer. After restart, run [MyFrameworkInstallerPart2.ps1]." -ForegroundColor Green
            Restart-Computer -delay 10
        }
    }    

    if ( $step11 ){
        Set-Location -Path $Global:MyProjectFolderPath
        code "`"$($Global:MyProjectFolderPath)`""
        #pause
        #$VSCodeConfig = Get-Content -path $Global:VSCodeConfigFilePath
        
        #$VSCodeSettings = $VSCodeConfig | ConvertFrom-Json
        
        #$VSCodeSettings."sync.autoDownload"  = $false
        #$VSCodeSettings."sync.forceDownload" = $false
        
        #$VSCodeConfig = $VSCodeSettings | ConvertTo-Json
        #$VSCodeConfig | Set-Content -Path $Global:VSCodeConfigFilePath    
    }

    

    $Answer = Get-Answer -Title "Do you want to install additional projects? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
    if ( $Answer -eq "Y" ) {
        $GitHubRepositoryCloneScript = "$($Global:gsProjectServicesFolderPath)\GitHubRepositoryClone\$($Global:gsSCRIPTSFolder)\GitHubRepositoryClone.ps1"
        . $GitHubRepositoryCloneScript
    }
    Remove-TempFiles
################################# Script end here ###################################