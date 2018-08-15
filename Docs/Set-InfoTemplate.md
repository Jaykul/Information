---
external help file: Information-help.xml
online version:
schema: 2.0.0
---

# Set-InfoTemplate

## SYNOPSIS

Sets the template string used for trace messages

## SYNTAX

```posh
Set-InfoTemplate [[-Template] <Object>]
```

## DESCRIPTION

Allows setting the template string to format the trace messages.
You use {placeholders} for properties of the object, and a few of them support formatting.
The following placeholders are available:

{Message}           = A string representation of the $MessageData
{GeneratedDateTime} = A full DateTimeOffset for when this record was generated
{ClockTime}         = The TimeOfDay from the DateTimeOffset (A TimeSpan representing when the record was generated)
{ElapsedTime}       = The elapsed time since the start of the pipeline

The three time based fields support formatting by placing it after the field, like: {ClockTime:hh:mm}

Additionally, there are several variables from the last frame of the call stack:

{Indent}         = A series of spaces based on the depth of the callstack (for indenting)
{Command}        = The command that was run to invoke the current code (i.e.
the last command in the call stack)
{FunctionName}   = The name of the function (if any) containing the current code (might just be \<ScriptBlock\> to indicate no function)
{ScriptPath}     = The full path for the running script file
{ScriptName}     = The name of the running script file
{LineNumber}     = The line number of the script file
{Location}       = A pre-formatted Location string
{PSComputerName} = The computer that generated the original InformationRecord

\`e               = The escape character (\[char\]27) for ANSI

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```posh
Set-InfoTemplate '{ElapsedTime} {ScriptName}:{LineNumber} {Message}'
```

Sets the Information.InformationRecord template to a simple message showing elapsed time, the source, and the message

### -------------------------- EXAMPLE 2 --------------------------

```posh
Set-InfoTemplate '{ElapsedTime}{Indent}{Message} <{Command}> {ScriptName}:{LineNumber}'
```

Sets a template that includes indenting based on the size of the CallStack

### -------------------------- EXAMPLE 3 --------------------------

```posh
Set-InfoTemplate '{ElapsedTime:mm:ss.fff}{Indent}{Message} <{Command}> {ScriptName}:{LineNumber}'
```

Sets a template which applies formatting to the elapsed time, to shorten it.

### -------------------------- EXAMPLE 4 --------------------------

```posh
Set-InfoTemplate '`e[38;5;1m{ElapsedTime}{Indent}`e[38;5;6m{Message} `e[38;5;5m<{Command}> {ScriptName}:{LineNumber}`e[39m'
```

Sets a template with ANSI escape sequences for color and indenting based on $CallStackDepth

### -------------------------- EXAMPLE 5 --------------------------

```posh
Set-InfoTemplate '{PSComputerName} `e[38;5;1m{ClockTime::mm:ss.fff} {Indent}`e[38;5;6m{Message} `e[38;5;5m<{Command}> {ScriptName}:{LineNumber}`e[39m'
```

Sets a template which includes the computer name, as well as using the actual time -- useful for logging across remote jobs.

## PARAMETERS

### -Template

The string template for help

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

