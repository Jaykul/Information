#requires -Module Information
[CmdletBinding()]param($RemoteArgs = @{})
Write-Info "Enter $PSCommandPath" -Tag Enter, Trace

New-Module -Name "My Custom Module" {

    function Invoke-ModuleFunction {
        [CmdletBinding()]
        param (
            [Parameter(ValueFromPipeline)]
            [string[]]$Message
        )
        begin {
            Write-Info "Enter Invoke-ModuleFunction Begin"
            Write-Info "-  Begin $Message"
            Write-Info "Exit Invoke-ModuleFunction Begin"
        }

        process {
            Write-Info "Enter Invoke-ModuleFunction Process"
            Write-Info "-  Process $Message"
            Write-Info "Exit Invoke-ModuleFunction Process"
        }

        end {
            Write-Info "Enter Invoke-ModuleFunction End"
            Write-Info "-  End $Message"
            Write-Info "Exit Invoke-ModuleFunction End"
        }
    }
} | Import-Module


Write-Info "Invoke Module Function" -Tag Enter, Trace

"Hello World", "Goodbye!" | Invoke-ModuleFunction

# Note this won't get printed to host when you specify -InformationAction Continue
# But it will show up if you specify -Debug
"Silence","Is Golden" | Invoke-ModuleFunction -InformationAction SilentlyContinue

Remove-Module "My Custom Module"

Write-Info "Exit $PSCommandPath" -Tag Exit, Trace
