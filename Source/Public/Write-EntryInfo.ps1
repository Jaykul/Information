function Write-EntryInfo {
    <#
        .Synopsis
            An enhancement to the built-in Write-Information to make it show the calling script line and log PSBoundParameters in addition to callstack
        .Description
            Writes messages to the Information stream with callstack and tags, optionally echoing to the debug stream.
            Messages echoed to the debug stream are only written when debugging is enabled (so they'll be visible) and can be filtered by tags.
        .Example
            Write-Info "Enter Get-MyFunctionName"

            Writes a message to the information stream
        .Example
            function Test-Information {
                [CmdletBinding()]param($Name, $Age)
                Write-Info 'Enter Test-Information' -Tag 'Trace','Enter'

                # do stuff

                Write-Info 'Exit Test-Information' -Tag 'Trace','Exit'
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
    [CmdletBinding(DefaultParameterSetName = "InformationOutput")]
    param(
        # Specifies an informational message that you want to display to users as they run a script or command.
        # Note that this is a rich object, and the -InformationVariable can collect those objects, but the stream will just get the ToString()
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Object")]
        [PSObject]$MessageData,

        # Specifies a simple string that you can use to sort and filter messages that you have added to the information stream with Write-Information
        [String[]]$Tags,

        # Supports passing in an existing Stopwatch so you can correlate logs output across jobs
        [DateTimeOffset]$StartTime
    )
    begin {
        if ($StartTime) {
            [Information.InformationMessage]::StartTime = $StartTime
        }

        if (!${script:Pre-Trace Timer Prompt}) {
            # Assume that we should reset the StartTime any time we hit the prompt:
            ${script:Pre-Trace Timer Prompt} = ${function:prompt}

            ${function:global:prompt} = {
                [Information.InformationMessage]::StartTime = [DateTimeOffset]::MinValue
                ${function:global:prompt} = ${script:Pre-Trace Timer Prompt}
                Remove-Variable -Scope Script -Name "Pre-Trace Timer Prompt"
                & ${function:global:prompt}
            }

            $MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
                if (${script:Pre-Trace Timer Prompt}) {
                    ${function:global:prompt} = ${script:Pre-Trace Timer Prompt}
                    Remove-Variable -Scope Script -Name "Pre-Trace Timer Prompt"
                }
            }
        }

        # Magically look up the stack for anyone turning on Information and treat it as present here:
        if ($Specified = (Get-PSCallStack).Where( { $_.GetFrameVariables().ContainsKey("InformationPreference")}, 1)) {
            $InformationPreference = $Specified.GetFrameVariables()["InformationPreference"].Value
        }
        # Magically look up the stack for anyone turning on Debug, and treat it as "Continue" in here
        if ($Specified = (Get-PSCallStack).Where( { $_.GetFrameVariables().ContainsKey("DebugPreference")}, 1)) {
            $DebugPreference = $Specified.GetFrameVariables()["DebugPreference"].Value
        }
        # Write-Info always treats Debug as either Silent or Contine -- never inquire or any of that
        if ($DebugPreference -notin "SilentlyContinue", "Ignore") {
            $DebugPreference = "Continue"
        }
    }

    process {
        # The main point of this wrapper is to put the line number into the Source:
        ${Your CallStack} = Get-PSCallStack | Select-Object -Skip 1
        if ($PSCmdlet.MyInvocation.InvocationName -eq "Write-Host") {
            $Tags = @("PSHOST") + $Tags
        }
        ${Trace Message} = New-InformationMessage -MessageData $MessageData -CallStack ${Your CallStack} -Tags $Tags
        $PSCmdlet.WriteInformation(${Trace Message})

        if ($DebugPreference -eq "Continue") {
            if (!$DebugFilterInclude -or $Tags.Where{ $_ -in $DebugFilterInclude}) {
                if (!$DebugFilterExclude -or -not $Tags.Where{ $_ -in $DebugFilterExclude}) {
                    Write-Debug ${Trace Message}.ToString()
                }
            }
        }
    }
}
