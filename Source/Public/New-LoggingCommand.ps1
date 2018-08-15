function New-LoggingCommand {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.CommandInfo]
        $Command
    )
    begin {
        $ProxyFactory = [System.Management.Automation.ProxyCommand]
    }
    process {
        $CommandName = $Command.Name
        if ($Command.Verb -and $Command.Noun) {
            $WrapperName = $Command.Verb + "-Info" + $Command.Noun
            Set-Alias $Command.Name $WrapperName -Scope Global -Verbose:$Verbose
            if ($Command.ModuleName) {
                Set-Alias "$($Command.ModuleName)\$($Command.Name)" $WrapperName -Scope Global -Verbose:$Verbose
            }
        } else {
            $WrapperName = "Info" + $Command.Name
            Set-Alias $Command.Name $WrapperName -Scope Global
            if ($Command.ModuleName) {
                Set-Alias "$($Command.ModuleName)\$($Command.Name)" $WrapperName -Scope Global
            }
        }

        $CmdletBindingAttribute = $ProxyFactory::GetCmdletBindingAttribute($Command)
        $ParamBlock = $ProxyFactory::GetParamBlock($Command)
        $Begin = $ProxyFactory::GetBegin($Command)
        $Process = $ProxyFactory::GetProcess($Command)
        $End = $ProxyFactory::GetEnd($Command)

        if($DynamicParam = $ProxyFactory::GetDynamicParam($Command)) {
            $DynamicParam = "dynamicparam {`n$DynamicParam}" -replace "\s*\|\s*Microsoft\.PowerShell\.Core\\Where-Object\s*{", ".Where{"
        }

Invoke-Expression @"
function global:$WrapperName {
$CmdletBindingAttribute
param(
    $ParamBlock
)
$DynamicParam
begin {
    Write-Info "BEGIN $CommandName"
    $Begin
}
process {
    Write-Info "PROCESS $CommandName"
    $Process
}
end {
    Write-Info "END $CommandName"
    $End
}
<#
    .ForwardHelpTargetName $($Command.ModuleName)\$CommandName
    .ForwardHelpCategory $($Command.Commandtime)
#>
}
"@
    }
}
