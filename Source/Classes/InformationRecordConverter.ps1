class InformationRecordConverter : System.Management.Automation.PSTypeConverter
{
    $InformationMessageConverter = [InformationMessageConverter]::new()

    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
               $psSourceValue.MessageData.TypeNames.Contains("Deserialized.Information.InformationMessage")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }


    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
               ([PSObject]$sourceValue).MessageData.TypeNames.Contains("Deserialized.Information.InformationMessage")-and
               $destinationType -eq "System.Management.Automation.InformationRecord"
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue

        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
               ([PSObject]$sourceValue).MessageData.TypeNames.Contains("Deserialized.Information.InformationMessage") -and
               $destinationType -eq "System.Management.Automation.InformationRecord"
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue

        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }
}

Update-TypeData -TypeName 'Deserialized.System.Management.Automation.InformationRecord' -TargetTypeForDeserialization 'System.Management.Automation.InformationRecord' -Force
Update-TypeData -TypeName 'System.Management.Automation.InformationRecord' -TypeConverter 'InformationRecordConverter' -SerializationDepth 6 -Force
