# PowerShell AI Functions

Function calling allows developers to more reliably get structured data back from the OpenAI GPT model.

## Introduction

`PowerShellAI.Functions` is a PowerShell module designed to work as a bridge between PowerShell functions and OpenAI. It provides an array of functionalities to convert PowerShell function metadata into OpenAI function call specifications, and also includes functions to directly call the OpenAI REST API.

This module is intended to make it easy for developers to integrate AI capabilities into their PowerShell scripts, without needing deep knowledge of the OpenAI API's specifics.

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

## Notebooks

Check out the end-to-end. Create a function, call the OpenAI API, and use the function call.
- [How-To-Call-Functions-With-Chat-Models.ipynb](Notebooks/How-To-Call-Functions-With-Chat-Models.ipynb)
