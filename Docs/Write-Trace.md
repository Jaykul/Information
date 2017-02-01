---
external help file: Information-help.xml
online version: 1.0.0
schema: 2.0.0
---

# Write-Trace

## SYNOPSIS
An enhancement to the built-in Write-Information to make it show the calling script line

## SYNTAX

```
Write-Trace [-MessageData] <PSObject> [-Tags <String[]>] [-StartTime <DateTimeOffset>]
```

## DESCRIPTION
Writes messages to the Information stream with callstack and tags, optionally echoing to the debug stream.
Messages are formatted using the MessageTemplate (a static property on [TraceMessage]), which is settable by Set-TraceMessageTemplate.
Additionally, messages echoed to the debug stream are only written when debugging is enabled (so they'll be visible) and can be filtered by tags.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Write-Trace "Enter Get-MyFunctionName"
```

Writes a message to the information stream

### -------------------------- EXAMPLE 2 --------------------------
```
function Test-Information {
    [CmdletBinding()]
    param($Name, $Age)

    Write-Trace 'Enter Test-Information' -Tag 'Trace','Enter'

    # do stuff

    Write-Trace 'Exit Test-Information' -Tag 'Trace','Exit'
}

$InformationTracePreference = "CallStack"
Test-Information -InformationVariable Log
$Log | Where Tags -match Enter | % { $_.MessageData.CallStack }
```

Writes enter and exit messages to the information stream using the TracePreference variables to add CallStack information, and shows how to filter and show that data

### -------------------------- EXAMPLE 3 --------------------------
```
$InformationDebugEcho = $true
Test-Information -Debug
```

Using the same Test-Information from the Example 2, this exameple doesn't includ CallStack information, but uses the `$InformationDebugEcho` and the `-Debug` switch trigger the information stream to be echoed to Debug, and printed with source and timestamp information.

## PARAMETERS

### -MessageData
Specifies an informational message that you want to display to users as they run a script or command.
Note that this is a rich object, and the `-InformationVariable` can collect those objects, but the stream will just get the ToString()

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Tags
Specifies a simple string that you can use to sort and filter messages that you have added to the information stream with Write-Information, Write-Trace, or Write-Host

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
Supports passing in a StartTime offset so you can correlate logs output across different servers or jobs, even when using elapsed time.

```yaml
Type: DateTimeOffset
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

A string message or object to write to the information stream

## OUTPUTS

[TraceMessage] objects to the information stream

## NOTES

Uses preference variables: InformationPreference, DebugPreference, and new preference variables DebugFilterInclude and DebugFilterExclude which are used to limit debug output.

## RELATED LINKS

Set-TraceMessageTemplate