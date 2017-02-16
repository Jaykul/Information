using module Information
# In this particular set of steps, I will try to use Pester 4.0's "Should" operator
Given 'I set DebugFilterInclude to (:?"(.*)",?)+' {
    param([string[]]$Tags)
    $global:DebugFilterInclude = $Tags | % { $_.Trim('"') }
}

BeforeEachFeature {
    Remove-Variable InformationStream -Scope Global -ErrorAction Ignore
    Remove-Variable InformationStream -Scope Script -ErrorAction Ignore
    Remove-Variable InformationStream -Scope Local -ErrorAction Ignore
}


When 'I call Write-Info ["''](.*)["''](?: -Tags ([^ ]+)+)?' {
    param($Message, [string[]]$Tags)
    $P = @{
        MessageData = $Message
        Tags = $Tags
    }
    Write-Info -Debug @P -InformationVariable +InformationStream -OutVariable +DebugStream 5>&1 | Out-Null
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
    $InformationStream.MessageData[-1].ToString() | Should $operator $message
}

Then 'the debug text should ([^ ]+) "(.*)"' {
    param($operator, $message)
    # Note this syntax is now considered "legacy" for should
    $DebugStream.Message | Should $operator $message
}

When "I call Set-InfoTemplate '(.*)'$" {
    param($Template)
    Information\Set-InfoTemplate $Template
}

Then "the TraceInfoTemplate is '(.*)'" {
    param($Template)
    [TraceInformation]::InfoTemplate | Should Be $Template
}

When "I wrap Trace-Info around code that throws an exception" {
    Trace-Info {
        Write-Host "Start Test"
        throw "Simple String Error"
    } -InformationVariable InformationStream -InformationAction SilentlyContinue -CatchException
}

Then "the information stream should have exceptions in it" {
    $InformationStream | Where Tags -match Error | Should Not BeNullOrEmpty
}