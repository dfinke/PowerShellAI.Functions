function Invoke-ChatWithModuleContext {
    param(
        [Parameter(Mandatory)]
        [string] $Question,
        [Parameter(Mandatory)]
        [string] $ModuleName
    )

    $commands = Get-Command -Module $ModuleName -ErrorAction "SilentlyContinue"
    if(!$commands) {
        throw "Module '$ModuleName' has no commands"
    }

    $functions = ConvertFrom-FunctionDefinition $commands

    $messages = @(
        New-ChatMessageTemplate system @'
You are a powershell expert.
You provide simple solutions to the users query by calling a single function.
Only use the functions you have been provided with.
If there is no answer to the query, respond with 'I don't know how to do that 🤷'.
'@
        New-ChatMessageTemplate user $Question
    )

    $chatResponse = Get-ChatCompletion $messages -functions $functions
    $target = $chatResponse.choices[0]

    if ($target.'finish_reason' -eq 'function_call') {
        $functionName = $target.message.'function_call'.name
        $arguments = $target.message.'function_call'.arguments
        $splatParam = $arguments | ConvertFrom-Json -AsHashtable

        Write-Host -ForegroundColor DarkGray "$functionName $(($splatParam.GetEnumerator() | Foreach-Object { return "-$($_.Key) '$($_.Value)'" }) -join ' ')"
        $answer = Read-Host -Prompt "Do you want to run the following command? (y/N)"
        if($answer -eq "y") {
            & $functionName @splatParam
        } else {
            Write-Verbose "Command was not run"
        }
    } else {
        $target.message.content
    }
}