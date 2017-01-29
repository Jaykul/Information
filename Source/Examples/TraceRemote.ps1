#requires -Module Information
using module Information
<#
    .Synopsis
        An example that features tracking time across remote calls
    .Description
        Note that you must pass in a $RemoteArgs hashtable with the ComputerName (and Credential if necessary).
#>
[CmdletBinding()]param($RemoteArgs = @{})
Set-TraceMessageTemplate '${Env:UserName}@${Env:ComputerName} $e[38;5;1m${Elapsed} $("  " * ${CallStackDepth})$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'
Write-Trace "Enter $PSCommandPath" -Tag Enter, Trace
if($DebugPreference -ne "SilentlyContinue") { $DebugPreference = "Continue"}

# Just waste some time ...
foreach ($loop in 1..10) { Start-Sleep -Milliseconds 100; Write-Trace "Loop $loop" }

Invoke-Command @RemoteArgs {
    param($MessageTemplate, [long]$StartTicks, [TimeSpan]$Offset, [System.Management.Automation.ActionPreference]$PassThruPreference)
    # Does anyone know a way to pass a DateTime or a DateTimeOffset to a remote job?
    $StartTime = [DateTimeOffset]::new($StartTicks, $Offset)
    # Preference variables don't pass through Invoke-Command either
    $DebugPreference = $PassThruPreference

    Import-Module Information
    Set-TraceMessageTemplate $MessageTemplate
    Write-Trace "Passing StopWatch" -StartTime $StartTime

    # Call the other example script
    & (Join-Path (Get-Module Information).ModuleBase "Examples\TraceDelayed.ps1") -StartTime $StartTime
} -Args ([TraceMessage]::MessageTemplate, [TraceMessage]::StartTime.Ticks, [TraceMessage]::StartTime.Offset, $DebugPreference)

Write-Trace "Exit $PSCommandPath" -Tag Exit, Trace