# In this particular set of steps, I will try to use Pester 4.0's "Should" operator

Given 'I call Write-Trace "(.*)"' {
    param($Message)
    Write-Trace -MessageData $Message -InformationVariable script:InformationStream
}

Then 'the information stream should have (\d+) items?' {
    param([int]$number)
    $InformationStream.Count | Should -Be $number
}

Then 'the MessageData should ([^ ]+) "(.*)"' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $InformationStream.MessageData | Should $operator $message
}
