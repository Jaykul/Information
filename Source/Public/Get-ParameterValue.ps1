function Get-ParameterValue {
    <#
        .Synopsis
            Get the actual values of parameters which have manually set (non-null) default values or values passed in the call
        .Description
            Unlike $PSBoundParameters, the hashtable returned from Get-ParameterValues includes non-empty default parameter values.
            NOTE: Default values that are the same as the implied values are ignored (e.g.: empty strings, zero numbers, nulls).
        .Example
            function Test-Parameters {
                [CmdletBinding()]
                param(
                    $Name = $Env:UserName,
                    $Age
                )
                $Parameters = . Get-ParameterValues

                # This WILL ALWAYS have a value...
                Write-Host $Parameters["Name"]

                # But this will NOT always have a value...
                Write-Host $PSBoundParameters["Name"]
            }
    #>
    [CmdletBinding()]
    param(
        # The InvocationInfo for the caller, contains the BoundParameters and the CommandInfo
        # You need not pass this, instead, dot-source Get-ParameterValues
        [System.Management.Automation.InvocationInfo]${Invocation Info} = $MyInvocation
    )

    # I'm naming all my variables with spaces to avoid stepping on your parameter names
    ${Parameter Values} = @{}
    foreach(${Parameter KeyValuePair} in ${Invocation Info}.MyCommand.Parameters.GetEnumerator()) {
        try {
            ${Parameter Name} = ${Parameter KeyValuePair}.Key

            # Check to see if the parameter variable has a value
            if($null -ne (${Parameter Variable Value} = Get-Variable -Name ${Parameter Name} -ValueOnly -ErrorAction Ignore )) {
                if(${Parameter Variable Value} -ne ($null -as ${Parameter KeyValuePair}.Value.ParameterType)) {
                    ${Parameter Values}[${Parameter Name}] = ${Parameter Variable Value}
                }
            }
            if(${Invocation Info}.BoundParameters.ContainsKey(${Parameter Name})) {
                ${Parameter Values}[${Parameter Name}] = ${Invocation Info}.BoundParameters[${Parameter Name}]
            }
        } finally {}
    }
    return ${Parameter Values}
}
