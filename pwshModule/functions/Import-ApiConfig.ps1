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
    if (!$Path) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Import-ApiConfig: `$Path is not set."
        $EnvHome = [System.Environment]::GetEnvironmentVariable('USERPROFILE')
        if ($IsLinux -or $IsMacOS) { $EnvHome = [System.Environment]::GetEnvironmentVariable('HOME') }
        $Path = [System.IO.FileInfo](Join-Path -Path $EnvHome -ChildPath ".ws1config.xml")
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Import-ApiConfig: Setting `$Path to: ${Path}"
    }
    if (!(Test-Path -PathType Leaf -Path $Path)) {
        Write-Error -Message "$($MyInvocation.MyCommand.Name): Import-ApiConfig: Path does not exist: ${Path}" -ErrorAction Stop
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
        Check the imported data before registering to module config.
    #>
}