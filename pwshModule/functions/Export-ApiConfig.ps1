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
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Export-ApiConfig: `$Path is not set."
        $EnvHome = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
        if ($IsLinux -or $IsMacOS) { $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME') }
        $Path = [System.IO.FileInfo](Join-Path -Path $EnvHome -ChildPath ".ws1config.xml")
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Export-ApiConfig: Setting `$Path to: ${Path}"
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