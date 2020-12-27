﻿<#
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
function Get-OSInfo {
    $OSInfo = Get-CimInstance Win32_OperatingSystem | select-object *  
    return $OsInfo  
}
function Convert-StringToDigitArray {
<#
    .SYNOPSIS
        Convert string to digit array
    .DESCRIPTION
        Convert string to array of digit.
    .EXAMPLE
        Convert-StringToDigitArray -UserInput $UserInput -DataSize $DataSize
    .NOTES
        AUTHOR  Alexk
        CREATED 05.11.20
        VER     1
#>
    [OutputType([Int[]])]
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0, HelpMessage = "String input data.")]
        [string] $UserInput,
        [Parameter( Mandatory = $True, Position = 1, HelpMessage = "Data size.")]
        [int] $DataSize
    )

    $SelectedArray = ($UserInput -split ",").trim()
    if ( $SelectedArray[0] -eq "*" ){
        $SelectedArray = @()
        foreach ( $Element in ( 1..( $DataSize-1 ) ) ) {
            $SelectedArray += $Element
        }
    }
    Else {
        $SelectedIntervals = $SelectedArray | Where-Object { $_ -like "*-*" }
        [int[]]$SelectedArray = $SelectedArray | Where-Object { $_ -NotLike "*-*" }
        foreach ( $item in $SelectedIntervals ) {
            [int[]]$Array = $item -split "-"
            if ( $Array.count -eq 2 ) {
                if ( $Array[0] -le $Array[1] ) {
                    $Begin = $Array[0]
                    $End = $Array[1]
                }
                Else {
                    $Begin = $Array[1]
                    $End = $Array[0]
                }
                foreach ( $Element in ($begin..$end) ) {
                    if ( -not ($Element -in $SelectedArray) -and ($Element -gt 0) ) {
                        $SelectedArray += $Element
                    }
                }
            }
        }
    }

    return $SelectedArray
}
function Show-ColoredTable {
<#
    .SYNOPSIS
        Show colored table
    .DESCRIPTION
        Show table in color view.
    .EXAMPLE
        Parameter set: "Alerts"
        Show-ColoredTable -Field $Field [-Data $Data] [-Definition $Definition] [-View $View] [-Title $Title] [-SelectField $SelectField] [-SelectMessage $SelectMessage]
        Parameter set: "Color"
        Show-ColoredTable [-Data $Data] [-View $View] [-Color $Color] [-Title $Title] [-AddRowNumbers $AddRowNumbers] [-SelectField $SelectField] [-SelectMessage $SelectMessage] [-PassThru $PassThru]
    .NOTES
        AUTHOR  Alexk
        CREATED 02.12.20
        VER     1
#>
    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $false, Position = 0, HelpMessage = "PsObject data." )]
        [psObject[]] $Data,
        [Parameter( Mandatory = $true, Position = 1, HelpMessage = "Field.", ParameterSetName = "Alerts" )]
        [ValidateNotNullOrEmpty()]
        [string] $Field,
        [Parameter( Mandatory = $false, Position = 2, HelpMessage = "Color rules definition.", ParameterSetName = "Alerts" )]
        [psObject] $Definition,
        [Parameter( Mandatory = $false, Position = 3, HelpMessage = "Selected fields view." )]
        $View,
        [Parameter( Mandatory = $false, Position = 4, HelpMessage = "Change each line color.", ParameterSetName = "Color")]
        [String[]] $Color,
        [Parameter( Mandatory = $false, Position = 5, HelpMessage = "Table title.")]
        [String] $Title,
        [Parameter( Mandatory = $false, Position = 6, HelpMessage = "Add row numbers.", ParameterSetName = "Color" )]
        [switch] $AddRowNumbers,
        [Parameter( Mandatory = $false, Position = 7, HelpMessage = "Select message.")]
        [string] $SelectField,
        [Parameter( Mandatory = $false, Position = 8, HelpMessage = "Select message.")]
        [string] $SelectMessage,
        [Parameter( Mandatory = $false, Position = 9, HelpMessage = "Add new line at the end.", ParameterSetName = "Color" )]
        [switch] $AddNewLine,
        [Parameter( Mandatory = $false, Position = 10, HelpMessage = "Return object.", ParameterSetName = "Color" )]
        [switch] $PassThru
    )

    If ( !$View ){
        $View = "*"
    }
    $First = $true

    if ( $Field ) {
        if ( !$Definition ){
            $Definition = [PSCustomObject]@{
                Information = @{Field = "Information"; Color = "Green"}
                Verbose     = @{Field = "Verbose"    ; Color = "Green"}
                Error       = @{Field = "Error"      ; Color = "Red"}
                Warning     = @{Field = "Warning"    ; Color = "Yellow"}
            }
        }

        foreach ( $Item in $Data ){
            switch ( $Item.$Field ) {
                $Definition.Information.Field {
                    if ( $First ) {
                        write-host ""
                        write-host "$(($Item | format-table -property $View -AutoSize | Out-String).trim() )" -ForegroundColor $Definition.Information.Color
                        $First = $false
                    }
                    Else {
                        write-host "$(($Item | format-table -property $View -AutoSize -HideTableHeaders | Out-String).trim() )" -ForegroundColor $Definition.Information.Color
                    }
                }
                $Definition.Verbose.Field {
                    if ( $First ) {
                        write-host ""
                        write-host "$(($Item | format-table -property $View -AutoSize | Out-String).trim() )" -ForegroundColor $Definition.Verbose.Color
                        $First = $false
                    }
                    Else {
                        write-host "$(($Item | format-table -property $View -AutoSize -HideTableHeaders | Out-String).trim() )" -ForegroundColor $Definition.Verbose.Color
                    }
                }
                $Definition.Error.Field {
                    if ( $First ) {
                        write-host "$(($Item | format-table -property $View -AutoSize | Out-String).trim() )" -ForegroundColor $Definition.Error.Color
                        $First = $false
                    }
                    Else {
                        write-host "$(($Item | format-table -property $View -AutoSize -HideTableHeaders | Out-String).trim() )" -ForegroundColor $Definition.Error.Color
                    }
                }
                $Definition.Warning.Field {
                    if ( $First ) {
                        write-host "$(($Item | format-table -property $View -AutoSize | Out-String).trim() )" -ForegroundColor $Definition.Warning.Color
                        $First = $false
                    }
                    Else {
                        write-host "$(($Item | format-table -property $View -AutoSize -HideTableHeaders | Out-String).trim() )" -ForegroundColor $Definition.Warning.Color
                    }
                }
                Default {
                    Write-host "$(($Item | format-table -property $View -AutoSize -HideTableHeaders | Out-String).trim() )" -ForegroundColor "White"
                }
            }
        }
    }
    Else {
        if ( $AddRowNumbers ){
            $Counter = 1
            $Result = @()
            foreach ( $item in $Data ) {
                $item | Add-Member -MemberType NoteProperty -Name "Num" -Value "$Counter"
                $Result  += $item
                $Counter ++
            }
            $NewView  = @("Num")
            $NewView += $View
            $Data = $Result
            $View = $NewView
        }

        if ( !$Color ){
            $Exclude   = "White", "Black", "Yellow", "Red"
            $ColorList = [Enum]::GetValues([System.ConsoleColor])
            $Basic     = $ColorList | where-object {$_ -notlike "Dark*"} | where-object {$_ -notin $Exclude}

            $Pairs = @()
            foreach ( $Item in $basic ){
                $Pairs += ,@("$Item", "Dark$Item")
            }

            $ColorPair = , @($Pairs) | Get-Random
            $Header    = $ColorList | where-object {$_ -notin $ColorPair} | get-random
            $Color     = @($Header)
            $Color    += $ColorPair
        }
        if ( $Title ){
            write-host "$Title"  -ForegroundColor $Color[0] # ($($Color -join(",")))"
            write-host ""
        }

        $Cnt        = 1
        $FirstCnt   = 0
        $ColorCount = $Color.Count - 1

        $TableData  = ( $Data  | format-table -property $View -AutoSize | Out-String ).trim().split("`r")
        foreach ( $line in $TableData ){
            if ( $First ) {
                write-host $line -ForegroundColor $Color[0] -NoNewLine
                $FirstCnt ++
                if ( $FirstCnt -gt 1 ){
                    $First = $false
                }
            }
            Else {
                write-host $line -ForegroundColor $Color[$Cnt] -NoNewLine
            }

            if ( $Cnt -lt $ColorCount){
                $Cnt++
            }
            Else {
                $Cnt = 1
            }
        }

        write-host ""
    }

    if ( $SelectMessage ){
        Write-host ""
        Write-Host $SelectMessage -NoNewline -ForegroundColor $Color[0]
        $Selected       = Read-Host
        $SelectedNum    = Convert-StringToDigitArray -UserInput $Selected -DataSize $Data.count
        $SelectedFields = ($Data | Where-Object { ($Data.IndexOf($_) + 1) -in $SelectedNum }).$SelectField
        $SelectedArray  = $Data | Where-Object { $_.$SelectField -in $SelectedFields }
        Write-Host ""
        write-host "Selected items: " -ForegroundColor $Color[0]

        $Cnt        = 1
        $ColorCount = $Color.Count - 1

        $TableData  = ( $SelectedArray  | format-table -property $View -AutoSize | Out-String ).trim().split("`r")
        foreach ( $line in $TableData ){
            write-host $line -ForegroundColor $Color[$Cnt] -NoNewLine

            if ( $Cnt -lt $ColorCount){
                $Cnt++
            }
            Else {
                $Cnt = 1
            }
        }
        if ( $AddNewLine ){
            Write-host ""
        }

        return $SelectedArray
    }
    Else {
        if ( $AddNewLine ){
            Write-host ""
        }
        if ( $PassThru ){
            return $Result
        }
    }
}
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

#Git
[uri] $global:Git64URI       = "https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.3/Git-2.29.2.3-64-bit.exe"
[uri] $global:Git32URI       = "https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.3/Git-2.29.2.3-32-bit.exe"
[string] $Global:GitFileName = "$($Env:TEMP)\GitInstall.exe"

[uri] $Global:MyFrameworkInstaller = "https://github.com/Alex-0293/MyFrameworkInstaller.git"

[uri] $Global:GSudoInstallURL      = "https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1"

if (-not (get-command "gsudo" -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope Process
    $GSudoInstall = Invoke-WebRequest -UseBasicParsing $Global:GSudoInstallURL
    Invoke-Expression $GSudoInstall
}

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
    if ( !(test-path $Global:MyProjectFolderPath) ){
        try {
            New-Item -Path $Global:MyProjectFolderPath -ItemType Directory
        }
        Catch {
            try {
                gsudo New-Item -Path $Global:MyProjectFolderPath -ItemType Directory
            }
            Catch {            
                Write-host "Folder path [$($Global:MyProjectFolderPath)] cannot be created! $_" -ForegroundColor Red
            }
        }
    }
    Else {
        Write-host "Folder path [$($Global:MyProjectFolderPath)] already exist." -ForegroundColor Green
    }
}
Else {
    if ( !(test-path $Global:MyProjectFolderPath) ){
        try {
            New-Item -Path $Global:MyProjectFolderPath -ItemType Directory
        }
        Catch {
            try {
                gsudo New-Item -Path $Global:MyProjectFolderPath -ItemType Directory
            }
            Catch {            
                Write-host "Folder path [$($Global:MyProjectFolderPath)] cannot be created! $_" -ForegroundColor Red
            }
        }
    }
    Else {
        Write-host "Folder path [$($Global:MyProjectFolderPath)] already exist." -ForegroundColor Green
    }
}

[string] $Global:GitUserName         = Get-Answer -Title "Enter your git user name: " -Color "Cyan","DarkMagenta" -AddNewLine
[string] $Global:GitEmail            = Get-Answer -Title "Enter your git email: " -Color "Cyan","DarkMagenta" -AddNewLine

$Global:OSInfo = Get-OSInfo

switch ( $OSInfo.caption ) {
    "Microsoft Windows Server 2012 R2 Standard" { $Global:OSVer = "2012R2" }
    Default { 
        $Global:OSVer = $null 
        Write-host "Unknown OS version [$OSInfo.caption]!" -ForegroundColor red
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

write-host "1. Install Git."
$GitURI = (Get-Variable -name "Git$($OSBit)URI").value
If ( $GitURI ) {
    if ( test-path -path $Global:GitFileName ){
        Remove-Item -Path $Global:GitFileName
    }

    Invoke-WebRequest -Uri $GitURI -OutFile $Global:GitFileName
    if ( test-path -path $Global:GitFileName ){
        Unblock-File -path $Global:GitFileName
        $res = Start-Programm -Programm $Global:GitFileName -Arguments '/silent' -Description "    Installing Git."
        if (!$res){
            exit 1
        }
    }
    Else {
        Write-Host "Error downloading file [$Global:GitFileName]!" -ForegroundColor Red
    }
}    
write-host "2. Clone my framework installer"
$ProjectServicesFolderPath = "$($Global:MyProjectFolderPath)\ProjectServices"
if ( !(test-path -path $ProjectServicesFolderPath) ){
    try {
        New-Item -Path $ProjectServicesFolderPath -ItemType Directory
    }
    Catch{
        try {
            gsudo New-Item -Path $ProjectServicesFolderPath -ItemType Directory
        }
        Catch {
            Write-host "Folder path [$ProjectServicesFolderPath] cannot be created! $_" -ForegroundColor Red
        }
    }
}

Set-Location -Path $ProjectServicesFolderPath
& git clone $Global:MyFrameworkInstaller


Copy-Item -Path "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings-empty.ps1" -Destination "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings.ps1"
Remove-Item -path "$ProjectServicesFolderPath\MyFrameworkInstaller\SETTINGS\Settings-empty.ps1"
$MyFrameworkInstaller = "$ProjectServicesFolderPath\MyFrameworkInstaller\SCRIPTS\MyFrameworkInstaller.ps1"
write-host "Starting [$MyFrameworkInstallerPart0]." -ForegroundColor Green
start-sleep -Seconds 10
. $MyFrameworkInstaller
################################# Script end here ###################################
