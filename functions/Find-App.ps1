<#
.SYNOPSIS
Search and retrieve details for both internal and external applications or books

.DESCRIPTION
Searches for an application or book, given filters including type, name, category and organization group id. Returns a list of applications or books that match the criteria with details of each application/book.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

get /apps/search
[ base url: /API/mam , api version: 1 ]

.PARAMETER type
The Product Type - App or Book.
query	string

.PARAMETER applicationtype
Type of the application. (Internal/Public).
query	string

.PARAMETER applicationname
Application Name.
query	string

.PARAMETER productComponentAppsOnly
Request query to include apps added under Products Staging and Provisioning.
query	string

.PARAMETER category
The Application Category.
query	string

.PARAMETER bundleid
BundleId/PackageId.
query	string

.PARAMETER locationgroupid
LocationGroup Identifier.
query	string

.PARAMETER model
Device Model.
query	string

.PARAMETER status
Application Status.
query	string

.PARAMETER platform
The Application Platform.
query	string

.PARAMETER winapptype
The application sub type for windows platforms.
query	string

.PARAMETER includeAppsFromChildOgs
Flag to indicate if apps from child og's should be included or not.
query	boolean

.PARAMETER IncludeAppsFromParentOgs
Flag to indicate if apps from parent og's should be included or not.
query	boolean

.PARAMETER AppCommandTarget
Application command Targets for Windows Desktop/MacOs.
query	string

.PARAMETER distinctApplicationsPerOg
Flag to indicate if distinct applications at an OG should be returned by the API. If two versions of an application have the same name, then the application with the greater version will be returned.
query	boolean

.PARAMETER excludeAssignedOrInstalledDeviceCount
Flag to indicate if assigned or installed device counts for apps should be excluded or not.
query	boolean

.PARAMETER page
Page number.
query	string

.PARAMETER pagesize
Records per page.
query	string

.PARAMETER orderby
Orderby column name.
query	string

.LINK
.EXAMPLE
#>
function Find-App {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('AppName', 'ApplicationName')]
        [string]
        $Name
        ,
        [Parameter()]
        [ValidateSet('Internal', 'Public')]
        [string]
        $StoreType
        ,
        [Parameter()]
        [ValidateSet('App', 'Book')]
        [string]
        $MediaType
        ,
        [Parameter()]
        [string]
        $ProductComponentAppsOnly
        ,
        [Parameter()]
        [string]
        $Category
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
        [string]
        $WinAppType
        ,
        [Parameter()]
        [switch]
        $Children
        ,
        [Parameter()]
        [switch]
        $Parents
        ,
        [Parameter()]
        [switch]
        $Distinct
        ,
        [Parameter()]
        [switch]
        $ExcludeDeviceCount
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
    $Uri = "$($Config.ApiUrl)/mam/apps/search"
	$Data = @{}
    if ($Name) { $Data.applicationName = $Name }
    if ($MediaType) { $Data.type = $MediaType }
    if ($StoreType) { $Data.applicationType = $StoreType }
    if ($ProductComponentAppsOnly) { $Data.productComponentAppsOnly = $ProductComponentAppsOnly }
    if ($Category) { $Data.category = $Category }
    if ($BundleId) { $Data.bundleId = $BundleId }
    if ($LocationGroupId -and $LocationGroupId -gt 0) { $Data.locationGroupId = $LocationGroupId }
    if ($Model) { $Data.model = $Model }
    if ($Status) { $Data.status = $Status }
    if ($Children) { $Data.includeAppsFromChildOgs = $Children }
    if ($Parents) { $Data.includeAppsFromParentOgs = $Parents }
    if ($Distinct) { $Data.distinctApplicationsPerOg = $Distinct }
    if ($ExcludeDeviceCount) { $Data.excludeAssignedOrInstalledDeviceCount = $ExcludeDeviceCount }
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
