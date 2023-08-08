Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="GPT Function Call" Height="800" Width="900" WindowStartupLocation="CenterScreen">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="600"/>
            <RowDefinition Height="35"/>
            <RowDefinition Height="35"/>
            <RowDefinition Height="35"/>            
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="35"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <TextBox Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" x:Name="txtCode" TextWrapping="Wrap" AcceptsReturn="True" AcceptsTab="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" />
        <Label Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" x:Name="lblInfo"/>
        <TextBox Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" x:Name="txtMessage" TextWrapping="Wrap" AcceptsReturn="True" AcceptsTab="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" />
        <Button Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="2" x:Name="btnSend" Content="_Send to GPT" />
        <TextBox Grid.Row="0" Grid.Column="2" Grid.RowSpan="4" x:Name="txtResponse" TextWrapping="Wrap" AcceptsReturn="True" AcceptsTab="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" />
    </Grid>
</Window>
"@

function Update-UI {
    $App.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action] {})
}

$app = [Windows.Application]::new()
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$txtCode = $window.FindName("txtCode")
$lblInfo = $window.FindName("lblInfo")
$txtMessage = $window.FindName("txtMessage")
$txtResponse = $window.FindName("txtResponse")
$btnSend = $window.FindName("btnSend")

$lblInfo.Content = "Enter your code in the box above. Message to GPT below. Press the button to send it to GPT" 
$lblInfo.Background = "Cyan"

# $txtMessage.Text = "add 3 and 5"
# $txtMessage.Text = "take the sum of 30 and 23"
# $txtMessage.Text = "40 less 12"
# $txtMessage.Text = "take the sum of 30 and 23 and subtract 12 from it"
$txtMessage.Text = "take the sum of 30 and 23 and subtract 12 from it and double it"

$txtCode.Text = @'
function add {
    <#
        .FunctionDescription
        Add two numbers
        .ParameterDescription a
        first number
        .ParameterDescription b
        second number
    #>
    param(
        [int]$a, 
        [int]$b
    )
    return $a + $b
}

function subtract {
    <#
        .FunctionDescription
        Subtract two numbers
        .ParameterDescription a
        first number
        .ParameterDescription b
        second number
    #>
    param(
        [int]$a, 
        [int]$b
    )
    return $a - $b
}

function multiply {
    <#
        .FunctionDescription
        Multiply two numbers
        .ParameterDescription a
        first number
        .ParameterDescription b
        second number
    #>
    param(
        [int]$a, 
        [int]$b
    )
    return $a * $b
}

'@

function Invoke-GPT {
    param(
        $prompt
    )

    $title = $window.Title
    $window.Title += " - Thinking..."
    $window.Cursor = [System.Windows.Input.Cursors]::Wait

    $txtCode.Text | Invoke-Expression # add functions to PS

    $functions = ConvertTo-OpenAIFunctionSpec -targetCode $txtCode.Text -Raw
    
    $messages = @()
    $messages += (New-ChatMessageTemplate user $prompt)
    
    $txtResponse.Text += "👤" + $prompt + "`n`n"
    Update-UI
    
    $chatResponse = Get-ChatCompletion $messages -functions $functions
    $finishedReason = $chatResponse.choices[0].finish_reason
    
    do {
        if ($chatResponse.choices[0].finish_reason -eq 'function_call') {
            $functionCallArguments = $chatResponse.choices[0].message.function_call.arguments -replace "`n", " "
            $fn = $chatResponse.choices[0].message.function_call.name
        
            $splatArguments = $functionCallArguments | ConvertFrom-Json -AsHashtable

            $result = & $fn @splatArguments
        
            $response = @"
👉Function call: $($chatResponse.choices[0].message.function_call | ConvertTo-Json -Compress)

👍Function result from $($fn): $result
"@
            $txtResponse.Text += $response + "`n`n"
            Update-UI

            $messages += New-ChatMessageTemplate -Role function -Content $result.ToString() -Name $fn    
        }
        
        $chatResponse = Get-ChatCompletion $messages -functions $functions
        $finishedReason = $chatResponse.choices[0].finish_reason
    } until($finishedReason -eq 'stop')

    $txtResponse.Text += "🤖" + $chatResponse.choices[0].message.Content + "`n`n"
    $txtResponse.Text += "--- This has been a good conversation ---" + "`n`n"
    Update-UI
    
    $window.Title = $title
    $window.Cursor = $null
}

$btnSend.Add_Click({ 
        # $txtResponse.Text = $null
        Invoke-GPT $txtMessage.Text 
    })

$window.ShowDialog() | Out-Null