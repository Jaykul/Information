function Trace-Information {
    <#
        .Synopsis
            Run a script with extra trace output from the Information stream
        .Description
            Turns on the $InformationTracePreference to include the callstack with each output, and runs the ScriptBlock.
            If the Verbose switch is specified, also forces all Write-Information calls to output to VerboseOutput

            Then, collects InformationOutput into the Log Variable for further investigation.
        .Link
            Format-Information
    #>
    [CmdletBinding()]
    param(
        # The ScriptBlock to trace Information messages from
        [Parameter(Mandatory,Position=0)]
        [ScriptBlock]$ScriptBlock,

        [string[]]$DebugFilterInclude,

        [string[]]$DebugFilterExclude
    )

    $CmdletBinding = [bool]$ScriptBlock.Ast.ParamBlock.Attributes.Where{$_.TypeName -match "CmdletBinding"}

    if($PSBoundParameters.ContainsKey("InformationVariable")) {
        . $ScriptBlock
    }
    else {
        if($CmdletBinding) {
            . $ScriptBlock -InformationVariable Log
            Set-Variable -Name Log -Value $Log -Scope 1
        }
        else {
            . {[CmdletBinding()]param() . $ScriptBlock } -InformationVariable Log
            Set-Variable -Name Log -Value $Log -Scope 1
        }



    }
}