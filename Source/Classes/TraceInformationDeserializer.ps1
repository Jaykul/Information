class TraceInformationDeserializer : System.Management.Automation.PSTypeConverter {

    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).TypeNames.Contains("Deserialized.TraceInformation")
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType)
    {
        return ([PSObject]$sourceValue).TypeNames.Contains("Deserialized.TraceInformation") -and $destinationType -eq "TraceInformation"
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return New-Object TraceInformation ($psSourceValue.MessageData, $psSourceValue.CallStack) -Property @{
            TimeGenerated = $psSourceValue.TimeGenerated
            ElapsedTime = $psSourceValue.ElapsedTime
            Time = $psSourceValue.Time
            Message = $psSourceValue.Message
            FunctionName = $psSourceValue.FunctionName
            ScriptPath = $psSourceValue.ScriptPath
            LineNumber = $psSourceValue.LineNumber
            Command = $psSourceValue.Command
            Location = $psSourceValue.Location
            Arguments = $psSourceValue.Arguments
            ScriptName = $psSourceValue.ScriptName
            CallStackDepth = $psSourceValue.CallStackDepth
        }
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase)
    {
        [PSObject]$psSourceValue = $sourceValue
        return New-Object TraceInformation ($psSourceValue.MessageData, $psSourceValue.CallStack) -Property @{
            TimeGenerated = $psSourceValue.TimeGenerated
            ElapsedTime = $psSourceValue.ElapsedTime
            Time = $psSourceValue.Time
            Message = $psSourceValue.Message
            FunctionName = $psSourceValue.FunctionName
            ScriptPath = $psSourceValue.ScriptPath
            LineNumber = $psSourceValue.LineNumber
            Command = $psSourceValue.Command
            Location = $psSourceValue.Location
            Arguments = $psSourceValue.Arguments
            ScriptName = $psSourceValue.ScriptName
        }
    }
}
Update-TypeData -TypeName TraceInformation -TargetTypeForDeserialization TraceInformationDeserializer -Force