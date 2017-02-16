function Set-InfoTemplate {
    <#
        .Synopsis
            Sets the template string used for trace messages
        .Description
            Allows setting the template string to format the trace messages. You should use single quotes strings with variables in them.
            The following variables are available in Write-Info:

            $MessageData    = The object passed in to Write-Info
            $Message        = A string representation of the $MessageData
            $Time           = The current Time (the TimeOfDay from a DateTime)
            $Elapsed        = The elapsed time on the TraceInformation stopwatch

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
            Set-InfoTemplate '${Elapsed} ${ScriptName}:${LineNumber} ${Message}'

            Sets the TraceInformation template to a simple message showing elapsed time, the source, and the message
        .Example
            Set-InfoTemplate '${Elapsed}$("  " * ${CallStackDepth})${Message} <${Command}> ${ScriptName}:${LineNumber}'

            Sets a template that includes indenting based on $CallStackDepth
        .Example
            Set-InfoTemplate '$("{0:mm\:ss\.fff}" -f ${Elapsed})$(" " * ${CallStackDepth})${Message} <${Command}> ${ScriptName}:${LineNumber}'

            Sets a template which applies formatting to the elapsed time, to shorten it.
        .Example
            Set-InfoTemplate '$e[38;5;1m${Elapsed}$("  " * ${CallStackDepth})$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'

            Sets a template with ANSI escape sequences for color and indenting based on $CallStackDepth
        .Example
            Set-InfoTemplate '${Env:UserName}@${Env:ComputerName} $e[38;5;1m$("{0:hh\:mm\:ss\.fff}" -f ${Time}) $("  " * ${CallStackDepth})$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'

            Sets a template which includes the user and computer name, as well as using the actual time -- useful for logging across remote jobs.
    #>
    [CmdletBinding()]param(
        # The string template for help
        $Template
    )

    [TraceInformation]::InfoTemplate = $Template
}