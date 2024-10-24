<#
.SYNOPSIS
Searches for organization groups using the query information provided.

.DESCRIPTION
Search organization by the given parameter.

.NOTES
get /groups/search
[ base url: /API/system , api version: 1 ]

.PARAMETER name
The OrganizationGroup name, such as "Global".
query	string

.PARAMETER type
The OrganizationGroup type. (eg. "Container","Customer","Partner").
query	string

.PARAMETER groupid
The organization group identifier[Activation code] to search for.[Exact match is performed for this attribute].
query	string

.PARAMETER orderby
Orders the results based on this attribute-value[Valid values are: Id/Name/GroupId/LocationGroupType].
query	string

.PARAMETER page
Specific page number to get. 0 based index.
query	integer

.PARAMETER pagesize
Maximum records per page. Default 500.
query	integer

.PARAMETER sortorder
Sorting order. Allowed values are ASC or DESC. Defaults to ASC if this attribute is not specified.
query	string

.LINK
.EXAMPLE
#>
function Find-OrganizationGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Name
        ,
        [Parameter()]
        [string]
        $Type
        ,
        [Parameter()]
        [string]
        $GroupId
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
        [ValidateSet('LastSeen', 'Ownership', 'Platform', 'DeviceId')]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Script:Config.ApiUrl)/system/groups/search"
    $Data = @{}
    if ($Name) { $Data.name = $Name }
    if ($Type) { $Data.type = $Type }
    if ($GroupId) { $Data.groupId = $GroupId }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($OrderBy) { $Data.orderby = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 2
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes)"
    $Response = Invoke-ApiRequest @Splattributes
    $Response.LocationGroups
}
