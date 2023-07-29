Import-Module "$PSScriptRoot\..\PowerShellAI.Functions.psd1" -Force

Describe "Get-ChatCompletion" -Tag Get-ChatCompletion {
    It 'Test if it Get-ChatCompletion exists' {
        $actual = Get-Command Get-ChatCompletion -ErrorAction SilentlyContinue

        $actual | Should -Not -BeNullOrEmpty
    }

    It 'Test if Get-ChatCompletion has the correct parameters ' {
        $actual = Get-Command Get-ChatCompletion -ErrorAction SilentlyContinue

        $actual.Parameters.ContainsKey('messages') | Should -Be $true
        $actual.Parameters.ContainsKey('functions') | Should -Be $true
        $actual.Parameters.ContainsKey('function_call') | Should -Be $true
        $actual.Parameters.ContainsKey('model') | Should -Be $true
    }
}