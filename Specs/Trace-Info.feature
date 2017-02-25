Feature: Trace-Info
    As a PowerShell scripter
    I want to be able to log exceptions and stack traces
    So that I can understand problems and fix them

    Background:
        Given I call Set-InfoTemplate '{ClockTime} {Message}'

    Scenario: I need to call code which may throw an exception
        When I wrap Trace-Info around code that throws an exception
        Then the information stream should have 2 items
        And the information stream should have exceptions in it