New-Variable -Force -Scope Script -Name Config -Value $null

$FunctionsPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'
Get-ChildItem -File -Path $FunctionsPath -Filter '*.ps1' | 
    Where-Object { $_.BaseName -notmatch '(^\.|\.dev$|\.test$)' } | 
    ForEach-Object {
        . $_.FullName
    }