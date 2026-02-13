function Import-ApiConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
        ,
        [Parameter()]
        [switch]
        $PassThru
    )
    $OSEnv = Get-OSEnvironment
    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        $Path = [System.IO.FileInfo](Join-Path -Path $OSEnv.Home -ChildPath ".ws1config_$($OSEnv.UserHost).xml")
    }
    $Script:Config = Import-Clixml -Path $Path

    if ($PassThru) { $Script:Config }
    <#
    .SYNOPSIS
    Import API configuration.

    .DESCRIPTION
    Imports the API configuration from a CliXML file.

    .PARAMETER Path
    The filepath to the CliXML file containing the configuration.

    .PARAMETER PassThru
    Returns the imported configuration.

    .EXAMPLE
    .NOTES
        .TODO
        .CHANGES
        2026-02-13
        * Updated to store certificate with private key.
    #>
}