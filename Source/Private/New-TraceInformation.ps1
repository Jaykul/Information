function New-TraceInformation {
    [CmdletBinding()]
    param(
        # Object or message to write to the Information stream
        $MessageData,

        # The CallStack
        [Array]$CallStack,

        # Tags to categorize and filter by
        [String[]]$Tags,

        # The prefix for the string message
        [AllowNull()][AllowEmptyString()]
        [string]$Prefix,

        # Don't expand error data
        [switch]$Simple
    )
    if($CallStack -isnot [System.Management.Automation.CallStackFrame[]]) {
        $CallStack = $CallStack.ForEach{ $_ -split "[\r?\n]+" }
    }

    ${Trace Message} = [TraceInformation]::new($MessageData, $CallStack, $Prefix, $Simple)
    ${Information Record} = [InformationRecord]::new(${Trace Message}, "$(@($CallStack)[0])")

    foreach($Tag in $Tags) { ${Information Record}.Tags.Add($Tag) }
    ${Information Record}
}