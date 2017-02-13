function New-TraceMessageInformationRecord {
    [CmdletBinding()]
    param(
        $MessageData,
        $CallStack,
        $Tags
    )

    ${Trace Message} = [TraceMessage]::new($MessageData, $CallStack)
    ${Information Record} = [InformationRecord]::new(${Trace Message}, $CallStack[0].ToString())

    foreach($Tag in $Tags) { ${Information Record}.Tags.Add($Tag) }
    ${Information Record}
}