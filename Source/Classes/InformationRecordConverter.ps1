class InformationRecordConverter : System.Management.Automation.PSTypeConverter
{
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.c") -or
               $psSourceValue.PSTypeNames.Contains("Deserialized.Information.InvocationRecord")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        if ($destinationType -eq [Information.InvocationRecord]) {
            $record = [Information.InvocationRecord]::new($psSourceValue.MessageData, $psSourceValue.Invocation, $psSourceValue.Tags)
            $record.TimeGenerated = $psSourceValue.TimeGenerated -as [DateTimeOffset]
        } else {
            $record = [System.Management.Automation.InformationRecord]::new($psSourceValue.MessageData, $psSourceValue.Source)
            $record.TimeGenerated = $psSourceValue.TimeGenerated
            $record.Tags.AddRange($psSourceValue.Tags)
        }
        return $record
    }

    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType) {
        return $false;
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        throw [NotImplementedException]::new();
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType) {
        throw [NotImplementedException]::new();
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        throw [NotImplementedException]::new();
    }
}

Update-TypeData -TypeName 'Deserialized.System.Management.Automation.InformationRecord' -TargetTypeForDeserialization 'System.Management.Automation.InformationRecord' -Force
Update-TypeData -TypeName 'Deserialized.Information.InvocationRecord' -TargetTypeForDeserialization 'Information.InvocationRecord' -Force
Update-TypeData -TypeName 'System.Management.Automation.InformationRecord' -TypeConverter 'InformationRecordConverter' -SerializationDepth 6 -Force
Update-TypeData -TypeName 'Information.InvocationRecord' -TypeConverter 'InformationRecordConverter' -SerializationDepth 6 -Force
