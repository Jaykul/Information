function Get-InfoTemplate {
    <#
        .Synopsis
            Gets the template string used for trace messages
    #>
    [CmdletBinding()]param()

    [Information.InformationHelper]::InfoTemplate
}