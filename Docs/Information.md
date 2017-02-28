---
Module Name: Information
Module Guid: 775a34c4-0c58-4836-9176-25fd2dc31f64
Download Help Link: {{Please enter FwLink manually}}
Help Version: {{1.0.0}}
Locale: en-US
---

# Information Module

## Description

The Information module was an experiment to provide useful new scenarios for using the Information stream, which was otherwise only usable via Write-Information.

The core functionality is two Cmdlets:

## Information Cmdlets
### [Write-Info](Write-Info.md)
A command to replace Write-Host or other logging with tagged and filterable Information stream logging

### [Trace-Info](Trace-Info.md)
A command to wrap around scripts to not only support filtering the output for Write-Info and easily logging it, but to ensure capturing full Error information and exception stack traces.

### [Write-ErrorInfo](Write-ErrorInfo.md)
Like Write-Info, but specifically for error objects. This is what's used internally in Trace-Info.

### [Set-InfoTemplate](Set-InfoTemplate.md)
Set a display template for our InformationMessage

### [Get-InfoTemplate](Get-InfoTemplate.md)
Get the current display template for InformationMessage

