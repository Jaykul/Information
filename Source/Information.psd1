@{

# Script module or binary module file associated with this manifest.
RootModule = 'Information.psm1'

# Version number of this module.
ModuleVersion = '0.5.0'

# ID used to uniquely identify this module
GUID = '775a34c4-0c58-4836-9176-25fd2dc31f64'

# Author of this module
Author = 'Joel "Jaykul" Bennett'

# Company or vendor of this module
CompanyName = 'HuddledMasses.org'

# Copyright statement for this module
Copyright = '(c) 2017 Joel Bennett. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Improves on Write-Information and provides new scenarios for the Information stream'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Write-Info', 'Trace-Info', 'Set-InfoTemplate'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @(
    'DebugFilterExclude'
    'DebugFilterInclude'
)

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
            0.5.0
            Added a Deserializer to TraceInformation so that remote TraceInformation can be rendered with the local InformationTemplate
            This means that we no longer need to pass the StartTime or the InfoTemplate to remote computers.
            Updated samples accordingly

            0.4.0
            Major refactor, rename existing functions to create a new, consistent sent of nouns
            Add Trace-Info to wrap calls to functions and alias Write-Host

            0.3.0
            Added a Deserializer for DataTimeOffset so that we can pass the "StartTime" to remote computers for consistent "elpsed" time.
        '

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

