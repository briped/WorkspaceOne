function Export-ApiConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
    )
    $OSEnv = Get-OSEnvironment

    #if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
    if (!$Path) { $Path = [System.IO.FileInfo](Join-Path -Path $OSEnv.Home -ChildPath ".ws1config_$($OSEnv.UserHost).xml") }
    $Script:Config | Export-Clixml -Path $Path
    <#
    .SYNOPSIS
    Export API configuration.

    .DESCRIPTION
    Exports the API configuration to a CliXML file.

    .PARAMETER Path
    The filepath to the CliXML file containing the configuration.

    .EXAMPLE
    .NOTES
        .TODO
        .CHANGES
        2026-02-13
        * Updated to store certificate with private key.
    #>
}