function Protect-Trace {
    #.Synopsis
    #   Invoke a command and collect the trace (Information) output and store it to file
    #.Description
    #   Wraps invocation of a command with exception handling and logging.
    #   Guarantees exceptions will be fully captured and logged.
    #.Example
    #   $Examples = Join-Path (Get-Module Information).ModuleBase Examples
    #   C:\PS> Protect-Trace -Command "$Examples\TraceException.ps1" -Log "$Examples\TraceException.log.clixml"
    #   C:\PS> $Log = Import-CliXml "$Examples\TraceException.log.clixml"
    #   C:\PS>
    #
    #   Shows how to invoke the TraceException example script, log it, and filter the collected log for exceptions
    [CmdletBinding()]
    param(
        # The command or script path to execute
        [Parameter()]
        $Command,

        # The path to log to
        [Parameter()]
        [string[]]$LogPath,

        # A collection of tags to include in debug output
        # If set, automatically causes Write-Trace output to be copied to the Debug stream
        [string[]]$DebugFilterInclude,

        # A collection of tags to exclute from the debug output
        # If set, automatically causes Write-Trace output to be copied to the Debug stream
        # If DebugFilterInclude is not set, everything except these tags is copied
        [string[]]$DebugFilterExclude
    )
    begin {
        Remove-Variable TraceExceptionLog -ErrorAction Ignore
        if($PSBoundParameters.ContainsKey('DebugFilterInclude')) {
            $Script:DebugFilterInclude = $DebugFilterInclude
        }
        if($PSBoundParameters.ContainsKey('DebugFilterExclude')) {
            $Script:DebugFilterExclude = $DebugFilterExclude
        }
    }

    end {
        trap {
            $ex = $_
            $level = 0
            Write-Trace -MessageData "Exception Caught: $($ex.GetType().FullName)" -Tags ErrorHandling -InformationVariable +TraceExceptionLog
            Write-Trace -MessageData $ex -Tags Exception, $ex.GetType().Name, ErrorHandling -InformationVariable +TraceExceptionLog

            do {
                $Message = $ex | Format-List * -Force | Out-String
                $Message = "$($ex.GetType().Name) [$(($level++))] Output:`n" + $Message.Trim("`r","`n") + "`n" + (" _" * 11)
                Write-Trace $Message -Tags ExceptionString -InformationVariable +TraceExceptionLog

                # Unravel all the levels?
                if($ex -is [System.Management.Automation.ErrorRecord]) {
                    $ex = $ex.Exception
                } else {
                    $ex = $ex.InnerException
                }
            } while($ex)

            if($ErrorActionPreference -eq "Continue") {
                continue
            } else {
                throw
            }
        }

        . {[CmdletBinding()]param() . $Command } -InformationVariable +TraceExceptionLog

        $TraceExceptionLog | Export-Clixml -Path $LogPath
        $LogPath
    }
}