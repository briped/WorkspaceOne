function Export-ApiConfig {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('PSPath')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Path
    )
    if (!$Path) {
        $EnvHome = if ($IsWindows) { [System.Environment]::GetEnvironmentVariable('USERPROFILE') } else { [System.Environment]::GetEnvironmentVariable('HOME') }
        $Path = [System.IO.FileInfo](Join-Path -Path $EnvHome -ChildPath ".ws1config.xml")
    }
    $Script:Config | Export-Clixml -Path $Path
    <#
    .SYNOPSIS
    Export API configuration.

    .DESCRIPTION
    Exports the API configuration to a CliXML file.

    .PARAMETER Path
    The filepath to the CliXML file containing the configuration.
    #>
}