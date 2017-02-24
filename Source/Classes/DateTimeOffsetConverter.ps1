class DateTimeOffsetConverter : System.Management.Automation.PSTypeConverter
{
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    # These methods aren't necessary...
    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.DateTimeOffset") -and $destinationType -eq "System.DateTimeOffset"
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }
}

Update-TypeData -TypeName 'Deserialized.System.DateTimeOffset' -TargetTypeForDeserialization 'System.DateTimeOffset' -Force
Update-TypeData -TypeName 'System.DateTimeOffset' -TypeConverter 'DateTimeOffsetConverter' -SerializationDepth 1 -Force