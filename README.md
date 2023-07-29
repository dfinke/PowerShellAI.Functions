# PowerShell AI Functions

Function calling allows developers to more reliably get structured data back from the OpenAI GPT model.

## Introduction

`PowerShellAI.Functions` is a PowerShell module designed to work as a bridge between PowerShell functions and OpenAI. It provides an array of functionalities to convert PowerShell function metadata into OpenAI function call specifications, and also includes functions to directly call the OpenAI REST API.

This module is intended to make it easy for developers to integrate AI capabilities into their PowerShell scripts, without needing deep knowledge of the OpenAI API's specifics.

## Installation

To install `PowerShellAI.Functions`, run the following in a PowerShell session:

```powershell
Install-Module -Name PowerShellAI # this is required
Install-Module -Name PowerShellAI.Functions
```

## Usage

To use `PowerShellAIFunctionRig`, you first need to import the module into your PowerShell session (as shown above). Here's an example of how to convert a PowerShell function's metadata to an OpenAI function call spec:

```powershell
function Get-CurrentWeather {
    <#
        .FunctionDescription
            Gets the current weather for a location
        .ParameterDescription location
            The location to get the weather for
        .ParameterDescription format
            The format to get the weather in
    #>
    param (
        [string]$location,
        [ValidateSet('celsius', 'fahrenheit')]
        [string]$unit
    )

    $paramUnit = "m"
    if ($unit -eq "fahrenheit") {
        $paramUnit = "u"
    }

    Write-Host "Getting the weather for $location in $unit"
    Invoke-RestMethod "https://wttr.in/$($location)?format=4&$paramUnit"
}

# Let's convert it to an OpenAI function call spec:
$fn = ConvertFrom-FunctionDefinition (Get-Command Get-CurrentWeather)

$fn | ConvertTo-Json -Depth 5
```

`ConvertFrom-FunctionDefinition` takes a PowerShell function  as input and returns an OpenAI function call spec. 

The above example will output the following JSON:

```json
{
  "name": "Get-CurrentWeather",
  "description": "Gets the current weather for a location",
  "parameters": {
    "type": "object",
    "properties": {
      "location": {
        "type": "string",
        "description": "The location to get the weather for"
      },
      "unit": {
        "type": "string",
        "description": "not supplied",
        "enum": [
          "celsius",
          "fahrenheit"
        ]
      }
    },
    "required": [
      "location",
      "unit"
    ]
  }
}
```

## Polyglot Interactive Notebooks

Check out the end-to-end example:

| Notebook Name and Link | Description |
| --- | --- |
| [How-To-Call-Functions-With-Chat-Models.ipynb](Notebooks/How-To-Call-Functions-With-Chat-Models.ipynb)| This notebook covers how to use the Chat Completions API in combination with external functions to extend the capabilities of GPT models. |

## PowerShell Functions

| Function | Description |
| --- | --- |
| ConvertFrom-FunctionDefinition | Converts a PowerShell function definition to an OpenAI function call spec. |
| ConvertTo-OpenAIFunctionSpec | Converts a PowerShell function call spec to an OpenAI function call spec. |
| ConvertTo-OpenAIFunctionSpecDataType | Converts a PowerShell data type to an OpenAI function call spec data type. |
| Get-ChatCompletion | Calls the OpenAI API to get a completion for a chat model. |
| Get-FunctionDefinition | Gets the definition of a PowerShell function. |
| Get-OpenAISpecDescriptions | Gets the descriptions of the OpenAI function call spec. |