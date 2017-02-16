#requires -Module Information

function Invoke-BrokenThing {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [int]$InputObject
    )

    begin {
        Write-Info "Begin Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Info "Begin Exit Invoke-BrokenThing" -Tags "Enter Begin"
        $ex = @()
    }

    process {
        Write-Info "Process Enter Invoke-BrokenThing" -Tags "Enter Begin"
        if($InputObject -ge 5) {
            Get-ChildItem "C:\NoSuch\FileExists-${InputObject}.txt" -ErrorVariable +ex
        }
        if($ex.Count -gt 2) {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new($ex[-1].Exception, "Invoke-BrokenThing:TooManyErrors", 'LimitsExceeded', $InputObject)
            )
        }

        Write-Info "Process Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }

    end {
        Write-Info "End Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Info "End Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }
}


$File = Trace-Info {
    Write-Info "Start Testing"


    1..10 | Invoke-BrokenThing

    Write-Info "Stop Testing" # won't ever happen?
} -LogPath "$($MyInvocation.MyCommand.Source).log.clixml"

$Log = Import-Clixml -Path $File
