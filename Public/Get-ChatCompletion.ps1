function Get-ChatCompletion {
    <#
        .SYNOPSIS
            Gets a chat completion from OpenAI's GPT API.

        .DESCRIPTION
            This function sends a request to OpenAI's GPT API to generate a chat completion based on the provided messages, functions, and function call.

        .PARAMETER messages
            An array of messages to use as context for the chat completion.

        .PARAMETER functions
            An array of functions to include in the chat completion.

        .PARAMETER function_call
            The function call to include in the chat completion.

        .PARAMETER model
            The GPT model to use for the chat completion. Default is 'gpt-3.5-turbo-16k'.
    #>
    [CmdletBinding()]
    param (
        [object[]]$messages,
        $functions,
        $function_call,
        $model = 'gpt-3.5-turbo-16k',
        $temperature = 1.0,
        $top_p = 1.0
    )

    $data = [Ordered]@{
        model       = $model
        temperature = $temperature
        top_p       = $top_p
        messages    = $messages 
    }

    if ($null -ne $functions) {        
        $data.functions = @($functions)       
    }

    if ($null -ne $function_call) {
        $data.function_call = @{name = $function_call }
    }

    $payload = $data | ConvertTo-Json -Depth 7 
    $body = [System.Text.Encoding]::UTF8.GetBytes($payload)

    try {
        $Error.Clear()
        # Invoke-OpenAIAPI -Uri (Get-OpenAIChatCompletionUri) -Method 'Post' -Body $body
        
        if ((Get-ChatAPIProvider) -eq 'OpenAI') {
            $uri = Get-OpenAIChatCompletionUri
        }
        elseif ((Get-ChatAPIProvider) -eq 'AzureOpenAI') {
            $uri = Get-ChatAzureOpenAIURI
        }

        Invoke-OpenAIAPI -Uri $uri -Method 'Post' -Body $body
    }
    catch {
        $_
        # $Error
        #$e = $r.ErrorDetails.Message | ConvertFrom-Json
        #$e.error.message
    }
}
