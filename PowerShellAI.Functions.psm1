Get-ChildItem $PSScriptRoot\Public *.ps1 | ForEach-Object {
    . $_.FullName
}