---
external help file: Information-help.xml
online version:
schema: 2.0.0
---

# Write-ErrorInfo

## SYNOPSIS

Write an ErrorRecord or Exception to the information stream.

## SYNTAX

```posh
Write-ErrorInfo [[-ErrorRecord] <Object>] [[-Prefix] <String>] [-WriteError] [-Simple] [-Passthru]
```

## DESCRIPTION

Writes the detailed trace of the ErrorRecord to the Information stream, optionally echoing it to the Error stream.

## EXAMPLES

### Example 1

```posh

```

## PARAMETERS

### -ErrorRecord

The Error or Exception to write out

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Passthru

If set, pass the ErrorRecord through as output

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prefix

Specify a prefix to use on the string message instead of the default error/exception prefix.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Simple

If set, skip unrolling the Exception and InnerException into the message text

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WriteError

If set, write the ErrorRecord to the Error stream

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### System.Management.Automation.ErrorRecord

### System.Exception


## OUTPUTS

### System.Management.Automation.ErrorRecord

### System.Exception

## NOTES

## RELATED LINKS

