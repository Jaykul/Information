function Set-TraceMessageTemplate {
    <#
        .Synopsis
            Sets the template string used for trace messages
        .Description
            Allows setting the template string to format the trace messages. You should use single quotes strings with variables in them.
            The following variables are available in Write-Trace:

            $MessageData    = The object passed in to Write-Trace
            $Message        = A string representation of the $MessageData
            $Time           = The current Time (the TimeOfDay from a DateTime)
            $Elapsed        = The elapsed time on the TraceMessage stopwatch

            Additionally, there are several variables from the last frame of the call stack:

            $CallStackDepth = The depth of the callstack (useful for indeting)
            $Command        = The command that was run to invoke the current code (i.e. the last command in the call stack)
            $FunctionName   = The name of the function (if any) containing the current code (might just be <ScriptBlock> to indicate no function)
            $ScriptPath     = The full path for the running script file
            $ScriptName     = The name of the running script file
            $LineNumber     = The line number of the script file
            $Location       = A pre-formatted Location string
            $Arguments      = A string representation of the arguments passed to the executing code

            $e              # The escape character ([char]27) for ANSI

        .Example
            Set-TraceMessageTemplate '${Elapsed} ${ScriptName}:${LineNumber} ${Message}'

            Sets the TraceMessage template to a simple message showing elapsed time, the source, and the message
        .Example
            Set-TraceMessageTemplate '${Elapsed}$("  " * ${CallStackDepth})${Message} <${Command}> ${ScriptName}:${LineNumber}'

            Sets the TraceMessage to a template that includes indenting based on $CallStackDepth
        .Example
            Set-TraceMessageTemplate '$e[38;5;1m${Elapsed}$("  " * ${CallStackDepth})$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'

            Sets the TraceMessage to a nice template with ANSI escape sequences for color and indenting based on $CallStackDepth
        .Example
            Set-TraceMessageTemplate '$("{0:mm\:ss\.fff}" -f ${Elapsed})$(" " * ${CallStackDepth})${Message} <${Command}> ${ScriptName}:${LineNumber}'

            This example shows how to apply a little formatting to the elapsed time.
        .Example
            Set-TraceMessageTemplate '$e[38;5;1m$("{0:mm\:ss\.fff}" -f ${Elapsed})$e[38;5;6m$(" " * ${CallStackDepth})${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'

            This example shows how to add colors to the formatted time
    #>
    [CmdletBinding()]param($Template)

    [TraceMessage]::MessageTemplate = $Template
}