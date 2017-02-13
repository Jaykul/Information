#requires -Module Information

function Invoke-BrokenThing {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [int]$InputObject
    )

    begin {
        Write-Trace "Begin Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Trace "Begin Exit Invoke-BrokenThing" -Tags "Enter Begin"
        $ex = @()
    }

    process {
        Write-Trace "Process Enter Invoke-BrokenThing" -Tags "Enter Begin"
        if($InputObject -ge 5) {
            Get-ChildItem "C:\NoSuch\FileExists-${InputObject}.txt" -ErrorVariable +ex
        }
        if($ex.Count -gt 2) {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new($ex[-1].Exception, "Invoke-BrokenThing:TooManyErrors", 'LimitsExceeded', $InputObject)
            )
        }

        Write-Trace "Process Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }

    end {
        Write-Trace "End Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Trace "End Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }
}


$File = Protect-Trace {
    Write-Trace "Start Testing"


    1..10 | Invoke-BrokenThing

    Write-Trace "Stop Testing" # won't ever happen?
} -LogPath "$($MyInvocation.MyCommand.Source).log.clixml"

$Log = Import-Clixml -Path $File
