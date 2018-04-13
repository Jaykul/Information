Add-Type @'
public class ExtensibleConverter<T> : System.Management.Automation.PSTypeConverter
{
    public static System.Collections.Generic.Dictionary<(Type From, Type To),ScriptBlock[]> Converters;

    bool CanConvertFrom(PSObject psSourceValue, Type destinationType)
    {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    object ConvertFrom(PSObject psSourceValue, Type destinationType, IFormatProvider formatProvider, bool ignoreCase)
    {
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    # These methods aren't necessary...
    [bool] CanConvertFrom([object]$o, [Type]$t) { return $false; }
    [object] ConvertFrom([object]$o, [Type]$t, [IFormatProvider]$f, [bool]$i) { throw [NotImplementedException]::new() }
    [bool] CanConvertTo([object]$o, [Type]$t) { throw [NotImplementedException]::new() }
    [object] ConvertTo([object]$o, [Type]$t, [IFormatProvider]$f, [bool]$i) { throw [NotImplementedException]::new() }
}
'@


Update-TypeData -TypeName 'Deserialized.System.DateTimeOffset' -TargetTypeForDeserialization 'System.DateTimeOffset' -Force
# Update-TypeData -TypeName 'System.DateTimeOffset' -TypeConverter 'DateTimeOffsetDeserializer' -SerializationDepth 1 -Force

class DateTimeOffsetFromString : DateTimeOffsetDeserializer {

    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.DateTimeOffset") -or $psSourceValue.PSTypeNames.Contains("System.String")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        if($psSourceValue -is [string]) {
            if ($psSourceValue -match "(?:(?<day>-?\d+)D|(?<hr>-?\d+)H|(?<min>-?\d+)M| ){1,3}") {
                return [DateTimeOffset]::Now.AddDays([int]$matches["day"]).AddHours([int]$matches["hr"]).AddMinutes([int]$matches["min"])
            }
        }
        return ([DateTimeOffsetDeserializer]$this).ConvertFrom($psSourceValue, $destinationType, $formatProvider, $ignoreCase)
    }
}

Update-TypeData -TypeName 'System.DateTimeOffset' -TypeConverter 'DateTimeOffsetFromString' -SerializationDepth 1 -Force
