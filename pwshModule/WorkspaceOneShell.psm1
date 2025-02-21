<#PSScriptInfo

.VERSION 2024.10.7.1

.GUID d16a1243-3ecb-403a-af51-8701bddf4cb6

.AUTHOR Brian Schmidt Pedersen

.COMPANYNAME N/A

.COPYRIGHT (c) Brian Schmidt Pedersen. All rights reserved.

.TAGS 

.LICENSEURI https://raw.githubusercontent.com/briped/WorkSpaceOneShell/main/LICENSE

.PROJECTURI https://github.com/briped/WorkspaceOneShell

.ICONURI https://play-lh.googleusercontent.com/SA6Tj62xWYGBNoFjV1dXNNv9nhjQ7Zo4fQZQSe11V043bBe-urbd0YNsH5LVT5O32cA

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


.PRIVATEDATA


#>
<#

.DESCRIPTION
Workspace ONE API PowerShell module for automating WS1.

.SYNOPSIS
WorkspaceONE API cmdlets
.NOTES
TODO
.EXAMPLE
TODO
#>
New-Variable -Force -Scope Script -Name Config -Value $null

$FunctionsPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'
Get-ChildItem -File -Path $FunctionsPath -Filter '*.ps1' | 
    Where-Object { $_.BaseName -notmatch '(^\.|\.dev$|\.test$)' } | 
    ForEach-Object {
        . $_.FullName
    }