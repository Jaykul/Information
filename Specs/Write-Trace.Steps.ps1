# In this particular set of steps, I will try to use Pester 4.0's "Should" operator

BeforeAll {
    Import-Module Information -Scope Global
}

BeforeScenario {
    Remove-Item Variable:InformationStream -ErrorAction Ignore
    Remove-Item Variable:DebugStream -ErrorAction Ignore
}

Given 'I set DebugFilterInclude to (:?"(.*)",?)+' {
    param([string[]]$Tags)
    $global:DebugFilterInclude = $Tags | % { $_.Trim('"') }
}

Given 'I call Write-Trace "(.*)"(?: -Tags ([^ ]+)+)?' {
    param($Message, [string[]]$Tags)
    $P = @{
        MessageData = $Message
        Tags = $Tags
        InformationVariable = "+script:InformationStream"
        OutVariable = "+script:DebugStream"
    }
    Write-Trace -Debug @P 5>&1 | Out-Null
}

Then 'the information stream should have (\d+) items?' {
    param([int]$number)
    $InformationStream.Count | Should -Be $number
}

Then 'the debug stream should have (\d+) items?' {
    param([int]$number)
    $DebugStream.Count | Should -Be $number
}

Then 'the MessageData should ([^ ]+) "(.*)"' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $InformationStream.MessageData | Should $operator $message
}

Then 'the debug text should ([^ ]+) "(.*)"' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $DebugStream.Message | Should $operator $message
}
