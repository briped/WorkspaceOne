<#PSScriptInfo
.VERSION
2025.2.21.0

.GUID
ebd1f179-cf89-4df0-bb9f-3835f335a714

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
2025.1.6.0
+ Initial version

2025.1.9.0
+ Added logging
* Fixes

2025.2.21.0
* Refactoring. Moving environment specific code to external files/scripts. (untested)
#>
<#
.SYNOPSIS
Move user(s) to a new organization group.

.DESCRIPTION
Takes one or more usernames and an organisation (name to search for).

.NOTES
TODO
.EXAMPLE
TODO
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    # User to be moved.
    [Parameter(Mandatory = $true)]
    [string[]]
    $User
    ,
    # Target organization group.
    [Parameter(Mandatory = $true)]
    [string]
    $OrganizationGroup
)
# dot-source config.
. $(Join-Path -Path $PSScriptRoot -ChildPath '.config.ps1')
# dot-source shared code.
. $(Join-Path -Path $PSScriptRoot -ChildPath 'shared.ps1')
WriteLog -Message "INFO! Started $($ThisScript.Name)"

Import-Module -Force -Name $Config.Manifest
# Iterate through all organisations defined in the config.
$Api = $Config.API[0]
if ($VerbosePreference -ne 'SilentlyContinue' -or $Visual) {
    Write-Host "Accessing API for " -NoNewline -ForegroundColor Cyan
    Write-Host $Api.LocationGroupId -NoNewline -ForegroundColor Yellow
    Write-Host "." -ForegroundColor Cyan
}
# Authenticate to the current organisation API.
$Attributes = $Api.Attributes
New-Ws1ApiConfig @Attributes
try {
    New-Ws1ApiConfig @Attributes
}
catch {
    $LogMessage = "ERROR! New-Ws1ApiConfig $($Attributes | ConvertTo-Json -Compress). Error: $($_)"
    WriteLog -Message $LogMessage
    Write-Error -Message $LogMessage -ErrorAction Stop
}
try {
    $Org = Find-Ws1OrganizationGroup -Name $OrganizationGroup
}
catch {
    $LogMessage = "ERROR! Find-Ws1OrganizationGroup -Name '$($OrganizationGroup)'. Error: $($_)"
    WriteLog -Message $LogMessage
    Write-Error -Message $LogMessage -ErrorAction Stop
}
if ($null -ne $Org.Id -and $Org.Id.Count -ne 1) {
    $LogMessage = "ERROR! Find-Ws1OrganizationGroup -Name '$($OrganizationGroup)' returned $($Org.Id.Count) results (expected 1)."
    WriteLog -Message $LogMessage
    Write-Error -Message $LogMessage -ErrorAction Stop
}
Write-Verbose -Message "'Find-Ws1OrganizationGroup -Name $($OrganizationGroup)': $($Org | ConvertTo-Json -Compress)"
foreach ($u in $User) {
    try {
        $Device = Find-Ws1Device -User $u.Trim()
    }
    catch {
        $LogMessage = "ERROR! Find-Ws1Device -User $($u). Error: $($_)"
        WriteLog -Message $LogMessage
        Write-Error -Message $LogMessage -ErrorAction Stop
    }
    if (!$Device) {
        $LogMessage = "INFO! No devices found for user '$($u)'. Skipping."
        WriteLog -Message $LogMessage
        Write-Verbose -Message $LogMessage
        continue
    }
    foreach ($d in $Device) {
        $DeviceLogData = $d | Select-Object -Property UserName,LocationGroupName,Model,Udid,SerialNumber,MacAddress,Imei | ConvertTo-Json -Compress
        $LogMessage = "Setting organizationgroup to '$($Org.Name)' for device '$($DeviceLogData)'."
        WriteLog -Message $LogMessage
        Write-Verbose -Message $LogMessage
        try {
            Set-Ws1DeviceOrganizationGroup -OrganizationGroupId $Org.Id -IdType Udid -Id $d.Udid
        }
        catch {
            $LogMessage = "ERROR! Set-Ws1DeviceOrganizationGroup -OrganizationGroupId $($Org.Id) -IdType Udid -Id $($d.Udid). Error: $($_)"
            WriteLog -Message $LogMessage
            Write-Error -Message $LogMessage
        }
    }
}
WriteLog -Message "INFO! Finished $($ThisScript.Name)"