<#
.SYNOPSIS
Search and retrieve details for purchased applications.

.DESCRIPTION
Application details, its assignments, deployment parameters are displayed.

.PARAMETER Name
Application Name, for example - AngryBirds.

.PARAMETER Assigned
Flag to indicate whether the app is assigned or not, for example - true.

.PARAMETER BundleId
BundleId/PackageId, for example - xyz.Angrybirds.com.

.PARAMETER LocationGroupId
LocationGroup Identifier, for example - 777.

.PARAMETER OrganizationGroupUuid
OrganizationGroup Identifier.

.PARAMETER Model
Device Model, for example - iPhone.

.PARAMETER Status
Application Status, for example - Active.

.PARAMETER Platform
The Application Platform, for example - Apple.

.PARAMETER Page
Specific page number to get. 0 based index.

.PARAMETER PageSize
Maximumm records per page. Default 500.

.PARAMETER OrderBy
Orderby column name, for example - applicationname.

.NOTES
.EXAMPLE
#>
function Find-PurchasedApp {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('AppName', 'ApplicationName')]
        [string]
        $Name
        ,
        [Parameter()]
        [switch]
        $Assigned
        ,
        [Parameter()]
        [string]
        $BundleId
        ,
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string]
        $Model
        ,
        [Parameter()]
        [string]
        $Status
        ,
        [Parameter()]
        [string]
        $Platform
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
    )
    $Uri = "$($Config.ApiUrl)/mam/apps/purchased/search"
	$Data = @{}
    if ($Name) { $Data.applicationName = [uri]::EscapeDataString($Name) }
    if ($Assigned) { $Data.isAssigned = $Assigned }
    if ($BundleId) { $Data.bundleId = $BundleId }
    if ($LocationGroupId -and $LocationGroupId -gt 0) { $Data.locationGroupId = $LocationGroupId }
    if ($OrganizationGroupUuid) { $Data.organizationGroupUuid = $OrganizationGroupUuid }
    if ($Model) { $Data.model = $Model }
    if ($Status) { $Data.status = $Status }
    if ($Platform) { $Data.platform = $Platform }
    if ($Page -and $Page -gt 0) { $Data.startIndex = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    if ($OrderBy) { $Data.orderBy = $OrderBy }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Application
}