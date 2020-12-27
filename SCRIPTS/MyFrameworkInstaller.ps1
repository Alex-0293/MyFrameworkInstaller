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

    $Success = $true

    if ( $Description ){
        write-host $Description -ForegroundColor Green
    }


    $Res = Start-Process $Programm -Wait -ArgumentList $Arguments -PassThru

    if ($Res.HasExited) {
        switch ( $Res.ExitCode ) {
            0 { 
                Write-host "Successfully finished." -ForegroundColor green                
            }
            Default { 
                Write-host "Error occured!" -ForegroundColor red
                $Success = $false
            }
        }
    }
    Else {
        Write-host "Error occured!" -ForegroundColor red
        $Success = $false
    }

    Return $Success

}

$SettingsPath = "$(split-path (split-path $PSCommandPath -Parent) -Parent)\SETTINGS\Settings.ps1"
. $SettingsPath

write-host "Check powershell version."
$PSVer = [int16] $PSVersionTable.PSVersion.major
write-host "    Powershel version [$PSVer]."
if ( $PSVer -lt 5 ) {
    $Answer = Get-Answer -Title "Do you want to update host powershell version [$PSVer] to [5]? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine

    if ( $Answer -eq "Y" ) {
        $InstallWMF5 = $true
        if ( $OSVer -and $OSBit ) {
            $WMF5 = (Get-Variable -name "WMF5_$($OSVer)_$($OSBit)").Value
            If ( $WMF5 ) {
                if ( test-path -path $Global:WMF5FileName ){
                    Remove-Item -Path $Global:WMF5FileName
                }

                Invoke-WebRequest -Uri $WMF5 -OutFile $Global:WMF5FileName
                if ( test-path -path $Global:WMF5FileName ){
                    Unblock-File -path $Global:WMF5FileName
                    $res = Start-Programm -Programm "wusa.exe" -Arguments @("$Global:WMF5FileName",'/quiet','/norestart') -Description "    Installing WMF 5.1."
                    if (!$res){
                        exit 1
                    }                    
                }
                Else {
                    Write-Host "Error downloading file [$Global:WMF5FileName]!" -ForegroundColor Red
                }
            }       

        }
        Else {
            exit 1
        }
    }
}

$Answer = Get-Answer -Title "Do you want to install powershell version 7? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
if ( $Answer -eq "Y" ) {
    write-host "Install Powershell 7."
    $Powershell7URI = (Get-Variable -name "Powershell7$($OSBit)URI").Value
    If ( $Powershell7URI ) {
        if ( test-path -path $Global:Powershell7FileName ){
            Remove-Item -Path $Global:Powershell7FileName
        }

        Invoke-WebRequest -Uri $Powershell7URI -OutFile $Global:Powershell7FileName
        if ( test-path -path $Global:Powershell7FileName ){
            Unblock-File -path $Global:Powershell7FileName
            $res = Start-Programm -Programm "msiexec" -Arguments @('/i',"$Global:Powershell7FileName",'/quiet','/qn','/norestart') -Description "    Installing Powershell 7."
            if (!$res){
                exit 1
            } 
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

$Answer = Get-Answer -Title "Do you want to install VSCode? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
if ( $Answer -eq "Y" ) {
    write-host "3. Install VSCode."
    $VSCodeURI = (Get-Variable -name "VSCode$($OSBit)URI").Value
    If ( $VSCodeURI ) {
        if ( test-path -path $Global:VSCodeFileName ){
            Remove-Item -Path $Global:VSCodeFileName
        }

        Invoke-WebRequest -Uri $VSCodeURI -OutFile $Global:VSCodeFileName
        if ( test-path -path $Global:VSCodeFileName ){
            Unblock-File -path $Global:VSCodeFileName
            $res = Start-Programm -Programm $Global:VSCodeFileName -Arguments @('/silent') -Description "    Installing VSCode."
            if (!$res){
                exit 1
            }
        }
        Else {
            Write-Host "Error downloading file [$Global:VSCodeFileName]!" -ForegroundColor Red
        }
    }  

    write-host "4. Config VSCode."
    write-host "   install powershell extention"
    & code --install-extension ms-vscode.powershell
    write-host "   install icon pack"
    & code --install-extension pkief.material-icon-theme
    write-host "   create VSCode user config"
    Set-Content -path $Global:VSCodeConfigFilePath -Value $Global:VSCodeConfig -Force
    write-host "   create MyProject folder"
    New-Item -Path $Global:MyProjectFolderPath -ItemType Directory
    write-host "   create MyProject\Projects folder"
    New-Item -Path "$($Global:MyProjectFolderPath)\Projects" -ItemType Directory
    $StartVSCode = $True    
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


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

$DisabledProjectsFolderPath = "$($Global:MyProjectFolderPath)\DisabledProjects"
if (-not (Test-Path $DisabledProjectsFolderPath) ) {
    New-Item -Path $DisabledProjectsFolderPath  -ItemType Directory -Force
}


if (-not (test-path "$ProjectsFolderPath\GlobalSettings")){    
    Set-Location $ProjectsFolderPath
    & git.exe clone $Global:GlobalSettingsURL
    Copy-Item -Path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1" -Destination "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings.ps1"
    Remove-Item -path "$ProjectsFolderPath\GlobalSettings\SETTINGS\Settings-empty.ps1"
}



$GlobalSettingsScriptPath = "$ProjectsFolderPath\GlobalSettings\SCRIPTS"
gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkInitScript' , \""$GlobalSettingsScriptPath\Init.ps1\"", [EnvironmentVariableTarget]::Machine )"    
gsudo "[Environment]::SetEnvironmentVariable( 'AlexKFrameworkGlobalInitScript' , \""$GlobalSettingsScriptPath\InitGlobal.ps1\"", [EnvironmentVariableTarget]::Machine )"  

$ModulePath = $Global:PowershellModulePath
if ( !(test-path -path $ModulePath) ){
    new-item -path $ModulePath -ItemType Directory
}

if (-not (test-path "$ModulePath\AlexkUtils")){
    Set-Location -path $ModulePath
    gsudo git.exe clone $Global:AlexKUtilsModuleURL 
}

if (-not (test-path "$ModulePath\AlexKBuildTools")){
    Set-Location -path $ModulePath
    gsudo git.exe clone $Global:AlexKBuildToolsModuleURL 
}

if (-not (test-path "$ProjectServicesFolderPath\GitHubRepositoryClone")){    
    Set-Location $ProjectServicesFolderPath
    & git.exe clone $Global:GitHubRepositoryCloneURL
    Copy-Item -Path "$ProjectsFolderPath\GitHubRepositoryClone\SETTINGS\Settings-empty.ps1" -Destination "$ProjectsFolderPath\GitHubRepositoryClone\SETTINGS\Settings.ps1"
    Remove-Item -path "$ProjectsFolderPath\GitHubRepositoryClone\SETTINGS\Settings-empty.ps1"
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

################################# Script end here ###################################

