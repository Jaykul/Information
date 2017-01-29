<#
    .Synopsis
        An example where output doesn't happen right away
    .Description
        In this example we didn't want to call Write-Trace upon entry to the script, but we did want to use Elapsed time
        To make sure the elapsed time is accurate, we create the StopWatch up front, and then pass it to Write-Trace on the first call
        Note that we could just set the static [TraceMessage]::StopWatch, but that would require importing the type with: using module Information
#>
[CmdletBinding()]param()

$StopWatch = [Diagnostics.StopWatch]::new()
$StopWatch.Start()

# Do some stuff ...
$Result = Get-Random -Maximum 1000
Start-Sleep -Milliseconds 500

# Now we're ready to start logging output:
Write-Trace "Initially counted $Result items" -Stopwatch $StopWatch

# And we'll call the first sample script, for fun:
& $PSScriptRoot\TracedScripts.ps1

Write-Trace "Exit $PSCommandPath" -Tag Exit, Trace