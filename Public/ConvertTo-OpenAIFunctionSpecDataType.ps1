function ConvertTo-OpenAIFunctionSpecDataType {
    <#
        .SYNOPSIS
        Converts a .NET data type to an OpenAI Function Spec data type.

        .DESCRIPTION
        This function takes a .NET data type as input and returns the corresponding OpenAI Function Spec data type.

        .PARAMETER targetType
        The .NET data type to convert.

        .EXAMPLE
        ConvertTo-OpenAIFunctionSpecDataType -targetType 'int32'
        Returns 'number'.

        .EXAMPLE
        ConvertTo-OpenAIFunctionSpecDataType -targetType 'switchparameter'
        Returns 'boolean'.
    #>

    [CmdletBinding()]
    param($targetType)

    # Use closest compatible types from json-schema https://json-schema.org/understanding-json-schema/
    switch ($targetType) {
        { $_ -match 'int32|decimal|float|single|int' } { return 'number' }
        { $_ -match 'switchparameter|bool|boolean'} { return 'boolean' }
        { $_ -match 'string'} { return 'string' }
        default { return 'object' }
    }
}