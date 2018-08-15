<#
    .Synopsis
        An example where output doesn't happen right away
    .Description
        In this example we didn't want to call Write-Information upon entry to the script, but we did want to use Elapsed time
        To make sure the elapsed time is accurate, we create the StartTime up front, and then pass it to Write-Information on the first call
        Note: we could set the static [Information.InformationFormatter]::StartTime
    .Example
        .\StartTimeExample -InformationAction Continue

        Invoke the example and output the Information stream visibly
#>
[CmdletBinding()]
param(
    # The time to use as the StartTime for printing elapsed time stamps
    #
    # If you need to do something like this script, where you initialize a StartTime
    # because you don't call Write-Info right away, you should make sure to initialize it as a parameter
    # that way, if you ever need to call it from another script as we do SimpleExample below,
    # you will be able to pass the start time through. See TraceRemote for an example.
    $StartTime = [DateTimeOffset]::UtcNow
)


# Do some stuff ...
$Result = Get-Random -Maximum 1000
Start-Sleep -Milliseconds 1000

# Now we're ready to start logging output:
Write-Info "Initially counted $Result items" -StartTime $StartTime

# And we'll call the first sample script, for fun:
& $PSScriptRoot\SimpleExample.ps1

Write-Info "Exit $PSCommandPath" -Tag Exit, Trace