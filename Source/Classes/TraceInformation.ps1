class TraceInformation {
    # This holds the original object that's passed in
    [PSObject]$MessageData
    [String]$Message

    # The CallStack
    [Array]$CallStack

    # The Time is here so we can use it in the InfoTemplate
    [DateTimeOffset]$TimeGenerated = [DateTimeOffset]::Now
    [TimeSpan]$ElapsedTime
    [TimeSpan]$Time

    [string]$FunctionName
    [string]$ScriptPath
    [int]$LineNumber
    [string]$Command
    [PSObject]$Location
    [string]$Arguments
    [string]$ScriptName
    [int]$CallStackDepth



    # A holder for the start time
    static [DateTimeOffset]$StartTime = [DateTimeOffset]::MinValue
    static [int]$ExceptionWidth = 120
    # A default InfoTemplate which specifies a format for time so that the 0 time stamp still shows fractions
    static [string]$InfoTemplate = $(if($global:Host.UI.SupportsVirtualTerminal -or $Env:ConEmuANSI -eq "ON") {
                                          '$e[38;5;1m$("{0:hh\:mm\:ss\.fff}" -f ${Time})$("  " * $CallStackDepth)$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'
                                      } else {
                                          '$("{0:hh\:mm\:ss\.fff}" -f ${Time})$("  " * $CallStackDepth)${Message} <${Command}> ${ScriptName}:${LineNumber}'
                                      })

    # The only constructor takes the message and the CallStack as parameters
    TraceInformation([PSObject]$MessageData, [Array]$CallStack, [string]$Prefix, [bool]$Simple){
        $this.init([PSObject]$MessageData, [Array]$CallStack, [string]$Prefix, [bool]$Simple)
    }

    TraceInformation([PSObject]$MessageData, [Array]$CallStack){
        $this.init([PSObject]$MessageData, [Array]$CallStack, $null, $false)
    }

    hidden [void] init([PSObject]$MessageData, [Array]$CallStack, [string]$Prefix, [bool]$Simple) {

        $this.MessageData = $MessageData
        if($CallStack -isnot [System.Management.Automation.CallStackFrame[]]) {
            $this.CallStack = $CallStack.ForEach{ $_ -split "[\r?\n]+" }
        } else {
            $this.CallStack = $CallStack
        }
        if([DateTimeOffset]::MinValue -eq [TraceInformation]::StartTime) {
            [TraceInformation]::StartTime = $this.TimeGenerated
        }

        $this.ElapsedTime = $this.TimeGenerated - [TraceInformation]::StartTime

        # These are the things I can imagine wanting in the debug message
        $this.Message = ([PSCustomObject]@{Data=$this.MessageData} | Format-Table -HideTableHeaders -AutoSize | Out-String).Trim()
        if($this.MessageData -is [String]) {
            $this.Message = $this.MessageData.Trim("`r","`n")
            if($this.Message -match "\n") {
                $this.Message += "`n" + (" " * [regex]::Match([TraceInformation]::InfoTemplate,'\${?message',"IgnoreCase").Index)
            }
        }

        $Frame = $this.CallStack[0]

        if($Frame -is [string]) {
            $this.FunctionName, $this.ScriptPath, $this.LineNumber = ($Frame -split "^at |, |: line ", 4).Where{$_}
            $this.Command = $this.FunctionName
            $this.Location = $Frame
            $this.Arguments = ''
        } else {
            $this.FunctionName   = $Frame.FunctionName -replace '^<?(.*?)>?$','$1'
            $this.ScriptPath     = $Frame.ScriptName
            $this.LineNumber     = $Frame.ScriptLineNumber
            $this.Command        = $Frame.Command
            $this.Location       = $Frame.Location
            $this.Arguments      = $Frame.Arguments
        }

        if($this.ScriptPath) {
            $this.ScriptName = Split-Path $this.ScriptPath -Leaf
        } else {
            $this.ScriptName = "."
        }

        $this.Time           = $this.TimeGenerated.TimeOfDay
        $this.CallStackDepth = $this.CallStack.Count - 1


        # Handle Error Types
        # Normalize ErrorRecord if available (is it ever not?)
        if($this.MessageData -is [System.Exception] -and $this.MessageData.ErrorRecord) {
            $this.MessageData = $this.MessageData.ErrorRecord
        }

        # Add a prefix for errors if one wasn't manually set
        if($Prefix) {
            $this.Message = $Prefix + " " + $this.Message
        }elseif($this.MessageData -is [System.Management.Automation.Runspaces.RemotingErrorRecord]) {
            $this.Message = "REMOTE ERROR: " + $this.Message
        } elseif($this.MessageData -is [System.Management.Automation.ErrorRecord]) {
            $this.Message = "ERROR: " + $this.Message
        } elseif($this.MessageData -is [System.Exception]) {
            $this.Message = "EXCEPTION: " + $this.Message
        }

        # Expand the exception stack if we weren't asked not to...
        if(!$Simple) {
            $ErrorRecord = $null
            if($this.MessageData -is [System.Management.Automation.ErrorRecord] -or $this.MessageData -is [System.Exception]) {
                $ErrorRecord = $this.MessageData
            }

            # Render the nested errors directly into the message
            $width = [TraceInformation]::ExceptionWidth
            $level = 1
            while($ErrorRecord) {
                if($level -eq 1) {
                    $this.Message += "`n`n"
                }
                $ExMessage = $ErrorRecord | Format-List * -Force | Out-String -Width $width -Stream | ForEach-Object { ("    " * $level) + $_ }
                $this.Message = $this.Message.TrimEnd() + "`n`n`n" +
                                 ("    " * $level) + ($ErrorRecord.GetType().FullName -replace "^\s*(.*?)\s*$","[`$1]`n") +
                                 ($ExMessage[1..$($ExMessage.Length-1)] -join "`n").TrimEnd() +
                                 "`n`n" + ("    " * ($level+1))

                # Unravel all the levels?
                if($ErrorRecord.Exception) {
                    $ErrorRecord = $ErrorRecord.Exception
                } else {
                    $ErrorRecord = $ErrorRecord.InnerException
                }
                $level += 1
                $width -= 4
            }
        }

    }

    [string]ToString() {

        $e = [char]27
        # Copy everything into local variables so they work in ExpandString
        $local:MessageData = $this.MessageData
        $local:Message = $this.Message
        $local:CallStack = $this.CallStack
        $local:TimeGenerated = $this.TimeGenerated
        $local:ElapsedTime = $this.ElapsedTime
        $local:Time = $this.Time
        $local:FunctionName = $this.FunctionName
        $local:ScriptPath = $this.ScriptPath
        $local:LineNumber = $this.LineNumber
        $local:Command = $this.Command
        $local:Location = $this.Location
        $local:Arguments = $this.Arguments
        $local:ScriptName = $this.ScriptName
        $local:CallStackDepth = $this.CallStackDepth

        try {
            return (Get-Variable ExecutionContext -ValueOnly).InvokeCommand.ExpandString( [TraceInformation]::InfoTemplate )
        } catch {
            Write-Warning $_
            return "{0} {1} at {2}" -f $this.Time, $this.Message, $this.Location
        }
    }
}

Update-TypeData -TypeName TraceInformation -SerializationMethod 'AllPublicProperties' -SerializationDepth 4 -Force
Update-TypeData -TypeName System.Management.Automation.InformationRecord -SerializationMethod 'AllPublicProperties' -SerializationDepth 6 -Force
