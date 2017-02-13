Feature: Set-TraceMessageTemplate
    As a PowerShell scripter, and user of the Information module
    I want to control the text that's output in the Information trace
    So that I can see what matters the most to me

    Scenario: I can set the message template
        # Gherkin "feature" means I can't pass $variable names here?
        When I call Set-TraceMessageTemplate '`${Time} `${Message}'
        Then the TraceMessageTemplate is '`${Time} `${Message}'

    Scenario: The message comes out as expected
        When I call Set-TraceMessageTemplate '`${Time} `${Message}'
        And I call Write-Trace 'Hello World'
        Then the MessageData should match "\d+:\d+:\d+\.\d+ Hello World"


    Scenario Outline: I can use tokens in the message
        When I call Set-TraceMessageTemplate '<Token>'
        And I call Write-Trace '<MessageData>'
        Then the Message should <Test> '<expected>'

        Examples:
            | Token            | MessageData | Test     | expected              |
            | `$MessageData    | Hello World | match    | Hello World           |
            | `$Message        | 14          | match    | 14                    |
            | `$Time           | Ignored     | match    | \d+:\d+:\d+\.\d+      |
            | `$Elapsed        | Ignored     | match    | \d+:\d+:\d+\.\d+      |
            | `$CallStackDepth | Ignored     | match    | \d+                   |
            | `$Command        | Ignored     | Be       | <ScriptBlock>         |
            | `$FunctionName   | Ignored     | Be       | <ScriptBlock>         |
            | `$ScriptPath     | Ignored     | match    | Information\\\\Specs\\\\Information\\.Steps\\.ps1 |
            | `$ScriptName     | Ignored     | Be       | Information.Steps.ps1                             |
            | `$LineNumber     | Ignored     | match    | \d+                                               |
            | `$Location       | Ignored     | match    | Information.Steps.ps1: line \d+                   |
            | `$Arguments      | Ignored     | Be       | $null                                             |
            | `$e[38;5;1m      | Ignored     | match    | \u001b\[38;5;1m                                   |