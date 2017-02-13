class TraceMessage {
    # This holds the original object that's passed in
    [PSObject]$MessageData
    [String]$Message

    # The CallStack
    [Array]$CallStack

    # The Time is here so we can use it in the MessageTemplate
    [DateTimeOffset]$TimeGenerated = [DateTimeOffset]::Now
    [TimeSpan]$ElapsedTime

    # A holder for the start time
    static [DateTimeOffset]$StartTime = [DateTimeOffset]::MinValue
    # A default MessageTemplate which specifies a format for time so that the 0 time stamp still shows fractions
    static [string]$MessageTemplate = $(if($global:Host.UI.SupportsVirtualTerminal -or $Env:ConEmuANSI -eq "ON") {
                                          '$e[38;5;1m$("{0:hh\:mm\:ss\.fff}" -f ${Elapsed})$("  " * $CallStackDepth)$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'
                                      } else {
                                          '$("{0:hh\:mm\:ss\.fff}" -f ${Elapsed}) ${Message} <${Command}> ${FunctionName}:${LineNumber}'
                                      })

    # The only constructor takes the message and the CallStack as parameters
    TraceMessage([PSObject]$MessageData, [Array]$CallStack){

        $this.MessageData = $MessageData
        if($CallStack -isnot [System.Management.Automation.CallStackFrame[]]) {
            $this.CallStack = $CallStack.ForEach{ $_ -split "[\r?\n]+" }
        } else {
            $this.CallStack = $CallStack
        }
        if([DateTimeOffset]::MinValue -eq [TraceMessage]::StartTime) {
            [TraceMessage]::StartTime = $this.TimeGenerated
        }

        $this.ElapsedTime = $this.TimeGenerated - [TraceMessage]::StartTime

        $e = [char]27
        # These are the things I can imagine wanting in the debug message
        $local:Message = ([PSCustomObject]@{Data=$this.MessageData} | Format-Table -HideTableHeaders -AutoSize | Out-String).Trim()
        if($this.MessageData -is [String]) {
            $local:Message = $this.MessageData.Trim("`r","`n")
            if($local:Message -match "\n") {
                $local:Message += "`n" + (" " * [regex]::Match([TraceMessage]::MessageTemplate,'\${?message',"IgnoreCase").Index)
            }
        }

        $Frame = $this.CallStack[0]

        if($Frame -is [string]) {
            $FunctionName, $ScriptPath, $LineNumber = ($Frame -split "^at |, |: line ", 4).Where{$_}
            $Command = $FunctionName
            $Location = $Frame
            $Arguments = ''
        } else {
            $FunctionName   = $Frame.FunctionName -replace '^<?(.*?)>?$','$1'
            $ScriptPath     = $Frame.ScriptName
            $LineNumber     = $Frame.ScriptLineNumber
            $Command        = $Frame.Command
            $Location       = $Frame.Location
            $Arguments      = $Frame.Arguments
        }

        if($ScriptPath) {
            $ScriptName = Split-Path $ScriptPath -Leaf
        } else {
            $ScriptName = "."
        }

        $Time           = $this.TimeGenerated.TimeOfDay
        $Elapsed        = $this.ElapsedTime
        $CallStackDepth = $this.CallStack.Count - 1

        $this.Message = (Get-Variable ExecutionContext -ValueOnly).InvokeCommand.ExpandString( [TraceMessage]::MessageTemplate )
    }

    [string]ToString() {
        return $this.Message
    }
}