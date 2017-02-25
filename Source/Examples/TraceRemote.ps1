#requires -Module Information
using module Information
<#
    .Synopsis
        An example that features tracking time across remote calls
    .Description
        Note that you must pass in a $RemoteArgs hashtable with the ComputerName (and Credential if necessary).
#>
[CmdletBinding()]param($RemoteArgs = @{})
# Another example of a trace template that includes the computer name, but with elapsed time, instead of clock time...
Set-InfoTemplate '{PSComputerName} `e[38;5;1m{ElapsedTime:mm:ss.fff} {Indent}`e[38;5;6m{Message} `e[38;5;5m<{Command}> {ScriptName}:{LineNumber}`e[39m'
Write-Info "Enter $PSCommandPath" -Tag Enter, Trace
if($DebugPreference -ne "SilentlyContinue") { $DebugPreference = "Continue"}

# Just waste some time ...
foreach ($loop in 1..10) {
    Start-Sleep -Milliseconds 100
    Write-Info "Loop $loop"
}

Invoke-Command @RemoteArgs {
    param([System.Management.Automation.ActionPreference]$PassThruPreference)
    # Preference variables don't pass through Invoke-Command
    $DebugPreference = $PassThruPreference
    $env:PSModulePath +=";" + "C:\Users\Joel\Projects\Modules"

    Import-Module Information
    Write-Info "No need to pass the StopWatch?"

    # Call the other example script
    & (Join-Path (Get-Module Information).ModuleBase "Examples\TraceDelayed.ps1")
} -Args $DebugPreference

Write-Info "Exit $PSCommandPath" -Tag Exit, Trace