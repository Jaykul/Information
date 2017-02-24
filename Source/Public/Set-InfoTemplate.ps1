function Set-InfoTemplate {
    <#
        .Synopsis
            Sets the template string used for trace messages
        .Description
            Allows setting the template string to format the trace messages.
            You should use single quoted strings with variable names in braces like ${Message}
            The following variables are available in Write-Info:

            ${Message}           = A string representation of the $MessageData
            ${GeneratedDateTime} = A full DateTimeOffset for when this record was generated
            ${ClockTime}         = The TimeOfDay from the DateTimeOffset (A TimeSpan representing when the record was generated)
            ${ElapsedTime}       = The elapsed time since the Information.InformationMessage::StartTime

            The three time based fields support formatting by placing it after the field, like: ${ClockTime:hh:mm}

            Additionally, there are several variables from the last frame of the call stack:

            ${Indent}         = A series of spaces based on the depth of the callstack (for indenting)
            ${Command}        = The command that was run to invoke the current code (i.e. the last command in the call stack)
            ${FunctionName}   = The name of the function (if any) containing the current code (might just be <ScriptBlock> to indicate no function)
            ${ScriptPath}     = The full path for the running script file
            ${ScriptName}     = The name of the running script file
            ${LineNumber}     = The line number of the script file
            ${Location}       = A pre-formatted Location string

            ${e}              = The escape character ([char]27) for ANSI. YOu can also use `e or $e

            And finally, you can use Environment variables like ${Env:ComputerName}

        .Example
            Set-InfoTemplate '${ElapsedTime} ${ScriptName}:${LineNumber} ${Message}'

            Sets the Information.InformationMessage template to a simple message showing elapsed time, the source, and the message
        .Example
            Set-InfoTemplate '${ElapsedTime}${Indent}${Message} <${Command}> ${ScriptName}:${LineNumber}'

            Sets a template that includes indenting based on $CallStackDepth
        .Example
            Set-InfoTemplate '${ElapsedTime::mm:ss.fff}${Indent}${Message} <${Command}> ${ScriptName}:${LineNumber}'

            Sets a template which applies formatting to the elapsed time, to shorten it.
        .Example
            Set-InfoTemplate '$e[38;5;1m${ElapsedTime}${Indent}$e[38;5;6m${Message} $e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}$e[39m'

            Sets a template with ANSI escape sequences for color and indenting based on $CallStackDepth
        .Example
            Set-InfoTemplate '${Env:UserName}@${Env:ComputerName} `e[38;5;1m${ClockTime::mm:ss.fff} ${Indent}`e[38;5;6m${Message} `e[38;5;5m<${Command}> ${ScriptName}:${LineNumber}`e[39m'

            Sets a template which includes the user and computer name, as well as using the actual time -- useful for logging across remote jobs.
    #>
    [CmdletBinding()]param(
        # The string template for help
        $Template
    )

    [Information.InformationMessage]::InfoTemplate = $Template
}