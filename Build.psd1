@{
    SourcePath = Join-Path $PSScriptRoot "Source"
    ModuleName = Split-Path $PSScriptRoot -Leaf
    TestPath = Join-Path $PSScriptRoot Specs

    # I like having the versioned build come out in the project root
    Output = $PSScriptRoot
    Language = $PSUICulture
    Default = "Build"
}