class InformationMessageConverter : System.Management.Automation.PSTypeConverter
{
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        # Write-Warning "CanConvertFrom $($psSourceValue.PSTypeNames)"
        return $psSourceValue.PSTypeNames.Contains("Deserialized.Information.InformationMessage")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        # Write-Warning "ConvertFrom $($psSourceValue.PSTypeNames)"
        $Properties = @{}
        if($psSourceValue.GeneratedDateTime -as [DateTimeOffset]) { $Properties.GeneratedDateTime = $psSourceValue.GeneratedDateTime -as [DateTimeOffset] }
        if($psSourceValue.ElapsedTime -as [TimeSpan]) { $Properties.ElapsedTime = $psSourceValue.ElapsedTime -as [TimeSpan] }
        if($psSourceValue.PSComputerName -as [string]) { $Properties.PSComputerName = $psSourceValue.PSComputerName -as [string] }
        if($psSourceValue.ShowException -as [bool]) { $Properties.ShowException = $psSourceValue.ShowException -as [bool] }
        if($psSourceValue.Prefix -as [string]) { $Properties.Prefix = $psSourceValue.Prefix -as [string] }

        return New-Object Information.InformationMessage ($psSourceValue.MessageData, $psSourceValue.CallStack) -Property $Properties
    }

    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType)
    {
        return $false;
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        throw [NotImplementedException]::new();
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType)
    {
        throw [NotImplementedException]::new();
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        throw [NotImplementedException]::new();
    }
}

Update-TypeData -TypeName 'Deserialized.Information.InformationMessage' -TargetTypeForDeserialization 'InformationMessageConverter' -Force
Update-TypeData -TypeName 'InformationMessageConverter' -TypeConverter 'InformationMessageConverter' -SerializationDepth 3 -Force
Update-TypeData -TypeName 'Information.InformationMessage' -SerializationDepth 4 -Force