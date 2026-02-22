<#PSScriptInfo
.VERSION
2026.02.19.0

.GUID
b1322417-f0a3-4f5b-802a-e3aca56986b8

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
2026.02.19.0
+ Initial version
#>
<#
.SYNOPSIS
Find devices that are inactive based on specified criteria.

.DESCRIPTION
Finds all devices that matches the specified criteria for being inactive.
Organization Groups or App Bundle-ids can be used to exclude a device from being considered inactive.

The idea of the script is to do inactive device cleanup.

.NOTES
TODO
.EXAMPLE
TODO
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    # Number of days since the device have last been seen, to be considered inactive.
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [int]
    $InactiveDays = 60
    ,
    # List of bundle-ids that will exclude device from being deleted.
    [Parameter()]
    [string[]]
    $ExcludeApp
    ,
    # List of Organization Group IDs that will exclude a device from being deleted.
    [Parameter()]
    [string[]]
    $ExcludeOrganizationGroup
)
$VerbosePreference = 'SilentlyContinue'
# dot-source config.
#. $(Join-Path -Path $PSScriptRoot -ChildPath '.config.ps1')
# dot-source shared code.
. $(Join-Path -Path $PSScriptRoot -ChildPath 'shared.ps1')
$InactiveDate = (Get-Date).AddDays(-$InactiveDays)

# Check if any apps are added to the exclusionlist.
if ($ExcludeApp.Count -gt 0) {
    # Empty array for the device ids to be excluded.
    $ExcludedDeviceIds = @()
    # Loop through each app in the list of exclusions.
    foreach ($BundleId in $ExcludeApp) {
        # Fetch the app details for the specified app.
        Write-Verbose -Message "Find-Ws1PurchasedApp -BundleId '$($BundleId)'."
        $App = Find-Ws1PurchasedApp -BundleId $BundleId
        # App id is stored as an object array, so to be on the safe side we'll iterate through all
        # values in the array, even though it most likely only contains one value.
        $App.Id.Value | ForEach-Object {
            Write-Verbose -Message "Get-Ws1DeviceWithPurchasedApp -PageSize 10000 -Status Installed -ApplicationId $($_)"
            $DevicesWithApp = Get-Ws1DeviceWithPurchasedApp -PageSize 10000 -Status Installed -ApplicationId $_
            Write-Verbose -Message "Adding $($DevicesWithApp.Count) device id's to the exclusion list."
            $ExcludedDeviceIds += $DevicesWithApp
        }
    }
}

# Check if any organizations are added to the exclusionlist.
if ($ExcludeOrganizationGroup.Count -gt 0) {
    # Empty array for the organization group ids to be excluded.
    $ExcludedOrganizationGroups = @()
    # Find all organization groups.
    $OrganizationGroups = Find-Ws1OrganizationGroup
    # Loop through each organisation group in the list of exclusions.
    foreach ($GroupId in $ExcludeOrganizationGroup) {
        # Check if the organisation group exists.
        if ($GroupId -in $OrganizationGroups.GroupId) {
            # The organisation group exists. Select the matching group and add ti the array of excluded organisation groups.
            $OrganizationGroup = $OrganizationGroups | Where-Object { $_.GroupId -eq $GroupId }
            $ExcludedOrganizationGroups += $OrganizationGroup
            # Skip to the next item in the list. Using instead of an else block.
            continue
        }
        # The following is only executed, if the supplied group id isn't found among all the organisation groups.
        # Du a match instead of equal, so we will find any that might have been slightly mistyped.
        $AlternateOrganisationGroups = $OrganizationGroups | Where-Object { $_.GroupId -match $GroupId }
        $ErrorMessage = "The organization group `"$($GroupId)`" was not found using exact matching."
        if ($AlternateOrganisationGroups.Count -gt 0) {
            $ErrorMessage += " These partial matches were found, but will not be used: `"$($AlternateOrganisationGroups -join '", "')`"."
        }
        Write-Warning -Message $ErrorMessage
    }
}

# Pagenumber to start at.
$Page = 0
# Number of items to return per page.
$Size = 500
# Empty array to hold all found items.
$InactiveDevices = @()
do {
    # Find all devices that haven't been seen since the $InactiveDate and return $Size items per page, return pagenumber $Page.
    $Response = Find-Ws1Device -LastSeen $InactiveDate -PageSize $Size -Page $Page
    $Devices = $Response.Devices
    # Check each device if it should be excluded.
    # Add the found devices to the array with all found devices.
    $InactiveDevices += $Devices
    # Increment to the next page.
    $Page++
} while ($Devices.Count -eq $Size)

$DeletableDevices = @()
$ExcludedDevices = @()
foreach ($Device in $InactiveDevices) {
    # Set or reset Skip variable.
    $Exclude = $false
    if ($Device.LocationGroupId.Id.Value -in $ExcludedOrganizationGroups.Id) {
        if ($Device.Id.Value -notin $ExcludedDevices) { $ExcludedDevices += $Device }
        $Exclude = $true
    }
    if ($Device.Id.Value -in $ExcludedDevicIds) {
        if ($Device.Id.Value -notin $ExcludedDevices) { $ExcludedDevices += $Device }
        $Exclude = $true
    }
    if ($Exclude -eq $true) { continue }
    $DeletableDevices += $Device
}
