#requires -Module Information
#.Synopsis
#   Copy a script to a remote session and invoke it
[CmdletBinding()]
param(
    # Path to script to run remotely
    [Alias('PSPath')]
    [string]$ScriptPath,

    # Hashtable or array for splatting to script
    [Alias('Args')]
    $ArgumentList,

    # Computers to run the script on
    [Alias('CN')]
    [string[]]$ComputerName,

    # Credentials to use, if necessary
    [PSCredential]$Credential
)

Write-Host "Start Remote Test"

$Guid = [Guid]::NewGuid().Guid

foreach($Server in $ComputerName) {
    $RemotePath = "Remote TestDrive:\Temp\$Guid"
    $LocalPath  = "C:\Temp\$Guid"
    $null = New-PSDrive -Name 'Remote TestDrive' -PSProvider FileSystem -Root "\\$Server\C$"
    $null = mkdir $RemotePath -Force

    $FileName = Join-Path $RemotePath (Split-Path $ScriptPath -Leaf)
    Write-Host "Copy File To Remote: $FileName"
    Copy-Item $ScriptPath -Destination $FileName

    Write-Host "Copy Module To Remotes: $RemotePath\Information"
    Copy-Item (Get-Module Information).ModuleBase -Destination $RemotePath\Information -Recurse

    # Turn it into a local path
    $FileName = $FileName -replace ([regex]::Escape($RemotePath)), $LocalPath

    Write-Host "Invoke the script $FileName remotely on $Server"
    Invoke-Command -ComputerName $Server -Credential $Credential -ArgumentList $FileName, $ArgumentList {
        param($FileName, $ArgumentList)
        Import-Module (Join-Path (Split-Path $FileName) Information\Information.psd1)
        Trace-Info {
            Push-Location (Split-Path $FileName)
            &$FileName @ArgumentList
        }
    }
    Write-Host "Clean up remote files"
    Remove-Item $RemotePath -Recurse
    #Remove-PSDrive "Remote TestsDrive"
}

Write-Host "End Remote Test"
