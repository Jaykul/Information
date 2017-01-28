[CmdletBinding()]param()
Write-Trace "Enter $PSCommandPath" -Tag Enter, Trace

function Trace-Sleep {
    [CmdletBinding()]param(
        $Message = "Hello World",
        $Milliseconds = $(Get-Random -Minimum 20 -Maximum 2000)
    )
    Write-Trace "Enter Test-This '$Message' and wait $Milliseconds milliseconds" -Tag Enter, Trace

    Start-Sleep -Milliseconds $Milliseconds

    Write-Trace "Exit Test-This '$Message'" -Tag Exit, Trace
}

Write-Trace "Calling Trace-Sleep" -Tags PSHost

Trace-Sleep "Hello ${Env:USERNAME}"

Write-Trace "Exit $PSCommandPath" -Tag Exit, Trace