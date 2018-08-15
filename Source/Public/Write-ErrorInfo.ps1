function Write-ErrorInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $ErrorRecord,
        
        [switch]$WriteError,

        [switch]$Passthru
    )

    $level = 0

    if($ErrorRecord -is [System.Management.Automation.ErrorRecord]) {
        $Tags = @("Error", "ErrorRecord")
        $Ex = $ErrorRecord.Exception
    } else {
        $Tags = @("Error", "Exception")
        $Ex = $ErrorRecord
    }

    # recursively add the exception types as tags
    do {
        $Tags += $Ex.GetType().Name
        $Ex = $Ex.InnerException
    } while($Ex.InnerException)

    $Info = [Information.InvocationRecord]::new($ErrorRecord, $ErrorRecord.InvocationInfo, ([string[]]$Tags))
    $PSCmdlet.WriteInformation($Info)
    if($Passthru) { $Info }

    # Make sure this error shows up in the error stream (as the last error)
    if($WriteError) {
        Write-Error -ErrorRecord $ErrorRecord
    }
}

Export-ModuleMember -Cmdlet * -Function * -Variable DebugFilterInclude, DebugFilterExclude