class InformationMessageConverter : System.Management.Automation.PSTypeConverter
{
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType)
    {
        Write-Warning "CanConvertFrom $($psSourceValue.PSTypeNames)"
        return $psSourceValue.PSTypeNames.Contains("Deserialized.Information.InformationMessage")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        Write-Warning "ConvertFrom $($psSourceValue.PSTypeNames)"
        $Properties = @{}
        if($psSourceValue.TimeGenerated -as [DateTimeOffset]) { $Properties.TimeGenerated = $psSourceValue.TimeGenerated -as [DateTimeOffset] }
        # if($psSourceValue.FunctionName-as [string]) { $Properties.FunctionName = $psSourceValue.FunctionName-as [string] }
        # if($psSourceValue.ScriptPath-as [string]) { $Properties.ScriptPath = $psSourceValue.ScriptPath-as [string] }
        # if($psSourceValue.LineNumber-as [int]) { $Properties.LineNumber = $psSourceValue.LineNumber-as [int] }
        # if($psSourceValue.Command-as [string]) { $Properties.Command = $psSourceValue.Command-as [string] }
        # if($psSourceValue.Location-as [PSObject]) { $Properties.Location = $psSourceValue.Location-as [PSObject] }
        # if($psSourceValue.ScriptName-as [string]) { $Properties.ScriptName = $psSourceValue.ScriptName-as [string] }
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