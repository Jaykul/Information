[CmdletBinding()]
param(
    $InputObject
)

Write-Host "Enter TestScript"

# This function could be anything, the point is for you to see a nested exception
function Test-Function {
    [CmdletBinding()]
    param(
        $InputObject
    )

    Write-Host "Enter Test-Function"

    Get-ChildItem $InputObject -ErrorVariable ChildItemError -ErrorAction Ignore

    if($ChildItemError) {
        # Turn their error into our terminating error
        $PSCmdlet.ThrowTerminatingError($ChildItemError[-1])
    }

    Write-Host "Exit Test-Function"
}

Get-ChildItem $InputObject

Write-Host "Exit TestScript"