# The Information module improves Write-Information

The core functionality is a replacement `Write-Info` command for writing to the Information stream, which updates the output to use the TimeZone aware DateTimeOffset for the built-in `TimeGenerated` field, and adds the `Invocation` property with the information about where the information is coming from.

In addition to that, there are wrapper functions that and formatting the data from the Information stream.

For instance, Write-Info writes to the Information (and optionally also the Debug) stream, and adds CallStack information to each output.

# TODO:

[] Fix bug in indent (and callstack?)