# WARNING: THIS PSM1 FILE IS REPLACED DURING BUILD
using namespace System.Management.Automation

[String[]]$DebugFilterInclude = @()
[String[]]$DebugFilterExclude = @()

class DateTimeOffsetConverter : System.Management.Automation.PSTypeConverter {
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType) {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    # These methods aren't necessary...
    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType) {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.DateTimeOffset")
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType) {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.DateTimeOffset") -and $destinationType -eq "System.DateTimeOffset"
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        [PSObject]$psSourceValue = $sourceValue
        return [DateTimeOffset]::new($psSourceValue.Ticks, $psSourceValue.Offset)
    }
}

Update-TypeData -TypeName 'Deserialized.System.DateTimeOffset' -TargetTypeForDeserialization 'System.DateTimeOffset' -Force
Update-TypeData -TypeName 'System.DateTimeOffset' -TypeConverter 'DateTimeOffsetConverter' -SerializationDepth 1 -Force

Add-Type -Path $PSScriptRoot\Classes\*.cs

class InformationMessageConverter : System.Management.Automation.PSTypeConverter {
    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType) {
        # Write-Warning "CanConvertFrom $($psSourceValue.PSTypeNames)"
        return $psSourceValue.PSTypeNames.Contains("Deserialized.Information.InformationMessage")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        # Write-Warning "ConvertFrom $($psSourceValue.PSTypeNames)"
        $Properties = @{}
        if ($psSourceValue.GeneratedDateTime -as [DateTimeOffset]) {
            $Properties.GeneratedDateTime = $psSourceValue.GeneratedDateTime -as [DateTimeOffset]
        }
        if ($psSourceValue.ElapsedTime -as [TimeSpan]) {
            $Properties.ElapsedTime = $psSourceValue.ElapsedTime -as [TimeSpan]
        }
        if ($psSourceValue.PSComputerName -as [string]) {
            $Properties.PSComputerName = $psSourceValue.PSComputerName -as [string]
        }
        if ($psSourceValue.ShowException -as [bool]) {
            $Properties.ShowException = $psSourceValue.ShowException -as [bool]
        }
        if ($psSourceValue.Prefix -as [string]) {
            $Properties.Prefix = $psSourceValue.Prefix -as [string]
        }

        return New-Object Information.InformationMessage ($psSourceValue.MessageData, $psSourceValue.CallStack) -Property $Properties
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

Update-TypeData -TypeName 'Deserialized.Information.InformationMessage' -TargetTypeForDeserialization 'InformationMessageConverter' -Force
Update-TypeData -TypeName 'InformationMessageConverter' -TypeConverter 'InformationMessageConverter' -SerializationDepth 3 -Force
Update-TypeData -TypeName 'Information.InformationMessage' -SerializationDepth 4 -Force

class InformationRecordConverter : System.Management.Automation.PSTypeConverter {
    $InformationMessageConverter = [InformationMessageConverter]::new()

    [bool] CanConvertFrom([PSObject]$psSourceValue, [Type]$destinationType) {
        return $psSourceValue.PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
        $psSourceValue.MessageData.PSTypeNames.Contains("Deserialized.Information.InformationMessage")
    }

    [object] ConvertFrom([PSObject]$psSourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }


    [bool] CanConvertFrom([object]$sourceValue, [Type]$destinationType) {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
        ([PSObject]$sourceValue).MessageData.PSTypeNames.Contains("Deserialized.Information.InformationMessage") -and
        $destinationType -eq "System.Management.Automation.InformationRecord"
    }

    [object] ConvertFrom([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        [PSObject]$psSourceValue = $sourceValue

        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }

    [bool] CanConvertTo([object]$sourceValue, [Type]$destinationType) {
        return ([PSObject]$sourceValue).PSTypeNames.Contains("Deserialized.System.Management.Automation.InformationRecord") -and
        ([PSObject]$sourceValue).MessageData.PSTypeNames.Contains("Deserialized.Information.InformationMessage") -and
        $destinationType -eq "System.Management.Automation.InformationRecord"
    }

    [object] ConvertTo([object]$sourceValue, [Type]$destinationType, [IFormatProvider]$formatProvider, [bool]$ignoreCase) {
        [PSObject]$psSourceValue = $sourceValue

        $MessageData = $this.InformationMessageConverter.ConvertFrom( $psSourceValue.MessageData, $null, $null, $true)
        return [System.Management.Automation.InformationRecord]::new($MessageData, $MessageData.CallStack)
    }
}

Update-TypeData -TypeName 'Deserialized.System.Management.Automation.InformationRecord' -TargetTypeForDeserialization 'System.Management.Automation.InformationRecord' -Force
Update-TypeData -TypeName 'System.Management.Automation.InformationRecord' -TypeConverter 'InformationRecordConverter' -SerializationDepth 6 -Force

class TraceInformation {
    [String]$Message

    [Hashtable]$BoundParameters

    TraceInformation([string]$Message, [Hashtable]$BoundParameters) {
        $this.Message = $Message
        $this.BoundParameters = $BoundParameters
    }

    [string] ToString() {
        return $this.Message + " " + $($(
                foreach ($param in $this.BoundParameters.GetEnumerator()) {
                    "-{0}:{1}" -f $param.Key, $($param.Value -join ", ")
                }
            ) -join " ")
    }
}


# dot source the functions
(Join-Path $PSScriptRoot Private\*.ps1 -Resolve -ErrorAction SilentlyContinue).ForEach{ . $_ }
(Join-Path $PSScriptRoot Public\*.ps1 -Resolve).ForEach{ . $_ }

Export-ModuleMember -Function * -Variable DebugFilterInclude, DebugFilterExclude