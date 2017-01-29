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

        [TracePreference]$InformationTrace
    )

    $InformationTracePreference, $ITP = $InformationTrace, $InformationTracePreference

    if($PSBoundParameters.ContainsKey("Debug")) {
        $script:InformationDebugEcho, $IDE = $true, $script:InformationDebugEcho
    }

    if($PSBoundParameters.ContainsKey("InformationVariable") -and -not $PSBoundParameters.ContainsKey("LogVariableName")) {
        . $ScriptBlock
    } else {
        . {[CmdletBinding()]param() . $ScriptBlock } -InformationVariable Log
        Set-Variable -Name Log -Value $Log -Scope 1
    }

    $InformationTracePreference, $ITP = $ITP, $InformationTracePreference
    $script:InformationDebugEcho, $IDE = $IDE, $script:InformationDebugEcho
}