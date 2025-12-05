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
        $StoreType = 'Public'
        ,
        [Parameter()]
        [ValidateSet('App', 'Book')]
        [string]
        $MediaType = 'App'
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
        [ValidateSet('Active', 'Inactive')]
        [string]
        $Status = 'Active'
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
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Attributes
    $Response.Application
    <#
    .SYNOPSIS
    Search and retrieve details for both internal and external applications or books

    .DESCRIPTION
    Searches for an application or book, given filters including type, name, category and organization group id. Returns a list of applications or books that match the criteria with details of each application/book.

    .PARAMETER Name
    Application Name.

    .PARAMETER MediaType
    The Product Type - App or Book.

    .PARAMETER StoreType
    Type of the application. (Internal/Public).

    .PARAMETER ProductComponentAppsOnly
    Request query to include apps added under Products Staging and Provisioning.

    .PARAMETER Category
    The Application Category.

    .PARAMETER BundleId
    BundleId/PackageId.

    .PARAMETER LocationGroupId
    LocationGroup Identifier.

    .PARAMETER Model
    Device Model.

    .PARAMETER Status
    Application Status.

    .PARAMETER Platform
    The Application Platform.

    .PARAMETER WinAppType
    The application sub type for windows platforms.

    .PARAMETER Children
    Flag to indicate if apps from child og's should be included or not.

    .PARAMETER Parents
    Flag to indicate if apps from parent og's should be included or not.

    .PARAMETER Distinct
    Flag to indicate if distinct applications at an OG should be returned by the API. If two versions of an application have the same name, then the application with the greater version will be returned.

    .PARAMETER ExcludeDeviceCount
    Flag to indicate if assigned or installed device counts for apps should be excluded or not.

    .PARAMETER Page
    Page number.

    .PARAMETER PageSize
    Records per page.

    .PARAMETER OrderBy
    Orderby column name.

    .NOTES
    .LINK
    .EXAMPLE
    #>
}