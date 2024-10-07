function Get-DateVersion {
    [CmdletBinding()]
    param(
        [Parameter()]
        [version]
        $Version
    )
    # Generate a new DateVersion:
    $NewVersion = [version](Get-Date -Format 'yyyy.M.d.0')
    # Return new DateVersion if ...
    # No version:
    if (!$Version -or 
        # Not a valid DateVersion string:
        $Version.ToString() -notmatch '^(19[3-9][0-9]|2[01][0-9]{2})\.(1[0-2]|[0-9])\.(3[01]|[12]?[0-9])' -or 
        # Major, Minor or Build are not the same:
        $Version.Major -ne $NewVersion.Major -or 
        $Version.Minor -ne $NewVersion.Minor -or 
        $Version.Build -ne $NewVersion.Build) { return $NewVersion }
    # Increment the Revision by 1:
    $Revision = $Version.Revision + 1
    # Return an updated DateVersion:
    [version]::new($Version.Major, $Version.Minor, $Version.Build, $Revision)
}
$ModuleFile = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath 'WorkspaceOneShell.psm1')
if (!$ModuleFile.Exists) { throw "Module '$($ModuleFile.FullName)' does not exist." }
# Import module:
$Module = Import-Module -PassThru -Name $ModuleFile
# Get an array of approved verbs:
$ApprovedVerbs = (Get-Verb).Verb
# Only export functions that have approved verbs:
$FunctionsToExport = @()
foreach ($f in $Module.ExportedFunctions.Values) {
    if ($f.Verb -notin $ApprovedVerbs) { continue }
    $FunctionsToExport += $f.Name
}
Remove-Module -Name $ModuleFile -ErrorAction SilentlyContinue
$ManifestFile = [System.IO.FileInfo](Join-Path -Path $PSScriptRoot -ChildPath "$($ModuleFile.BaseName).psd1")
$Splattributes = @{
    Path                 = $ManifestFile
    RootModule           = $ModuleFile.Name
    ModuleVersion        = Get-DateVersion
    Guid                 = (New-Guid).Guid
    Author               = 'Brian Schmidt Pedersen'
    CompanyName          = 'N/A'
    Copyright            = '(c) Brian Schmidt Pedersen. All rights reserved.'
    LicenseUri           = 'https://raw.githubusercontent.com/briped/WorkSpaceOneShell/main/LICENSE'
    Description          = 'Workspace ONE API PowerShell module for automating WS1.'
    DefaultCommandPrefix = 'Ws1'
    FunctionsToExport    = $FunctionsToExport
    ProjectUri           = 'https://github.com/briped/WorkspaceOneShell'
    IconUri              = 'https://play-lh.googleusercontent.com/SA6Tj62xWYGBNoFjV1dXNNv9nhjQ7Zo4fQZQSe11V043bBe-urbd0YNsH5LVT5O32cA'
}
$NowString = (Get-Date).ToString('o') -replace "[$([regex]::Escape([System.IO.Path]::GetInvalidFileNameChars() -join ''))]"
# Create or update the ModuleManifest:
if (!$ManifestFile.Exists) {
    New-ModuleManifest @Splattributes
}
else {
    # Import existing ModuleManifest into $Manifest variable:
    Import-LocalizedData -BindingVariable Manifest -FileName $ManifestFile.Name
    # Set or update existing attributes:
    $Splattributes.ModuleVersion = if ($Manifest -and $Manifest.ModuleVersion) { Get-DateVersion -Version $Manifest.ModuleVersion } else { Get-DateVersion }
    $Splattributes.Guid = if ($Manifest -and $Manifest.GUID) { $Manifest.GUID } else { (New-Guid).Guid }
    # Update the existing ModuleManifest:
    Copy-Item -Path $ManifestFile -Destination ".$($ManifestFile.BaseName)_$($NowString)$($ManifestFile.Extension)"
    Update-ModuleManifest @Splattributes
}
# Don't continue if the ModfuleManifest cannot be validated:
if (!(Test-ModuleManifest -Path $ManifestFile)) { break }


## Set PSScriptFileInfo
## PSScriptFileInfo is not really needed (or supported for modules) when using ModfuleManiest, however
## I like having that information in the module file as well.
# Copy the ModuleFile to a ScriptFile:
$ScriptFile = Copy-Item -PassThru -Path $ModuleFile.Name -Destination "$($ModuleFile.BaseName).ps1"
# Remove attributes that that are not compatible with PSScriptFileInfo Cmdlets:
$PSScriptFileInfoParameters = (Get-Command -Name Update-PSScriptFileInfo).Parameters.Keys
$Scripttributes = @{}
foreach ($Attribute in $Splattributes.Keys) {
    if ($Attribute -notin $PSScriptFileInfoParameters) { continue }
    $Scripttributes.${Attribute} = $Splattributes.${Attribute}
}
# Add or update the PSScriptFileInfo attributes:
$Scripttributes.Path = $ScriptFile
$Scripttributes.Version = $Splattributes.ModuleVersion
$Scripttributes.Guid = $Splattributes.Guid

# Create or update the PSScriptFileInfo:
if (!(Test-PSScriptFileInfo -Path $ScriptFile)) {
    New-PSScriptFileInfo @Scripttributes
}
else {
    Update-PSScriptFileInfo @Scripttributes
}
# Move the ScriptFile back to the ModuleFile:
if (Test-PSScriptFileInfo -Path $ScriptFile) {
    Copy-Item -Path $ModuleFile -Destination ".$($ModuleFile.BaseName)_$($NowString)$($ModuleFile.Extension)"
    Move-Item -Force -Path $ScriptFile -Destination $ModuleFile
}