Feature: Write-Info
    As a PowerShell Module Author
    I need to conditionally log output, with timestamps
    So that I can trace execution and locate problems

    Background:
        Given I call Set-InfoTemplate '`${ClockTime} `${Message}'

    Scenario: Simple Trace to Information
        When I call Write-Info "Hello World"
        Then the information stream should have 1 item
        And the MessageData should match "Hello World"

    Scenario: Filtered Trace to Information
        Given I set DebugFilterInclude to "Hello"
        When I call Write-Info "Hello World" -Tags Hello
        And I call Write-Info "Test Names" -Tags Test
        Then the information stream should have 2 items
        And the MessageData should match "Hello World|Test Names"
        And the debug stream should have 1 item
        And the debug text should match "Hello World"
