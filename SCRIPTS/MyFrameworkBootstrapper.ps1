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
        [string] $FolderPath
    )

    if ( !(test-path $FolderPath) ){
        try {
            New-Item -Path $FolderPath -ItemType Directory | Out-Null
        }
        Catch {
            try {
                gsudo New-Item -Path $FolderPath -ItemType Directory | Out-Null
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
Function Install-GIt {
    #Git
    $Release = Get-LatestGitHubRelease -Programm "git-for-windows/git" -Stable

    [uri] $global:Git64URI       = ($Release.assets | Where-Object {$_.name -like "*64-bit.exe"}).browser_download_url
    [uri] $global:Git32URI       = ($Release.assets | Where-Object {$_.name -like "*32-bit.exe"}).browser_download_url
    [string] $Global:GitFileName = "$($Env:TEMP)\GitInstall.exe"
    $GitVer  = $Release.tag_name.replace("v","").split(".")

    $InstallGit = $True

    $GitExist = Get-Command -Name "Git" -ErrorAction SilentlyContinue
    if ( $GitExist ){
        $res = Start-Programm -Programm "git" -Arguments '--version' -Description "    Check git version."
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
                $res = Start-Programm -Programm $Global:GitFileName -Arguments '/silent' -Description "    Installing Git."
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
    $res = Start-Programm -Programm "git" -Arguments 'clone',$Global:MyFrameworkInstaller -Description "    Cloning [$Global:MyFrameworkInstaller]."
        
    if ( $res.object.exitcode -eq 0 ){
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
    #Powershell7
    $Release = Get-LatestGitHubRelease -Programm "PowerShell/PowerShell" -Stable

    [uri] $global:Powershell764URI       = ($Release | Where-Object {$_.name -like "*win-x64.msi"}).assets.browser_download_url
    [uri] $global:Powershell732URI       = ($Release | Where-Object {$_.name -like "*win-x64.msi"}).assets.browser_download_url

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
                        $res = Start-Programm -Programm "wusa.exe" -Arguments @($Global:WMF5FileName,'/quiet') -Description "    Installing WMF 5.1."
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

    $Powershell7Exist = Get-Command -name "pwsh.exe" -ErrorAction SilentlyContinue
    if ( $Powershell7Exist ){
        $IsPS7Installed = $True
    }
    Else {
        $IsPS7Installed = $False
    }

    if ( !$IsPS7Installed ) {
        $Answer = Get-Answer -Title "Do you want to install powershell version 7? " -ChooseFrom "y","n" -DefaultChoose "y" -Color "Cyan","DarkMagenta" -AddNewLine
        if ( $Answer -eq "Y" ) {
            write-host "Install Powershell 7."
            Get-Variable
            $Powershell7URI = (Get-Variable -name "Powershell7$($OSBit)URI").Value
            $Global:Powershell7FileName = "$FileCashFolderPath\$(split-path -path $Powershell7URI -Leaf)"
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
        return $true
    }
}

Function Set-FrameworkEnvironment {
    #WMF5.1
    [uri]    $Global:WMF5_2012R2_64 = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
    
    $root = "$($Env:USERPROFILE)\Documents\MyProjects"
    $FileCashFolderPath = "$Root\Install"
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
            New-Folder -FolderPath $Global:MyProjectFolderPath    
        }
        Else {
            New-Folder -FolderPath $Global:MyProjectFolderPath      
        }
        $FileCashFolderPath = "$($Global:MyProjectFolderPath)\Install"
        New-Folder -FolderPath $FileCashFolderPath  

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
        New-Folder -FolderPath $ProjectServicesFolderPath

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

clear-host
Start-Transcript

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
                write-host "Starting [$MyFrameworkInstallerPath]." -ForegroundColor Green

                Update-Environment
                Stop-Transcript

                & pwsh.exe $MyFrameworkInstallerPath -root `"$Global:MyProjectFolderPath`"
            }
        }   
    }
}

################################# Script end here ###################################