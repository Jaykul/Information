using module Information
# In this particular set of steps, I will try to use Pester 4.0's "Should" operator
Given 'I set DebugFilterInclude to (:?"(.*)",?)+' {
    param([string[]]$Tags)
    $global:DebugFilterInclude = $Tags | % { $_.Trim('"') }
}

When 'I call Write-Trace ["''](.*)["''](?: -Tags ([^ ]+)+)?' {
    param($Message, [string[]]$Tags)
    $P = @{
        MessageData = $Message
        Tags = $Tags
    }
    Write-Trace -Debug @P -InformationVariable +InformationStream -OutVariable +DebugStream 5>&1 | Out-Null
}

Then 'the information stream should have (\d+) items?' {
    param([int]$number)
    $InformationStream.Count | Should -Be $number
}

Then 'the debug stream should have (\d+) items?' {
    param([int]$number)
    $DebugStream.Count | Should -Be $number
}

Then '(?n)the Message(Data)? should (?<operator>[^ ]+) ["''](?<message>.*)["'']' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $InformationStream.MessageData[-1] | Should $operator $message
}

Then 'the debug text should ([^ ]+) "(.*)"' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $DebugStream.Message | Should $operator $message
}

When "I call Set-TraceMessageTemplate '(.*)'$" {
    param($Template)
    Information\Set-TraceMessageTemplate $Template
}

Then "the TraceMessageTemplate is '(.*)'" {
    param($Template)
    [TraceMessage]::MessageTemplate | Should Be $Template
}

When "I wrap Protect-Trace around code that throws an exception" {
    $InformationStream = Protect-Trace {
        Write-Trace "Start Test"
        Get-ChildItem NoSuchFile -EA Stop
    } -ea SilentlyContinue
}

Then "the information stream should have exceptions in it" {
    $InformationStream | Where Tags -eq Exception | Should Not BeNullOrEmpty
}