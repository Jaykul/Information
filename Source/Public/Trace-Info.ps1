function Trace-Info {
    #.Synopsis
    #   Invoke a command and collect the trace (Information) output and store it to file
    #.Description
    #   Wraps invocation of a command with exception handling and logging.
    #   Guarantees exceptions will be fully captured and logged.
    #.Example
    #   $Examples = Join-Path (Get-Module Information).ModuleBase Examples
    #   C:\PS> Trace-Info -Command "$Examples\TraceException.ps1" -Log "$Examples\TraceException.log.clixml"
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
        # If set, automatically causes Write-Info output to be copied to the Debug stream
        [string[]]$DebugFilterInclude,

        # A collection of tags to exclute from the debug output
        # If set, automatically causes Write-Info output to be copied to the Debug stream
        # If DebugFilterInclude is not set, everything except these tags is copied
        [string[]]$DebugFilterExclude,

        [switch]$CatchException,

        [Switch]$Passthru
    )
    begin {
        Remove-Variable TraceExceptionLog -ErrorAction Ignore
        if($PSBoundParameters.ContainsKey('DebugFilterInclude')) {
            $Script:DebugFilterInclude = $DebugFilterInclude
        }
        if($PSBoundParameters.ContainsKey('DebugFilterExclude')) {
            $Script:DebugFilterExclude = $DebugFilterExclude
        }
        Set-Alias Write-Host Write-Info -Scope Global -Option AllScope
    }

    end {
        try {
            . {
                [CmdletBinding()]param()
                 . $Command
            } -InformationVariable +TraceExceptionLog -ErrorVariable +TraceExceptionLog
        } catch {
            # Attempt to remove duplicates (seems to always happen for exceptions)
            $ErrorRecord = $_
            if($null -eq (Compare-Object $TraceExceptionLog[-1] $ErrorRecord -Property $ErrorRecord.GetType().GetProperties().Name)) {
                $TraceExceptionLog = $TraceExceptionLog[0..$($TraceExceptionLog.Count-2)]
            }
        }

        # To make logging convenient, we convert Errors into Information.InformationMessages:
        $Max = $TraceExceptionLog.Count - 1
        :convertErrors foreach($e in 0..$Max) {
            if($TraceExceptionLog[$e] -isnot [System.Management.Automation.InformationRecord]) {
                ## If it's remote, we don't need to re-log it if it's already logged...
                if($TraceExceptionLog[$e] -is [System.Management.Automation.Runspaces.RemotingErrorRecord]) {
                    $ErrorRecord = $TraceExceptionLog[$e]
                    foreach($r in 0..($e-1)) {
                        if($TraceExceptionLog[$r].MessageData.MessageData.Exception.Message -eq $ErrorRecord.MessageData.MessageData.Exception.Message -and
                           $TraceExceptionLog[$r].MessageData.MessageData.Exception.ErrorDetails_ScriptStackTrace -eq $ErrorRecord.MessageData.MessageData.Exception.ScriptStackTrace) {
                            Write-ErrorInfo $TraceExceptionLog[$e] -Simple -InformationVariable +TraceExceptionLog -Prefix "REMOTE ERROR LOG:"
                            continue convertErrors
                        }
                    }
                }

                ## Replace the original with an InformationRecord
                # Write-Warning "Logged Error on (${Env:ComputerName}) $($TraceExceptionLog[$e])"
                # $TraceExceptionLog[$e] = Write-ErrorInfo $TraceExceptionLog[$e] -Passthru -InformationVariable +TraceExceptionLog
                $TraceExceptionLog[$e] = Write-ErrorInfo $TraceExceptionLog[$e] -Prefix "ERROR LOG:" -Passthru
            }
        }
        if($LogPath) {
            $TraceExceptionLog | Export-Clixml -Depth 4 -Path $LogPath
        }
        if($Passthru) {
            $TraceExceptionLog
        }
        Remove-Item Alias:Write-Host # Write-Info
        if(!$CatchException -and $ErrorRecord) {
            throw $ErrorRecord
        }
    }
}