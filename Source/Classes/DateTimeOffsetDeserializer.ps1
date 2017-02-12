class DateTimeOffsetDeserializer : System.Management.Automation.PSTypeConverter {

    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).TypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).TypeNames.Contains("Deserialized.System.DateTimeOffset") -and $destinationType -eq "System.DateTimeOffset"
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }
}
Update-TypeData -TypeName DateTimeOffset -TargetTypeForDeserialization DateTimeOffsetDeserializer -Force