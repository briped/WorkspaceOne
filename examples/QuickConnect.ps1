<#PSScriptInfo
.VERSION
2026.02.22.0

.GUID
abff454c-6dd9-40f2-ab05-ee7f7008466b

.AUTHOR
Brian Schmidt Pedersen

.COMPANYNAME
N/A

.COPYRIGHT
(c) Brian Schmidt Pedersen. All rights reserved.

.LICENSEURI
https://raw.githubusercontent.com/briped/WorkSpaceOne/main/LICENSE

.PROJECTURI
https://github.com/briped/WorkspaceOne

.RELEASENOTES
2026.02.22.0
+ Initial version
#>
<#
.SYNOPSIS
Tests and updates stored API configurations.

.DESCRIPTION
Attempts to connect to API using previously exported configuration.
Prompts for updated credentials or API key if connection response indicates that they are incorrect.

The idea is for Workspace ONE admins to be able to simply open a PowerShell console and run this script, to work with the PowerShell module

.NOTES
TODO
.EXAMPLE
TODO
#>
$ParentDir = ([System.IO.DirectoryInfo]$PSScriptRoot).Parent
. $(Join-Path -Path $ParentDir -ChildPath 'shared.ps1')
$Manifest = [System.IO.FileInfo](Join-Path -Path (Join-Path -Path $ParentDir -ChildPath 'pwshModule') -ChildPath 'WorkspaceOneShell.psd1')
Import-Module -Force -Name $Manifest

# Simple secure credential storage and checking.
$EnvHome = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
if ($IsLinux -or $IsMacOS) { $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME') }
$ConfigFile = [System.IO.FileInfo](Join-Path -Path $EnvHome -ChildPath ".ws1config.xml")
if (Test-Path -PathType Leaf -Path $ConfigFile) {
    $ApiConfig = Import-Ws1ApiConfig -PassThru -Path $ConfigFile
    try {
        $ApiInfo = Get-Ws1ApiInfo
    }
    catch {
        if ($null -eq $_.ErrorDetails.Message -or !($_.ErrorDetails.Message | Test-Json)) {
            Write-Error -Message $_ -ErrorAction Stop
        }
        $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        switch ($ErrorDetails.errorCode) {
            1005 {
                Write-Host "Username or password is incorrect. Please re-enter credentials." -ForegroundColor Red
                $ApiConfig.Credential = Get-Credential
                break
            }
            1013 {
                Write-Host "API key incorrect or insufficient permissions. Try re-entering the API key." -ForegroundColor Red
                $ApiConfig.ApiKey = Read-Host -AsSecureString -Prompt 'API key'
                break
            }
            Default {
                Write-Error -Message "Unexpected error: $($ErrorDetails | ConvertTo-Json -Compress)" -ErrorAction Stop
            }
        }
        New-Ws1ApiConfig @ApiConfig
    }
    Remove-Variable -Force -Name ApiConfig -ErrorAction SilentlyContinue
}
else { New-Ws1ApiConfig }
if (!$ApiInfo) { Export-Ws1ApiConfig -Path $ConfigFile }
