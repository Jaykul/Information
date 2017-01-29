#requires -Module Information
using module Information

<#
    .Synopsis
        An example that features tracking time across remote calls
    .Description
        Note that you must have pre-configured a $Remote variable that is a hashtable with the ComputerName (and Credential if necessary).
#>
[CmdletBinding()]param()
Write-Trace "Enter $PSCommandPath" -Tag Enter, Trace

# Just waste some time ...
foreach ($loop in 1..10) {
    Start-Sleep -Milliseconds 100
    Write-Trace "Loop $loop"
}

Invoke-Command @Remote {
    param($MessageTemplate, $StopWatch)
    # Preference variables don't pass through Invoke-Command
    $DebugPreference = "Continue"

    Import-Module Information
    Set-TraceMessageTemplate $MessageTemplate
    Write-Trace "Passing ::StopWatch" -Stopwatch $StopWatch

    # Call the other example script
    & (Join-Path (Get-Module).ModuleBase "Examples\TracedScripts.ps1")
} -Args ([TraceMessage]::MessageTemplate, [TraceMessage]::StopWatch)


Write-Trace "Exit $PSCommandPath" -Tag Exit, Trace