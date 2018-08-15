function Set-InfoTemplate {
    <#
        .Synopsis
            Sets the template string used for trace messages
        .Description
            Allows setting the template string to format the trace messages.
            You use {placeholders} for properties of the object, and a few of them support formatting.
            The following placeholders are available:

            {Message}  = A string representation of the $MessageData
            {Computer} = The name of the computer where the information message was generated
            {User}     = The name of the user account the script was running in

            The following three time based fields support formatting by placing it after the field, like: {ClockTime:hh:mm}

            {TimeGenerated}  = A full DateTimeOffset for when this record was generated
            {ClockTime}      = The TimeOfDay from the DateTimeOffset (A TimeSpan representing when the record was generated)
            {ElapsedTime}    = The elapsed time since the [Information.InformationFormatter]::StartTime

            Additionally, there are several variables from the InvocationInfo of the command:

            {Command}          = The command that created the message (nearly always Write-Info, but could be anything if they construct the InvocationMessage)
            {CommandName}      = The name of the function (if any) containing the current code (might just be <ScriptBlock> to indicate no function)
            {PSCommandPath}    = The full path for the running script file
            {ScriptName}       = The name of the running script file
            {ScriptLineNumber} = The line number of the script file
            {Position}         = The line and character information (the first line of the posistion message
            {PositionMessage}  = The pre-formatted PositionMessage incluldes the line information and the actual line

            `e                 = The escape character ([char]27) for ANSI

        .Example
            Set-InfoTemplate '{ElapsedTime} {ScriptName}:{ScriptLineNumber} {Message}'

            Sets the InformationRecord template to a simple message showing elapsed time, the source, and the message
        .Example
            Set-InfoTemplate '{ElapsedTime:mm:ss.fff} {Message} <{Command}> {ScriptName}:{ScriptLineNumber}'

            Sets a template which applies formatting to the elapsed time, to shorten it.
        .Example
            Set-InfoTemplate '`e[38;5;1m{ElapsedTime} `e[38;5;6m{Message} `e[38;5;5m<{Command}> {ScriptName}:{LineNumber}`e[39m'

            Sets a template with ANSI escape sequences for color
        .Example
            Set-InfoTemplate '{User}@{Computer} `e[38;5;1m{ClockTime:mm:ss.fff} `e[38;5;6m{Message} `e[38;5;5m<{Command}> {ScriptName}:{ScriptLineNumber}`e[39m'

            Sets a template which includes the user and computer name, as well as using the actual time -- useful for logging across remote jobs.
    #>
    [CmdletBinding()]param(
        # The string template for help
        $Template
    )

    [Information.InformationHelper]::InfoTemplate = $Template
}