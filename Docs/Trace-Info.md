---
external help file: Information-help.xml
online version: 
schema: 2.0.0
---

# Trace-Info

## SYNOPSIS
Invoke a command and collect the trace (Information) output and store it to file

## SYNTAX

```
Trace-Info [[-Command] <Object>] [[-LogPath] <String>] [[-DebugFilterInclude] <String[]>]
 [[-DebugFilterExclude] <String[]>] [-CatchException] [-Passthru]
```

## DESCRIPTION
Wraps invocation of a command with exception handling and logging.
Guarantees exceptions will be fully captured and logged.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$Examples = Join-Path (Get-Module Information).ModuleBase Examples
```

C:\PS\> Trace-Info -Command "$Examples\TraceException.ps1" -Log "$Examples\TraceException.log.clixml"
C:\PS\> $Log = Import-CliXml "$Examples\TraceException.log.clixml"
C:\PS\>

Shows how to invoke the TraceException example script, log it, and filter the collected log for exceptions

## PARAMETERS

### -Command
The command or script path to execute

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

### -LogPath
The path to log to

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DebugFilterInclude
A collection of tags to include in debug output
If set, automatically causes Write-Info output to be copied to the Debug stream

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DebugFilterExclude
A collection of tags to exclute from the debug output
If set, automatically causes Write-Info output to be copied to the Debug stream
If DebugFilterInclude is not set, everything except these tags is copied

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CatchException
{{Fill CatchException Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru
{{Fill Passthru Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

