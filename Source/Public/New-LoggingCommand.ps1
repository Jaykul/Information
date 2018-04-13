function New-LoggingCommand {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.CommandInfo]
        $Command
    )
    begin {
        $ProxyFactory = [System.Management.Automation.ProxyCommand]
    <#
        class TraceInformation {
            [String]$Message

            [Hashtable]$BoundParameters

            TraceInformation([string]$Message, [Hashtable]$BoundParameters) {
                $this.Message = $Message
                $this.BoundParameters = $BoundParameters
            }

            [string] ToString() {
                return $this.Message + " " + $($(
                    foreach($param in $this.BoundParameters.GetEnumerator()) {
                        "-{0}:{1}" -f $param.Key, $($param.Value -join ", ")
                    }
                ) -join " ")
            }
        }
    #>
    }

    process {
        $CommandName = $Command.Name
        if ($Command.Verb -and $Command.Noun) {
            $WrapperName = $Command.Verb + "-Info" + $Command.Noun
            Set-Alias $Command.Name $WrapperName -Scope Global
            if ($Command.ModuleName) {
                Set-Alias "$($Command.ModuleName)\$($Command.Name)" $WrapperName -Scope Global
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
        if($Help = $Command | Get-Help) {
            $HelpComments = $ProxyFactory::GetHelpComments(@($Help)[0])
        }

Invoke-Expression @"
function global:$WrapperName {
$CmdletBindingAttribute
param(
    $ParamBlock
)
$DynamicParam
begin {
    # [TraceInformation]::new("BEGIN $CommandName", `$PSBoundParameters) | Write-Info -Tag Trace, Enter, Begin
    Write-Info "BEGIN $CommandName"
    $Begin
}
process {
    # [TraceInformation]::new("PROCESS $CommandName", `$PSBoundParameters) | Write-Info -Tag Trace, Enter, Process
    Write-Info "PROCESS $CommandName"
    $Process
}
end {
    # [TraceInformation]::new("END $CommandName", `$PSBoundParameters) | Write-Info -Tag Trace, Leave, End
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