<#
.SYNOPSIS
Search and retrieve details for purchased applications.

.DESCRIPTION
Application details, its assignments, deployment parameters are displayed.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

get /apps/purchased/search
[ base url: /API/mam , api version: 1 ]

.PARAMETER applicationname
Application Name, for example - AngryBirds.
query	string

.PARAMETER isassigned
Flag to indicate whether the app is assigned or not, for example - true.
query	string

.PARAMETER bundleid
BundleId/PackageId, for example - xyz.Angrybirds.com.
query	string

.PARAMETER locationgroupid
LocationGroup Identifier, for example - 777.
query	string

.PARAMETER organizationgroupuuid
OrganizationGroup Identifier.
query	string

.PARAMETER model
Device Model, for example - iPhone.
query	string

.PARAMETER status
Application Status, for example - Active.
query	string

.PARAMETER platform
The Application Platform, for example - Apple.
query	string

.PARAMETER page
Specific page number to get. 0 based index.
query	string

.PARAMETER pagesize
Maximumm records per page. Default 500.
query	string

.PARAMETER orderby
Orderby column name, for example - applicationname.
query	string

.LINK
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
        [string]
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
        [ValidateSet('iPhone', 'iPad')]
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
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Application
}
