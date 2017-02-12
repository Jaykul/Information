function Invoke-BrokenThing {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [int]$InputObject
    )

    begin {
        Write-Trace "Begin Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Trace "Begin Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }

    process {
        Write-Trace "Process Enter Invoke-BrokenThing" -Tags "Enter Begin"
        if($InputObject -gt 10) {
            Get-ChildItem C:\NoSuch\FileExists.txt -ea stop
        }
        Write-Trace "Process Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }

    end {
        Write-Trace "End Enter Invoke-BrokenThing" -Tags "Enter Begin"
        Write-Trace "End Exit Invoke-BrokenThing" -Tags "Enter Begin"
    }
}


Protect-Trace {
    Write-Trace "Start Testing"


    1..1e4 | % {
        Get-Random -min 0 -max 15
    } | Invoke-BrokenThing

    Write-Trace "Stop Testing" # won't ever happen?
} -LogPath "$($MyInvocation.MyCommand.Source).log.clixml"