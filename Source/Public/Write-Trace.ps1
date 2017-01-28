function Write-Trace {
    <#
        .Synopsis
            An enhancement to the built-in Write-Information to make it show the calling script line
        .Description
            Creates a stopwatch that tracks the time elapsed while a script runs, and adds caller position and time to the output
        .Example
            Write-Trace "Enter Get-MyFunctionName"

            Writes a message to the information stream
        .Example
            function Test-Information {
                [CmdletBinding()]param($Name, $Age)
                Write-Trace 'Enter Test-Information' -Tag 'Trace','Enter'

                # do stuff

                Write-Trace 'Exit Test-Information' -Tag 'Trace','Exit'
            }

            $InformationTracePreference = "CallStack"
            Test-Information -InformationVariable Log
            $Log | Where Tags -match Enter | % { $_.MessageData.CallStack }

            Writes enter and exit messages to the information stream using the TracePreference variables to add CallStack information, and shows how to filter and show that data
        .Example
            $InformationDebugEcho = $true
            Test-Information -Debug

            Using the same Test-Information from the Example 2, this exameple doesn't includ CallStack information, but uses the $InformationDebugEcho and the -Debug switch trigger the information stream to be echoed to Debug, and printed with source and timestamp information.
    #>
    [CmdletBinding(DefaultParameterSetName="InformationOutput")]
    param(
        # Specifies an informational message that you want to display to users as they run a script or command.
        # Note that this is a rich object, and the -InformationVariable can collect those objects, but the stream will just get the ToString()
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [PSObject]$MessageData,

        # Specifies a simple string that you can use to sort and filter messages that you have added to the information stream with Write-Information
        [String[]]$Tags
    )
    begin {
        if((Get-PSCallStack).Where({ $_.InvocationInfo.BoundParameters.ContainsKey("Debug") }, 1).InvocationInfo.BoundParameters.Debug) {
            $DebugPreference = "Continue"
        }
    }

    process {
        # The main point of this wrapper is to put the line number into the Source:
        ${Your CallStack} = Get-PSCallStack | Select-Object -Skip 1
        ${Trace Message} = [TraceMessage]::new($MessageData, ${Your CallStack})
        ${Information Record} = [InformationRecord]::new(${Trace Message}, ${Your CallStack}[0].ToString())

        if($DebugPreference -eq "Continue") {
            Write-Debug ${Trace Message}.ToString()
        }

        foreach($Tag in $Tags) { ${Information Record}.Tags.Add($Tag) }
        $PSCmdlet.WriteInformation(${Information Record})
    }
}
