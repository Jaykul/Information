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
        [string]$LogPath,

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
        $RealStart = [DateTimeOffset]::Now

        try {
            . {[CmdletBinding()]param() . $Command } -InformationVariable +TraceExceptionLog -ErrorVariable +TraceExceptionLog
        } catch {
            $ex = $_
            $level = 0
            # Make sure this error shows up in the error stream (as the last error)
            Write-Error -ErrorRecord $ex
            Write-Trace -MessageData "Protect-Trace Caught: $($ex.GetType().FullName)" -Tags ErrorHandling -InformationVariable +TraceExceptionLog
            # Write-Trace -MessageData $ex -Tags Exception, $ex.GetType().Name, ErrorHandling -InformationVariable +TraceExceptionLog

            do {
                $Message = $ex | Format-List * -Force | Out-String
                $Message = "$($ex.GetType().Name)$(if(($level++)){" - Nested Exception ($level)"}):`n" + $Message.Trim("`r","`n")
                Write-Trace $Message -Tags ExceptionString, $ex.GetType().Name -InformationVariable +TraceExceptionLog

                # Unravel all the levels?
                if($ex -is [System.Management.Automation.ErrorRecord]) {
                    $ex = $ex.Exception
                } else {
                    $ex = $ex.InnerException
                }
            } while($ex)
        }
        $RealEnd = [DateTimeOffset]::Now

        # To make logging convenient, we convert Errors into TraceMessages:
        foreach($e in 0..($TraceExceptionLog.Count - 1)) {
            if($TraceExceptionLog[$e] -isnot [System.Management.Automation.InformationRecord]) {
                $Information_Record = @{
                    MessageData = $TraceExceptionLog[$e]
                    CallStack = $TraceExceptionLog[$e].ScriptStackTrace
                    Tags = "ErrorStream",$TraceExceptionLog[$e].GetType().Name
                }

                if(!($TraceExceptionLog[$e].PSTypeNames -match "ErrorRecord")) {
                    $Information_Record.CallStack = $TraceExceptionLog[$e].ErrorRecord.ScriptStackTrace
                    $Information_Record.Tags += "Exception"
                }

                $TraceExceptionLog[$e] = New-TraceMessageInformationRecord @Information_Record

                $Start = $RealStart
                $End = $RealEnd
                foreach($back in $e..0) {
                    if([DateTimeOffset]$Time = $TraceExceptionLog[$e].TimeGenerated) {
                        $Start = $Time
                        break
                    }
                }
                foreach($back in $e..($TraceExceptionLog.Count - 1)) {
                    if([DateTimeOffset]$Time = $TraceExceptionLog[$e].TimeGenerated) {
                        $End = $Time
                        break
                    }
                }
                # pre-date this event to try and line it up with when it really happened..
                $TraceExceptionLog[$e].TimeGenerated = $Start.AddMilliseconds(($End - $Start).TotalMilliseconds / 2).DateTime
            }
        }


        if($LogPath) {
            $TraceExceptionLog | Export-Clixml -Depth 4 -Path $LogPath
            Get-Item $LogPath
        } else {
            $TraceExceptionLog
        }
    }
}