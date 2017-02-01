---
Module Name: Information
Module Guid: 775a34c4-0c58-4836-9176-25fd2dc31f64
Download Help Link: {{Please enter FwLink manually}}
Help Version: {{1.0.0}}
Locale: en-US
---

# Information Module

## Description

The Information module is an experiment to provide useful new scenarios for using the Information stream, otherwise only usable via Write-Information.

The core functionality is a wrapper, `Write-Trace` for writing rich object logs to the Information stream,

## Information Cmdlets

### [Set-TraceMessageTemplate](Set-TraceMessageTemplate.md)

A wrapper for the `[TraceMessage]::MessageTemplate` to support changing the format string for the debug logs.

### [Write-Trace](Write-Trace.md)

A replacement for the built-in Write-Information which adds the call stack and parameter information to the stream, and supports echoing data to the Debug stream as well.

