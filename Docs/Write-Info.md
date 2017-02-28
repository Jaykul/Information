---
external help file: Information-help.xml
online version:
schema: 2.0.0
---

# Write-Info

## SYNOPSIS

An enhancement to the built-in Write-Information to make it show the calling script line, etc.

## SYNTAX

```posh
Write-Info [-MessageData] <PSObject> [-Tags <String[]>] [-StartTime <DateTimeOffset>]
```

## DESCRIPTION

Writes messages to the Information stream with callstack and tags, optionally echoing to the debug stream. Messages echoed to the debug stream are only written when debugging is enabled (so that they would be visible) and can be filtered by tags using module preference variables: `$DebugFilterInclude` and/or `$DebugFilterExclude`.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```posh
Write-Info "Enter Get-MyFunctionName"
```

Writes a message to the information stream

### -------------------------- EXAMPLE 2 --------------------------

```posh
function Test-Information {
    [CmdletBinding()]
    param($Name, $Age)

    Write-Info 'Enter Test-Information' -Tag 'Trace','Enter'

    # do stuff

    Write-Info 'Exit Test-Information' -Tag 'Trace','Exit'
}

Test-Information -InformationVariable Log
$Log | Where Tags -match Enter | % { $_.MessageData.CallStack }
```

Writes enter and exit messages to the information stream, and shows how to collect that using the `-InformationVariable` and filter it based on the tags.

### -------------------------- EXAMPLE 3 --------------------------

```posh
Write-Info (Get-ChildItem) -InformationVariable Log

$Log.MessageData.MessageData
```

Writes an array of files to the information stream, collects that stream in the `$Log` variable, and then fetches them out to display them.
Note that if we turned on `-InformationAction Continue` they would render as just their names, but the serialized FileInfo is available in the MessageData.

## PARAMETERS

### -MessageData

Specifies an informational message that you want to display to users as they run a script or command.
Note that this is a rich object, and the -InformationVariable can collect those objects, but the host output will be a string rendering.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: Object

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Tags

Specifies a collection of text tags that can be used to sort and filter messages that you have added to the information stream

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

Supports passing in the DateTimeOffset so you that the ElapsedTime can be calculated correctly across scripts

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

### System.Object

## OUTPUTS

## NOTES

## RELATED LINKS

### Write-ErrorInfo

### Trace-Info

### Set-InfoTemplate