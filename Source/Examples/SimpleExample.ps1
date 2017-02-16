<#
    .Synopsis
        The simplest example, where there's just a script that used to use Write-Host or Write-Verbose ...
    .Description
        NOTE: I added a function in this script so that the example can show a small callstack
#>
[CmdletBinding()]param()
# Imagine this is a legacy script, and there was a lot of Write-Verbose or Write-Debug
Set-Alias Write-Verbose Write-Info
# Write-Host man cause problems, because it has:
# -ForegroundColor -BackgroundColor and -NoNewLine
# And those are not implemented on Write-Info
Set-Alias Write-Host Write-Info


Write-Host "Enter $PSCommandPath"

function Invoke-FakeWork {
    [CmdletBinding()]param(
        $Message = "Hello World",
        $Milliseconds = $(Get-Random -Minimum 20 -Maximum 2000)
    )
    Write-Verbose "Enter Test-This '$Message' and wait $Milliseconds milliseconds"

    Start-Sleep -Milliseconds $Milliseconds

    Write-Verbose "Exit Test-This '$Message'"
}

Write-Host "Calling Trace-Sleep"

Invoke-FakeWork "Hello ${Env:USERNAME}"

Write-Host "Exit $PSCommandPath"