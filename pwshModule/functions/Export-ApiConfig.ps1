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
    if (!$Path -or !(Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue)) {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        $FileBrowser.InitialDirectory = $OSEnv.Home
        $FileBrowser.FileName = ".ws1config_$($OSEnv.UserHost).xml"
        $FileBrowser.Filter = 'Common Language Infrastructure eXensible Markup Language (*.xml)|*.xml|All files (*.*)|*.*'
        $DialogResult = $FileBrowser.ShowDialog()
        if ($DialogResult -ne 'OK') { return }
        $Path = [System.IO.FileInfo]$FileBrowser.FileName
    }
    $Script:Config | Export-Clixml -Path $Path.FullName
    <#
    .SYNOPSIS
    Export API configuration.

    .DESCRIPTION
    Exports the API configuration to a CliXML file.

    .PARAMETER Path
    The filepath to the CliXML file containing the configuration.

    .NOTES
    .LINK
    .EXAMPLE
    #>
}