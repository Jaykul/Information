Feature: Set-InfoTemplate
    As a PowerShell scripter, and user of the Information module
    I want to control the text that's output in the Information trace
    So that I can see what matters the most to me

    Scenario: I can set the message template
        # Gherkin "feature" means I can't pass $variable names here?
        When I call Set-InfoTemplate '{ClockTime} {Message}'
        Then the TraceInfoTemplate is '{ClockTime} {Message}'

    Scenario: The message comes out as expected
        When I call Set-InfoTemplate '{ClockTime} {Message}'
        And I call Write-Info 'Hello World'
        Then the MessageData should match "\d+:\d+:\d+\.\d+ Hello World"


    Scenario Outline: I can use tokens in the message
        When I call Set-InfoTemplate '<Token>'
        And I call Write-Info '<MessageData>'
        Then the Message should <Test> '<expected>'

        Examples:
            | Token                 | MessageData | Test     | expected                                          |
            | `{Message}            | Hello World | match    | Hello World                                       |
            | `{Message}            | 14          | match    | 14                                                |
            | `{Indent}             | Ignored     | match    | \s+                                               |
            | `{Command}            | Ignored     | Be       | <ScriptBlock>                                     |
            | `{FunctionName}       | Ignored     | Be       | <ScriptBlock>                                     |
            | `{ClockTime:hh-mm.ss} | Ignored     | match    | \d+-\d+.\d+                                       |
            | `{ElapsedTime:mm:ss}  | Ignored     | match    | \d+:\d+                                           |
            | `{GeneratedDateTime}  | Ignored     | match    | \d+/\d+/\d{4} \d+:\d{2}:\d{2} [AP]M -?\d{2}:\d{2} |
            | `{ScriptPath}         | Ignored     | match    | Information\\\\Specs\\\\Information\\.Steps\\.ps1 |
            | `{PSComputerName}     | Ignored     | match    | ${Env:ComputerName}                               |
            | `{ScriptName}         | Ignored     | Be       | Information.Steps.ps1                             |
            | `{LineNumber}         | Ignored     | match    | \d+                                               |
            | `{Location}           | Ignored     | match    | Information.Steps.ps1: line \d+                   |
            | ``e[38;5;1m           | Ignored     | match    | \u001b\[38;5;1m                                   |