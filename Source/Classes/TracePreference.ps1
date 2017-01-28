using namespace System.Management.Automation

[Flags()]
enum TracePreference {
    None = 0
    CallStack = 1
    Parameters = 2
}
