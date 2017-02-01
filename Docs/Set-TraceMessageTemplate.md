---
external help file: Information-help.xml
online version: 1.0.0
schema: 2.0.0
---

# Set-TraceMessageTemplate

## SYNOPSIS
Sets the template string used for trace messages

## SYNTAX

```
Set-TraceMessageTemplate [[-Template] <Object>]
```

## DESCRIPTION

Allows setting the template string to format the trace messages.
You should use single quoted strings, with variables embedded in them.
The following variables are available in Write-Trace:


Variable            | Meaning
--------            | --------
`${MessageData}`    | The object passed in to Write-Trace
`${Message}`        | A string representation of the $MessageData
`${Time}`           | The current Time (the TimeOfDay from a DateTime)
`${Elapsed}`        | The elapsed time on the TraceMessage stopwatch
 | **Additionally, there are several variables from the last frame of the call stack:**
`${CallStackDepth}` | The depth of the callstack (useful for indeting)
`${Command}`        | The command that was run to invoke the current code (i.e. the last command in the call stack)
`${FunctionName}`   | The name of the function (if any) containing the current code (might just be \<ScriptBlock\> to indicate no function)
`${ScriptPath}`     | The full path for the running script file
`${ScriptName}`     | The name of the running script file
`${LineNumber}`     | The line number of the script file
`${Location}`       | A pre-formatted Location string
`${Arguments}`      | A string representation of the arguments passed to the executing code
`${e}`              | The escape character (\[char\]27) for ANSI

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Set-TraceMessageTemplate '${Elapsed} ${ScriptName}:${LineNumber} ${Message}'
```

Sets the TraceMessage template to a simple message showing elapsed time, the source, and the message

### -------------------------- EXAMPLE 2 --------------------------
```
${ScriptName}:${LineNumber}'
```

Sets the TraceMessage to a template that includes indenting based on $CallStackDepth

### -------------------------- EXAMPLE 3 --------------------------
```
${ScriptName}:${LineNumber}$e[39m'
```

Sets the TraceMessage to a nice template with ANSI escape sequences for color and indenting based on $CallStackDepth

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

