class TraceMessage {
    # This holds the original object that's passed in
    [Object]$MessageData
    [String]$Message

    # The CallStack
    [System.Management.Automation.CallStackFrame[]]$CallStack

    # The Time is here so we can use it in the MessageTemplate
    [DateTimeOffset]$TimeGenerated = [DateTimeOffset]::Now
    [TimeSpan]$ElapsedTime

    # A holder for the start time
    static [DateTimeOffset]$StartTime = [DateTimeOffset]::MinValue
    # A default MessageTemplate
    static [string]$MessageTemplate = $(if($global:Host.UI.SupportsVirtualTerminal -or $Env:ConEmuANSI -eq "ON") {
                                          '$e[38;5;1m${Elapsed}$("  " * $CallStackDepth)$e[38;5;6m${Message} $e[38;5;5m${Command} ${ScriptName}:${LineNumber}$e[39m'
                                      } else {
                                          '${Elapsed} ${ScriptName}:${FunctionName}:${LineNumber} ${Message}'
                                      })

    # The only constructor takes the message and the CallStack as parameters
    TraceMessage([Object]$MessageData, [System.Management.Automation.CallStackFrame[]]$CallStack){

        $this.MessageData = $MessageData
        $this.CallStack = $CallStack

        if([DateTimeOffset]::MinValue -eq [TraceMessage]::StartTime) {
            [TraceMessage]::StartTime = $this.TimeGenerated
        }

        $this.ElapsedTime = $this.TimeGenerated - [TraceMessage]::StartTime

        $e = [char]27
        # These are the things I can imagine wanting in the debug message
        $local:Message   = ([PSCustomObject]@{Data=$MessageData} | Format-Table -HideTableHeaders -AutoSize | Out-String)
        $ScriptPath     = $CallStack[0].ScriptName
        if($ScriptPath) {
            $ScriptName = Split-Path $ScriptPath -Leaf
        } else {
            $ScriptName = "<.>"
        }
        $Command        = $CallStack[0].Command
        $FunctionName   = $CallStack[0].FunctionName -replace '^<?(.*?)>?$','$1'
        $LineNumber     = $CallStack[0].ScriptLineNumber
        $Location       = $CallStack[0].Location
        $Arguments      = $CallStack[0].Arguments
        $Time           = $this.TimeGenerated.TimeOfDay
        $Elapsed        = $this.ElapsedTime
        $CallStackDepth = $CallStack.Count - 1

        $this.Message = (Get-Variable ExecutionContext -ValueOnly).InvokeCommand.ExpandString( [TraceMessage]::MessageTemplate )
    }

    [string]ToString() {
        return $this.Message
    }
}