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
Function Get-Answer {
<#
    .SYNOPSIS
        Get answer
    .DESCRIPTION
        Colored read host with features.
    .EXAMPLE
        Get-Answer -Title $Title [-ChooseFrom $ChooseFrom] [-DefaultChoose $DefaultChoose] [-Color $Color]
    .NOTES
        AUTHOR  Alexk
        CREATED 26.12.20
        VER     1
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Title message." )]
        [ValidateNotNullOrEmpty()]
        [string] $Title,
        [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Choose from list." )]
        [string[]] $ChooseFrom,
        [Parameter(Mandatory = $false, Position = 2, HelpMessage = "Default option." )]
        [string] $DefaultChoose,
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Two view colors." )]
        [String[]] $Color,
        [Parameter(Mandatory = $false, Position = 4, HelpMessage = "Add new line at the end." )]
        [Switch] $AddNewLine
    )
    $Res = $null

    write-host ""

    if ( $ChooseFrom ) {
        $OptionSeparator = "/"
        $ChoseFromString = ""

        foreach ( $item in $ChooseFrom ) {
            if ( $item.toupper() -ne $DefaultChoose.toupper() ){
                $ChoseFromString += "$($item.toupper())$OptionSeparator"
            }
            Else {
                $ChoseFromString += "($($item.toupper()))$OptionSeparator"
            }
        }

        $ChoseFromString = $ChoseFromString.Substring(0,($ChoseFromString.Length-$OptionSeparator.Length))

        $Message = "$Title [$ChoseFromString]"

        $ChooseFromUpper = @()
        foreach ( $item in $ChooseFrom ){
            $ChooseFromUpper += $item.ToUpper()
        }
        if ( $DefaultChoose ){
            $ChooseFromUpper += ""
        }

        while ( $res -notin $ChooseFromUpper ) {
            if ( $Color ) {
                write-host -object "$Title[" -ForegroundColor $Color[0] -NoNewline
                write-host -object "$ChoseFromString" -ForegroundColor $Color[1] -NoNewline
                write-host -object "]" -ForegroundColor $Color[0] -NoNewline
            }
            Else {
                write-host -object $Message -NoNewline
            }
            $res = Read-Host
            if ( $DefaultChoose ){
                if ( $res -eq "" ) {
                    $res = $DefaultChoose
                }
            }

            $res = $res.ToUpper()
        }
    }
    Else {
        write-host -object $Title -ForegroundColor $Color[0] -NoNewline
        $res = Read-Host
    }

    write-host -object "Selected: " -ForegroundColor $Color[0] -NoNewline
    write-host -object "$res" -ForegroundColor $Color[1] -NoNewline

    if ( $AddNewLine ){
        Write-host ""
    }

    return $Res

}
Function Start-Programm {
    param (
        [string] $Programm,
        [string[]] $Arguments,
        [string] $Description
    )

    $PSO = [PSCustomObject]@{
        Programm    = $Programm
        Arguments   = $null
        Description = $Description
        Command     = get-command $Programm -ErrorAction SilentlyContinue
        Object      = $null        
        Output      = $null 
        ErrorOutput = $null
    }

    if ( $Description ){
        write-host $Description -ForegroundColor Green
    }    
    
    if ( $PSO.Command ) {
        if ( $PSO.Command.path ) {
            $ProgPath    = $PSO.Command.path
            $Output      = "$($Env:temp)\Output.txt"
            $ErrorOutput = "$($Env:temp)\ErrorOutput.txt"

            switch ( $PSO.Command.name ) {
                "msiexec.exe" {  
                    $MSIInstallerLogFilePath = "$($Env:TEMP)\msi.log"
                    $AddLog = $true
                    foreach ( $item in $Arguments ){
                        if ( $item.trim() -like "/LIME*"){
                            $AddLog = $False
                        }
                    }
                    if ( $AddLog ){
                        $Arguments += "/LIME `"$($MSIInstallerLogFilePath)`""
                    }
                }
                "wusa.exe" {  
                    $WUSALogFilePath = "$($Env:TEMP)\wusa.etl"
                    $AddLog = $true
                    foreach ( $item in $Arguments ){
                        if ( $item.trim() -like "/log:*"){
                            $AddLog = $False
                        }
                    }
                    if ( $AddLog ){
                        $Arguments += "/log:`"$($WUSALogFilePath)`""
                    }
                }
                Default {}
            }

            $PSO.Arguments = $Arguments

            $Res      = Start-Process "`"$ProgPath`"" -Wait -PassThru -ArgumentList $Arguments -RedirectStandardOutput $Output -RedirectStandardError $ErrorOutput            
            
            if ($Res.HasExited) {
                
                $PSO.Object = $res
                $PSO.output = Get-Content -path $Output -ErrorAction SilentlyContinue
                Remove-Item -path $Output -Force -ErrorAction SilentlyContinue
                $PSO.ErrorOutput = Get-Content -path $ErrorOutput -ErrorAction SilentlyContinue
                Remove-Item -path $ErrorOutput -Force -ErrorAction SilentlyContinue
                
                switch ( $PSO.Command.name ) {
                    "msiexec.exe" {
                        $PSO.output += Get-Content -path $MSIInstallerLogFilePath -ErrorAction SilentlyContinue
                        Remove-Item -path $MSIInstallerLogFilePath -Force -ErrorAction SilentlyContinue                        
                    }
                    "wusa.exe" {                      
                        $PSO.output += (Get-WinEvent -Path $WUSALogFilePath -oldest | out-string)
                        Remove-Item -path $WUSALogFilePath -Force -ErrorAction SilentlyContinue 
                        $WUSALogFilePath = "$($WUSALogFilePath.Split(".")[0]).dpx"
                        Remove-Item -path $WUSALogFilePath -Force -ErrorAction SilentlyContinue                       
                    }
                    Default {
                        
                    }
                }

                switch ( $Res.ExitCode ) {
                    0 { 
                        Write-host "    Successfully finished." -ForegroundColor green                
                    }
                    Default { 
                        write-host "Error output:"       -ForegroundColor DarkRed
                        write-host "============="       -ForegroundColor DarkRed
                        write-host "$($PSO.ErrorOutput)" -ForegroundColor red
                        write-host ""
                        write-host "Std output:"    -ForegroundColor DarkRed
                        write-host "============="  -ForegroundColor DarkRed
                        write-host "$($PSO.Output)" -ForegroundColor red                        
                        #Write-host "Error [$($Res.ExitCode)] occured!" -ForegroundColor red
                    }
                }
            }
            Else {
                Write-host "Error occured!" -ForegroundColor red
            }
        }
        else{
            Write-host "Command [$Programm] not found!" -ForegroundColor red
        }
    }
    else{
        Write-host "Command [$Programm] not found!" -ForegroundColor red
    }

    Return $PSO
}
function Update-Environment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
#remove it
#$OSBit = 64

$SettingsPath = "$(split-path (split-path $PSCommandPath -Parent) -Parent)\SETTINGS\Settings.ps1"
. $SettingsPath

if (-not (get-command "gsudo" -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope Process
    $GSudoInstall = Invoke-WebRequest -UseBasicParsing $Global:GSudoInstallURL
    Invoke-Expression $GSudoInstall
}

$PSMaximumVer = ($psversiontable.PSCompatibleVersions.major | Measure-Object -max | Select-Object maximum).Maximum
if ( $PSMaximumVer -ge 7 ){
    $IsPS7Installed = $True
}
Else {
    $IsPS7Installed = $False
}
if ( !$IsPS7Installed ) {
    $Answer = Get-Answer -Title "Do you want to install powershell version 7? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
    if ( $Answer -eq "Y" ) {
        write-host "Install Powershell 7."
        $Powershell7URI = (Get-Variable -name "Powershell7$($OSBit)URI").Value
        $Global:Powershell7FileName = "$($Env:TEMP)\$(split-path -path $Powershell7URI -Leaf)"
        If ( $Powershell7URI ) {
            if ( test-path -path $Global:Powershell7FileName ){
                Remove-Item -Path $Global:Powershell7FileName
            }

            Invoke-WebRequest -Uri $Powershell7URI -OutFile $Global:Powershell7FileName
            if ( test-path -path $Global:Powershell7FileName ){
                Unblock-File -path $Global:Powershell7FileName

                $res = Start-Programm -Programm "msiexec" -Arguments @('/i',$Global:Powershell7FileName,'/qn','/promptrestart') -Description "    Installing Powershell 7."
                
                # if ( !(($res.Output -like "*Configuration completed successfully.*") -or ($res.Output -like "*Installation completed successfully.*"))){
                #     write-host $res.Output -ForegroundColor Red
                # } 
            }
            Else {
                Write-Host "Error downloading file [$Global:Powershell7FileName]!" -ForegroundColor Red
            }
        }  
        $Global:PowershellModulePath  = "c:\program files\powershell\7\Modules"
    }
    Else{
        $Global:PowershellModulePath  = "c:\program files\powershell\Modules"
    }
}
Else {
    $Global:PowershellModulePath  = "c:\program files\powershell\7\Modules"
}

$CodeCommand = Get-Command "Code" -ErrorAction SilentlyContinue
if ( !$CodeCommand ) {
    $Answer = Get-Answer -Title "Do you want to install VSCode? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
    if ( $Answer -eq "Y" ) {
        write-host "3. Install VSCode."
        $VSCodeURI = (Get-Variable -name "VSCode$($OSBit)URI").Value
        $Global:VSCodeFileName = "$($Env:TEMP)\VSCode.exe"
        If ( $VSCodeURI ) {
            if ( test-path -path $Global:VSCodeFileName ){
                Remove-Item -Path $Global:VSCodeFileName
            }

            $res = Invoke-WebRequest -Uri $VSCodeURI -OutFile $Global:VSCodeFileName -PassThru
            $OldName = $Global:VSCodeFileName
            $FileName = $res.headers."Content-Disposition".split("`"")[1]
            $Global:VSCodeFileName = "$($Env:TEMP)\$FileName"
            rename-item -Path $OldName -NewName $Global:VSCodeFileName

            if ( test-path -path $Global:VSCodeFileName ){
                Unblock-File -path $Global:VSCodeFileName
                $res = Start-Programm -Programm $Global:VSCodeFileName -Arguments @('/silent', '/MERGETASKS=!runcode') -Description "    Installing VSCode."
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

        $res = Start-Programm -Programm "code" -Arguments @('--install-extension', 'ms-vscode.powershell') -Description "    Installing VSCode powershell extention."
        # if ( $res.ErrorOutput ){
        #     write-host $res.ErrorOutput -ForegroundColor Red
        # }

        $res = Start-Programm -Programm "code" -Arguments @('--install-extension', 'pkief.material-icon-theme') -Description "    Installing VSCode icon pack extention."
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
    $res = Start-Programm -Programm "git" -Arguments @('clone', $Global:GlobalSettingsURL ) -Description "    Git clone [$Global:GlobalSettingsURL]."
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

$ModulePath = $Global:PowershellModulePath
if ( !(test-path -path $ModulePath) ){
    new-item -path $ModulePath -ItemType Directory | Out-Null
}

if (-not (test-path "$ModulePath\AlexkUtils")){
    if ((test-path "$ModulePath")){
        Set-Location -path $ModulePath
        $res = Start-Programm -Programm "git" -Arguments @('clone', $Global:AlexKUtilsModuleURL ) -Description "    Git clone [$Global:AlexKUtilsModuleURL]."
        if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
            Write-host "    Folder already exist." -ForegroundColor yellow  
        }
    }
    Else {
        Write-Host "Path [$ModulePath] not found!" -ForegroundColor red
    }
}

if (-not (test-path "$ModulePath\AlexKBuildTools")){
    Set-Location -path $ModulePath
    if ((test-path "$ModulePath")){
        Set-Location -path $ModulePath
        $res = Start-Programm -Programm "git" -Arguments @('clone', $Global:AlexKBuildToolsModuleURL ) -Description "    Git clone [$Global:AlexKBuildToolsModuleURL]."
        if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
            Write-host "    Folder already exist." -ForegroundColor yellow  
        }        
    }
    Else {
        Write-Host "Path [$ModulePath] not found!" -ForegroundColor red
    }
}

if (-not (test-path "$ProjectServicesFolderPath\GitHubRepositoryClone")){    
    Set-Location $ProjectServicesFolderPath
    $res = Start-Programm -Programm "git" -Arguments @('clone', $Global:GitHubRepositoryCloneURL ) -Description "    Git clone [$Global:GitHubRepositoryCloneURL]."
    if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
        Write-host "    Folder already exist." -ForegroundColor yellow  
    }
    Else {
        if ( $res.object.exitcode -eq 0 ) {
            Copy-Item -Path "$ProjectServicesFolderPath\GitHubRepositoryClone\SETTINGS\Settings-empty.ps1" -Destination "$ProjectServicesFolderPath\GlobalSettings\SETTINGS\Settings.ps1"
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

$res = Import-Module -name "AlexKUtils" -Force -PassThru
if ( !$res){
    write-host "Failed to import module [AlexkUtils]!" -ForegroundColor Red
    exit 1
}

$res = Import-Module -name "AlexKBuildTools" -Force -PassThru
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
    Add-ToLog -Message "File [$GlobalSettingsFilePath] not found!" -Status "Error" -Display
    exit 1
}

$GitHubRepositoryCloneSettings = "$($Global:gsProjectServicesFolderPath)\GitHubRepositoryClone\$($Global:gsSETTINGSFolder)\$($Global:gsDefaultSettingsFile)"

if ( test-path -path $GitHubRepositoryCloneSettings ) {
    Set-ASTVariableValue -FilePath $GitHubRepositoryCloneSettings -VariableName "Global:gsMyProjectFolderPath" -VariableValue "`"$($Global:MyProjectFolderPath)`""

}
Else {
    Add-ToLog -Message "File [$GitHubRepositoryCloneSettings] not found!" -Status "Error" -Display
    exit 1
}

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

if ( $StartVSCode ){
    Set-Location -Path $Global:MyProjectFolderPath
    & code "`"$($Global:MyProjectFolderPath)`""
}
Stop-Transcript
read-host -Prompt "Press any key..."
################################# Script end here ###################################

