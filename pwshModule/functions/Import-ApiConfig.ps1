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
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.OpenFileDialog
        $FileBrowser.InitialDirectory = $OSEnv.Host
        $FileBrowser.FileName = ".ws1config_$($OSEnv.UserHost).xml"
        $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*.*)|*.*'
        $FileBrowser.ShowDialog() | Out-Null
        $Path = [System.IO.FileInfo]$FileBrowser.FileName
    }
    $Script:Config = Import-Clixml -Path $Path.FullName
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

    .NOTES
    .EXAMPLE
    #>
}