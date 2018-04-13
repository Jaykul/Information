function Write-ErrorInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $ErrorRecord,

        [AllowNull()][AllowEmptyString()]
        [string]$Prefix,

        [switch]$WriteError,

        [switch]$Simple,

        [switch]$Passthru
    )

    $level = 0

    $Information_Record = @{
        Prefix = $Prefix
        MessageData = $ErrorRecord
        Tags = @("Error")
        Simple = $Simple.IsPresent
    }

    if($ErrorRecord -is [System.Management.Automation.ErrorRecord]) {
        $Information_Record.Tags += "ErrorRecord"
        $Information_Record.CallStack = $ErrorRecord.ScriptStackTrace
        $Ex = $ErrorRecord.Exception
    } else {
        $Information_Record.Tags += "Exception"
        $Information_Record.CallStack = $ErrorRecord.ErrorRecord.ScriptStackTrace
        $Ex = $ErrorRecord
    }
    # recursively add the exception types as tags
    do {
        $Information_Record.Tags += $Ex.GetType().Name
        $Ex = $Ex.InnerException
    } while($Ex.InnerException)

    $Info = New-InformationMessage @Information_Record
    $PSCmdlet.WriteInformation($Info)
    if($Passthru) { $Info }

    # Make sure this error shows up in the error stream (as the last error)
    if($WriteError) {
        Write-Error -ErrorRecord $ErrorRecord
    }
}

Export-ModuleMember -Cmdlet * -Function * -Variable DebugFilterInclude, DebugFilterExclude