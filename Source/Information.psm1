using namespace System.Management.Automation

[Flags()]
enum TracePreference {
    None = 0
    CallStack = 1
    Parameters = 2
}

class TraceMessage : System.Management.Automation.HostInformationMessage {
    # This holds the original object that's passed in
    [Object]$MessageData

    # The CallStack
    [System.Management.Automation.CallStackFrame[]]$CallStack

    # The Time is here so we can use it in the MessageTemplate
    [DateTimeOffset]$TimeGenerated = [DateTimeOffset]::Now

    # A default MessageTemplate
    static [string]$MessageTemplate = $(if($global:Host.UI.SupportsVirtualTerminal -or $Env:ConEmuANSI -eq "ON") {
                                          '$e[38;5;1m${Time}$("  " * $CallStackDepth)$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m"'
                                      } else {
                                          '${Time} ${ScriptName}:${FunctionName}:${LineNumber} ${Message}'
                                      })

    # The only constructor takes the message and the CallStack as parameters
    TraceMessage([Object]$MessageData, [System.Management.Automation.CallStackFrame[]]$CallStack){

        $this.MessageData = $MessageData
        $this.CallStack = $CallStack

        $e = [char]27
        # These are the things I can imagine wanting in the debug message
        $Message        = ([PSCustomObject]@{Data=$MessageData} | Format-Table -HideTableHeaders -AutoSize | Out-String).Trim()
        $ScriptPath     = $CallStack[0].ScriptName
        $ScriptName     = Split-Path $ScriptPath -Leaf
        $Command        = $CallStack[0].Command
        $FunctionName   = $CallStack[0].FunctionName -replace '^<?(.*)>?$','<$1>'
        $LineNumber     = $CallStack[0].ScriptLineNumber
        $Location       = $CallStack[0].Location
        $Arguments      = $CallStack[0].Arguments
        $Time           = $this.TimeGenerated.TimeOfDay
        $CallStackDepth = $CallStack.Count - 1

        $this.Message = (Get-Variable ExecutionContext -ValueOnly).InvokeCommand.ExpandString( [TraceMessage]::MessageTemplate )
    }
}

# dot source the functions
(Join-Path $PSScriptRoot Private\*.ps1 -Resolve -ErrorAction SilentlyContinue).ForEach{ . $_ }
(Join-Path $PSScriptRoot Public\*.ps1 -Resolve).ForEach{ . $_ }
