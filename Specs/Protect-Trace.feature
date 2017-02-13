Feature: Protect-Trace
    As a PowerShell scripter
    I want to be able to log exceptions and stack traces
    So that I can understand problems and fix them

    Background:
        Given I call Set-TraceMessageTemplate '`${Time} `${Message}'

    Scenario: I need to call code which may throw an exception
        When I wrap Protect-Trace around code that throws an exception
        Then the information stream should have 8 items
        And the information stream should have exceptions in it