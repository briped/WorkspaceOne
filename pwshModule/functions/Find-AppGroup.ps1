function Find-AppGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('GroupName', 'AppGroupName', 'ApplicationGroupName')]
        [string]
        $Name
        ,
        [Parameter()]
        [Alias('GroupType', 'AppGroupType', 'ApplicationGroupType')]
        [string]
        $Type
        ,
        [Parameter()]
        [int]
        $OrganizationGroupId
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
    $Uri = "$($Config.ApiUrl)/mam/apps/appgroups/search"
	$Data = @{}
    if ($Name) { $Data.appGroupName = $Name }
    if ($Type) { $Data.appGroupType = $Type }
    if ($OrganizationGroupId -and $OrganizationGroupId -gt 0) { $Data.organizationGroupId = $OrganizationGroupId }
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
    $Response = Invoke-ApiRequest @Splattributes
    $Response.AppGroups
    <#
    .SYNOPSIS
    Searches for the Application Groups based on the query information provided.

    .DESCRIPTION
    Takes in query parameters to perform a search on the available Application Groups.

    .PARAMETER Name
    App Group name. Example = "Apple MDM Applications".

    .PARAMETER Type
    Application group type [Whitelist, Blacklist, Required, MDMApplication, COPEAllowlist, COPEDenylist].

    .PARAMETER OrganizationGroupId
    OrganizationGroup Id. Example = "7".

    .PARAMETER Platform
    The Application Platform. Example = "Android".

    .PARAMETER Page
    Page number.

    .PARAMETER PageSize
    Records per page.

    .PARAMETER OrderBy
    Orderby column name. Example = "ApplicationCount".

    .NOTES
    .LINK
    .EXAMPLE
    #>
}