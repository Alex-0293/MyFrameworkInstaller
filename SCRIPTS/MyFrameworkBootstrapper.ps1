<#
    .NOTES
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
Function Install-GIt {
    #Git

    #$Res = Install-Program -ProgramName "pwsh.exe" -Description "Powershell 7.x" -GitRepo "PowerShell/PowerShell" -FilePartX32 "*win-x32.msi" -FilePartX64 "*win-x64.msi" -OSBit $OSBit -Installer "msiexec" -InstallerArguments @('/i',"%FilePath%",'/qn','/promptrestart')

    $Release = Get-LatestGitHubRelease -Program "git-for-windows/git" -Stable

    [uri] $global:Git64URI       = ($Release.assets | Where-Object {$_.name -like "*64-bit.exe"}).browser_download_url
    [uri] $global:Git32URI       = ($Release.assets | Where-Object {$_.name -like "*32-bit.exe"}).browser_download_url
    [string] $Global:GitFileName = "$($Global:FileCashFolderPath)\GitInstall.exe"
    $GitVer  = $Release.tag_name.replace("v","").split(".")

    $InstallGit = $True

    $GitExist = Get-Command -Name "Git" -ErrorAction SilentlyContinue
    if ( $GitExist ){
        $res = Start-Program -Program "git" -Arguments '--version' -Description "    Check git version."
        if ( $Res ) {
            write-host "    $($res.output)"
            $GitInstalledVer = $res.output.split(" ")[2].split(".")
            $Max = Compare-Version -ver1 $GitInstalledVer -ver2 $GitVer 
            if ( $Max -le $GitInstalledVer ){
                $InstallGit = $False
            }
        }
    }

    if ( $InstallGit ) {
        write-host "1. Install Git."
        $GitURI = (Get-Variable -name "Git$($OSBit)URI").value
        If ( $GitURI ) {
            if ( test-path -path $Global:GitFileName ){
                Remove-Item -Path $Global:GitFileName
            }

            Invoke-WebRequest -Uri $GitURI -OutFile $Global:GitFileName
            if ( test-path -path $Global:GitFileName ){
                Unblock-File -path $Global:GitFileName
                $res = Start-Program -Program $Global:GitFileName -Arguments '/silent' -Description "    Installing Git."
                if (!$res){
                    exit 1
                }
                Update-Environment
                return $true
            }
            Else {
                Write-Host "Error downloading file [$Global:GitFileName]!" -ForegroundColor Red
                return $false
            }
        }
    }
    return $true
}
Function Set-MyFrameworkInstaller {
    [uri] $Global:MyFrameworkInstaller = "https://github.com/Alex-0293/MyFrameworkInstaller.git"

    write-host "2. Clone my framework installer"

    Set-Location -Path $ProjectServicesFolderPath
    if ( test-path -path "$ProjectServicesFolderPath\MyFrameworkInstaller" ){
        remove-item -path "$ProjectServicesFolderPath\MyFrameworkInstaller" -Force -Recurse
    }
    $res = Start-Program -Program "git" -Arguments 'clone',$Global:MyFrameworkInstaller -Description "    Cloning [$Global:MyFrameworkInstaller]."
        
    if ( $res.object.exitcode -eq 0 ){
        Set-Location -Path "$ProjectServicesFolderPath\MyFrameworkInstaller\SCRIPTS"
        Copy-Item -Path "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings-empty.ps1" -Destination "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings.ps1"
        Remove-Item -path "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings-empty.ps1" 
        return $true  
    }
    else {
        write-host "Error while clonning [$Global:MyFrameworkInstaller], exit code [$($res.object.exitcode)]" -ForegroundColor Red
        return $false
    }
}
Function Install-Powershell7 {
    write-host "3. Check powershell version."
    $PSVer = [int16] $PSVersionTable.PSVersion.major
    write-host "    Powershel version [$PSVer]."
    if ( $PSVer -lt 5 ) {
        $Answer = Get-Answer -Title "Do you want to update host powershell version [$PSVer] to [5]? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine

        if ( $Answer -eq "Y" ) {
            $InstallWMF5 = $true
            if ( $OSVer -and $OSBit ) {
                $WMF5 = (Get-Variable -name "WMF5_$($OSVer)_$($OSBit)").Value
                $Global:WMF5FileName = "$FileCashFolderPath\$(split-path -path $WMF5 -Leaf)"
                Add-ToStartUp -FilePath $env:SetupBatPath -ShortCutName "MyFrameworkInstaller" -WorkingDirectory $Root
                If ( $WMF5 ) {
                    if ( test-path -path $Global:WMF5FileName ){
                        Remove-Item -Path $Global:WMF5FileName
                    }

                    Invoke-WebRequest -Uri $WMF5 -OutFile $Global:WMF5FileName
                    if ( test-path -path $Global:WMF5FileName ){
                        Unblock-File -path $Global:WMF5FileName
                        $res = Start-Program -Program "wusa.exe" -Arguments @($Global:WMF5FileName,'/quiet') -Description "    Installing WMF 5.1."
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

    $Res = Install-Program -ProgramName "pwsh.exe" -Description "Powershell 7.x" -GitRepo "PowerShell/PowerShell" -FilePartX32 "*win-x32.msi" -FilePartX64 "*win-x64.msi" -OSBit $OSBit -RunAs -Installer "msiexec" -InstallerArguments @('/i',"%FilePath%",'/qn','/promptrestart') -force

    if ( $Res ){
        if ( ( $Res.output -like "*Installation completed successfully*" ) -or ( $Res.output -like "*Configuration completed successfully*" ) -or ( $Res -eq $True ) ){
            $Global:PowershellModulePath  = "c:\program files\powershell\7\Modules"
            return $true
        }
        Else {
            $Global:PowershellModulePath  = "c:\program files\powershell\Modules"
            return $false
        }
    }
    Else {
        $Global:PowershellModulePath  = "c:\program files\powershell\Modules"
        return $false
    }
}
Function Set-FrameworkEnvironment {
    #WMF5.1
    [uri]    $Global:WMF5_2012R2_64 = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"

    $LogDirectory = "$($Env:USERPROFILE)\Documents\MyProjects"
    $Global:FileCashFolderPath = "$LogDirectory\Install"
    write-host "File cache folder [$FileCashFolderPath]."
    if ( test-path $FileCashFolderPath ){
        [psobject]$InstallConfig = Import-Clixml -path "$FileCashFolderPath\Config.xml"
        foreach ( $item in $InstallConfig.PSObject.Properties ){
            Set-Variable -Name $item.Name -Value $item.Value -Scope global
        }
    }
    Else {
        $Data = @()
        $PSO = [PSCustomObject]@{
            FullName = "$($Env:USERPROFILE)\Documents\MyProjects"
        }
        $Data += $PSO
        $PSO = [PSCustomObject]@{
            FullName = "c:\DATA\MyProjects"
        }
        $Data += $PSO
        $PSO = [PSCustomObject]@{
            FullName = "Custom"
        }
        $Data += $PSO

        $Global:MyProjectFolderPath = $null

        $Global:MyProjectFolderPath = (Show-ColoredTable -Data $Data -View "FullName" -Title "Path options:" -AddRowNumbers -PassThru -Color   "Cyan","DarkMagenta", "Magenta" -SelectMessage "Select MyProject path: " -SelectField "FullName" -AddNewLine).FullName

        if ( (!$Global:MyProjectFolderPath) -or ($Global:MyProjectFolderPath -eq "Custom") ){
            $Global:MyProjectFolderPath = Get-Answer -Title "Enter custom MyProjects folder path (like: c:\data): " -Color "Cyan","DarkMagenta" -AddNewLine
            if (($Global:MyProjectFolderPath.Substring(($Global:MyProjectFolderPath.Length-1),1) -eq "\") -or ($Global:MyProjectFolderPath.Substring(($Global:MyProjectFolderPath.Length-1),1) -eq "/") ) {
                $Global:MyProjectFolderPath = $Global:MyProjectFolderPath.Substring(0,($Global:MyProjectFolderPath.Length - 1))
            }
            $Global:MyProjectFolderPath = $Global:MyProjectFolderPath + "\MyProjects"
            New-Folder -FolderPath $Global:MyProjectFolderPath -Confirm

        }
        Else {
            New-Folder -FolderPath $Global:MyProjectFolderPath -Confirm
        }

        # $Global:FileCashFolderPath = "$($Global:MyProjectFolderPath)\Install"
        New-Folder -FolderPath $FileCashFolderPath -Force

        [string] $Global:GitUserName         = Get-Answer -Title "Enter your git user name: " -Color "Cyan","DarkMagenta" -AddNewLine
        [string] $Global:GitEmail            = Get-Answer -Title "Enter your git email: " -Color "Cyan","DarkMagenta" -AddNewLine

        $Global:OSInfo = Get-OSInfo

        switch -Wildcard ( $OSInfo.caption ) {
            "*Server 2012 R2*" { $Global:OSVer = "2012R2" }
            "*Windows 10*" { $Global:OSVer = "10" }
            Default { 
                $Global:OSVer = $null 
                Write-host "Unknown OS version [$($OSInfo.caption)]!" -ForegroundColor red
            }
        }

        switch -Wildcard ( $OSInfo.OSArchitecture ) {
            "64*" { $Global:OSBit = 64 }
            "32*" { $Global:OSBit = 32 }
            Default { 
                $Global:OSBit = $null
                Write-host "Unknown OS bitness [$OSInfo.OSArchitecture]!" -ForegroundColor red
            }
        } 

        $Global:ProjectServicesFolderPath = "$($Global:MyProjectFolderPath)\ProjectServices"
        New-Folder -FolderPath $ProjectServicesFolderPath -Confirm

        $InstallConfig = [PSCustomObject]@{
            MyProjectFolderPath       = $MyProjectFolderPath
            GitUserName               = $Global:GitUserName
            GitEmail                  = $Global:GitEmail
            FileCashFolderPath        = $FileCashFolderPath
            ProjectServicesFolderPath = $ProjectServicesFolderPath
            OSVer                     = $Global:OSVer
            OSBit                     = $Global:OSBit
        }

        $InstallConfig | Export-Clixml -Path "$FileCashFolderPath\Config.xml"
    }
    return $true
}
$ScriptVer = "Version 1.7"
Write-host -object $ScriptVer -ForegroundColor "Cyan"

$FunctionFilePath = "$($Env:temp)\Functions.ps1"
. $FunctionFilePath

clear-host
$root = "$($Env:USERPROFILE)\Documents\MyProjects"
Get-ChildItem -path $root -filter "*.log" | remove-item -force -ErrorAction SilentlyContinue

$TransPath = "$root\MyFrameworkBootStrapper-$(Get-date -format 'dd.MM.yy HH-mm-ss').log"
Start-Transcript -path $TransPath

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Step0 = Set-FrameworkEnvironment
if ( $step0 ){
    $Step1 = Install-GIt
    if ( $step1 ){
        $Step2 = Set-MyFrameworkInstaller
        if ( $step2 ){
            $Step3 = Install-Powershell7
            if ( $step3 ) {
                $MyFrameworkInstallerPath = "$ProjectServicesFolderPath\MyFrameworkInstaller\SCRIPTS\MyFrameworkInstaller.ps1"
                Update-Environment
                write-host "Starting [$MyFrameworkInstallerPath]." -ForegroundColor Green
                Stop-Transcript
                & pwsh.exe $MyFrameworkInstallerPath -root "$($Env:USERPROFILE)\Documents\MyProjects"
            }
        }
    }
}

################################# Script end here ###################################