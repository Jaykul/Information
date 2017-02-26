<#
    .Synopsis
        The simplest example, where there's just a script that used to use Write-Host or Write-Verbose ...
    .Description
        NOTE: I added a function in this script so that the example can show a small callstack
    .Example
        .\SimpleExample -InformationAction Continue

        Invoke the example and output the Information stream visibly
#>
[CmdletBinding()]param()
Write-Info "Enter $PSCommandPath"

function Invoke-FakeWork {
    [CmdletBinding()]param(
        $Message = "Hello World",
        $Milliseconds = $(Get-Random -Minimum 20 -Maximum 2000)
    )
    Write-Info "Enter Invoke-FakeWork '$Message' and wait $Milliseconds milliseconds"

    Start-Sleep -Milliseconds $Milliseconds

    Write-Info "Exit Invoke-FakeWork '$Message'"
}

Write-Info "Calling Invoke-FakeWork"

Invoke-FakeWork "Hello ${Env:USERNAME}"

Write-Info "Exit $PSCommandPath"