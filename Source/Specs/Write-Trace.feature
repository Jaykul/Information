Feature: Write-Trace
    As a PowerShell Module Author
    I need to conditionally log output, with timestamps
    So that I can trace execution and locate problems


    Scenario: Simple Trace to Information
        When I call Write-Trace "Hello World"
        Then the information stream should have 1 item
        And the MessageData should match "Hello World"