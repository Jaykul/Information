#requires -Module Information
[CmdletBinding()]param($RemoteArgs = @{})
Write-Trace "Enter $PSCommandPath" -Tag Enter, Trace


New-Module -Name "My Custom Module" {

    function Invoke-ModuleFunction {
        [CmdletBinding()]
        param (
            [Parameter(ValueFromPipeline)]
            [string[]]$Message
        )
        begin {
            Write-Trace "Enter Invoke-ModuleFunction Begin"
            Write-Trace "-  Begin $Message"
            Write-Trace "Exit Invoke-ModuleFunction Begin"
        }

        process {
            Write-Trace "Enter Invoke-ModuleFunction Process"
            Write-Trace "-  Process $Message"
            Write-Trace "Exit Invoke-ModuleFunction Process"
        }

        end {
            Write-Trace "Enter Invoke-ModuleFunction End"
            Write-Trace "-  End $Message"
            Write-Trace "Exit Invoke-ModuleFunction End"
        }
    }
} | Import-Module


Write-Trace "Invoke Module Function" -Tag Enter, Trace

"Hello World", "Goodbye!" | Invoke-ModuleFunction

# Note this won't get printed to host when you specify -InformationAction Continue
# But it will show up if you specify -Debug
"Silence","Is Golden" | Invoke-ModuleFunction -InformationAction SilentlyContinue

Remove-Module "My Custom Module"

Write-Trace "Exit $PSCommandPath" -Tag Exit, Trace
