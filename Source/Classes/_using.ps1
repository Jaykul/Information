using namespace System.Management.Automation

[String[]]$DebugFilterInclude = @()
[String[]]$DebugFilterExclude = @()

Update-TypeData -TypeName 'Deserialized.System.DateTimeOffset' -TargetTypeForDeserialization 'System.DateTimeOffset' -Force
Update-TypeData -TypeName 'System.DateTimeOffset' -TypeConverter 'Information.DateTimeOffsetConverter' -SerializationDepth 1 -Force

Update-TypeData -TypeName 'Deserialized.System.Management.Automation.InformationRecord' -TargetTypeForDeserialization 'System.Management.Automation.InformationRecord' -Force
Update-TypeData -TypeName 'Deserialized.Information.InvocationRecord' -TargetTypeForDeserialization 'Information.InvocationRecord' -Force
Update-TypeData -TypeName 'System.Management.Automation.InformationRecord' -TypeConverter 'Information.InformationRecordConverter' -SerializationDepth 6 -Force
Update-TypeData -TypeName 'Information.InvocationRecord' -TypeConverter 'Information.InformationRecordConverter' -SerializationDepth 6 -Force
