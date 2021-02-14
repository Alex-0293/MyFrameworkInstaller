﻿function Get-OSInfo {
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
        [string] $Description,
        [switch] $Evaluate,
        [switch] $RunAs
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

            if ( $Evaluate ){
                $Res      = gsudo "Start-Process '$ProgPath' -Wait -PassThru -ArgumentList '$Arguments' -RedirectStandardOutput '$Output' -RedirectStandardError '$ErrorOutput'"
            }
            else {
                if ( $RunAs ) {
                    $Res      = Start-Process "`"$ProgPath`"" -Wait -PassThru -ArgumentList $Arguments -RedirectStandardOutput $Output -RedirectStandardError $ErrorOutput -Verb RunAs
                }
                Else {
                    $Res      = Start-Process "`"$ProgPath`"" -Wait -PassThru -ArgumentList $Arguments -RedirectStandardOutput $Output -RedirectStandardError $ErrorOutput
                }
            }


            if ($Res.HasExited -or $Evaluate ) {

                if ( !$Evaluate ) {
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
                            if ( $PSO.ErrorOutput ) {
                                write-host "Error output:"       -ForegroundColor DarkRed
                                write-host "============="       -ForegroundColor DarkRed
                                write-host "$($PSO.ErrorOutput)" -ForegroundColor red
                            }

                            write-host ""

                            if ( $PSO.Output ) {
                                write-host "Std output:"    -ForegroundColor DarkRed
                                write-host "============="  -ForegroundColor DarkRed
                                write-host "$($PSO.Output)" -ForegroundColor red
                            }
                        }
                    }
                } Else {
                    $PSO.Object = ""
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
    write-host "Refresh environment..." -ForegroundColor Yellow
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
function Add-ToStartUp {
    Param (
        [string] $FilePath,
        [string] $ShortCutName,
        [string] $WorkingDirectory
    )

    write-host "Adding shortcut [$ShortCutName] to user startup folder"
    if ( $FilePath ) {
        $UserStartUpFolderPath = "$($Env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Startup"
        
        $WshShell                  = New-Object -comObject WScript.Shell

        $Shortcut                  = $WshShell.CreateShortcut("$UserStartUpFolderPath\$ShortCutName.lnk")
        $Shortcut.TargetPath       = $FilePath
        #$Shortcut.Arguments        = "/iq `"custom.bgi`" /accepteula /timer:0"
        $Shortcut.WorkingDirectory = $WorkingDirectory
        $Shortcut.Save()
    }
}
function New-Folder {
    Param (
        [string] $FolderPath,
        [switch] $Confirm
    )

    $FolderPathExist = test-path -path $FolderPath

    if ( !($FolderPathExist) -or $Confirm ){
        try {
            if ( $Confirm -and $FolderPathExist ){
                $Answer = Get-Answer -Title "Do you want to remove existed folder [$FolderPath]? " -Color "Cyan","DarkMagenta" -AddNewLine -ChooseFrom "y","n" -DefaultChoose "y"
                if ( $Answer -eq "Y"){
                    Remove-Item -path $FolderPath -Force -recurse
                    New-Item -Path $FolderPath -ItemType Directory | Out-Null
                }
            }
            Else {
               New-Item -Path $FolderPath -ItemType Directory | Out-Null
            }
        }
        Catch {
            try {
                if ( $Confirm ){
                    if ( $Answer -eq "Y"){
                        gsudo Remove-Item -path $FolderPath -Force -recurse
                        gsudo New-Item -Path $FolderPath -ItemType Directory | Out-Null
                    }
                }
                Else {
                   gsudo New-Item -Path $FolderPath -ItemType Directory | Out-Null
                }
            }
            Catch {
                Write-host "Folder path [$($FolderPath)] cannot be created! $_" -ForegroundColor Red
            }
        }
    }
    Else {
        Write-host "Folder path [$($FolderPath)] already exist." -ForegroundColor Green
    }
}
function Get-LatestGitHubRelease {
    param (
        [string] $Programm,
        [switch] $Stable
    )
    $releases_url = "https://api.github.com/repos/$Programm/releases"

    $releases = Invoke-RestMethod -uri "$($releases_url)" #?access_token=$($token)

    if ( $stable ) {
        $LatestRelease = $releases | Where-Object {$_.prerelease -eq $false} | Select-Object -First 1
    }
    Else {
        $LatestRelease = $releases | Select-Object -First 1
    }
    
    return $LatestRelease
}
Function Install-Program {
    param (
        [string]   $ProgramName,
        [string]   $Description,
        [string]   $GitRepo,
        [string]   $FilePartX32,
        [string]   $FilePartX64,
        [string]   $OSBit,
        [switch]   $RunAs,
        [string]   $Installer,
        [string[]] $InstallerArguments
    )

    $ProgramExist = Get-Command -name $ProgramName -ErrorAction SilentlyContinue
    if ( $ProgramExist ){
        $IsInstalled = $True
    }
    Else {
        $IsInstalled = $False
    }

    if ( !$IsInstalled ) {
        $Answer = Get-Answer -Title "Do you want to install $Description" -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
        if ( $Answer -eq "Y" ) {
            $Release = Get-LatestGitHubRelease -Programm $GitRepo -Stable
            "PowerShell/PowerShell"
            switch ($OSBit) {
                "32" {  
                    $global:Program   = $Release.assets | Where-Object {$_.name -like "*$FilePartX32"}
                }
                "64" {  
                    $global:Program   = $Release.assets | Where-Object {$_.name -like "*$FilePartX64"}
                }
                Default {}
            }

            [uri] $ProgramURI = $Program.browser_download_url
            $Global:ProgramFileName = "$FileCashFolderPath\$(split-path -path $ProgramURI -Leaf)"
            write-host "Prepare to install $Description [$(split-path -path $ProgramURI -Leaf)] size [$([math]::round($Program.size/ 1mb,2)) MB]."
            If ( $ProgramURI ) {
                if ( test-path -path $Global:ProgramFileName ){
                    Remove-Item -Path $Global:ProgramFileName
                }

                Invoke-WebRequest -Uri $ProgramURI -OutFile $Global:ProgramFileName
                if ( test-path -path $Global:ProgramFileName ){
                    Unblock-File -path $Global:ProgramFileName

                    if ( $RunAs ){
                        $res = Start-Programm -Programm $Installer -Arguments $InstallerArguments -Description "    Installing $Description." -RunAs
                    }
                    Else {
                        $res = Start-Programm -Programm $Installer -Arguments $InstallerArguments -Description "    Installing $Description."
                    }
                }
                Else {
                    Write-Host "Error downloading file [$Global:ProgramFileName]!" -ForegroundColor Red
                }
            }
        }
    }

    Return $res
}
function Compare-Version {
    param(
        [array] $Ver1,
        [array] $Ver2
    )
    #return maximum version

    if ( $Ver1.count -le $Ver2.count ){
        $MinCount = $Ver1.count
    }
    Else {
        $MinCount = $Ver2.count
    }
   
    foreach ( $item in (0..($MinCount-1))) {
        if ( $ver1[$item] -gt $ver2[$item] ) {
            return $ver1
        }
        elseif ( $ver2[$item] -gt $ver1[$item] ) {
            return $ver2
        }
    }
    return $ver1
}
function Remove-FromStartUp {
    Param (
        [string] $ShortCutName
    )

    if ( $ShortCutName ) {
        $UserStartUpFolderPath = "$($Env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Startup"

        $ShorCutPath = "$UserStartUpFolderPath\$($ShortCutName).lnk"
        write-host "Removing shortcut [$ShortCutName] from user startup folder"
        remove-item -path $ShorCutPath -Force -ErrorAction SilentlyContinue
    }
}
function Install-CustomModule {
    param (
        [string] $Name,
        [string] $ModulePath,
        [uri]    $ModuleURI,
        [switch] $Evaluate
    )

    if (-not (test-path "$ModulePath\$Name")){
        if ((test-path "$ModulePath")){
            Set-Location -path $ModulePath
            if ( $Evaluate ){
                $res = Start-Programm -Programm "git" -Arguments @('clone', $ModuleURI ) -Description "    Git clone [$ModuleURI]." -Evaluate
            }
            Else {
                $res = Start-Programm -Programm "git" -Arguments @('clone', $ModuleURI ) -Description "    Git clone [$ModuleURI]."
            }
            if ( $res.ErrorOutput -eq "fatal: destination path 'MyFrameworkInstaller' already exists and is not an empty directory." ){
                Write-host "    Folder already exist." -ForegroundColor yellow
            }
        }
        Else {
            Write-Host "Path [$ModulePath] not found!" -ForegroundColor red
        }
    }
    Else {
        Write-Host "Module [$name] on [$modulePath] already exist!" -ForegroundColor green
    }
}

