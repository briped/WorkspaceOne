<#
.SYNOPSIS
Search User Groups.

.DESCRIPTION
Takes in query parameters to perform a search on the available User Groups.

.PARAMETER Name
Name of the group.

.PARAMETER Type
User Group Type.

.PARAMETER SyncStatus
Sync Status of the User Group.

.PARAMETER MergeStatus
Merge Status of the User Group.

.PARAMETER OrganizationGroupId
Organization Group Identifier.

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
function Find-UserGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [Alias('GroupName', 'USerGroupName')]
        [string]
        $Name
        ,
        [Parameter()]
        [Alias('GroupType', 'UserGroupType')]
        [string]
        $Type
        ,
        [Parameter()]
        [string]
        $SyncStatus
        ,
        [Parameter()]
        [string]
        $MergeStatus
        ,
        [Parameter()]
        [int]
        $OrganizationGroupId
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
    $Uri = "$($Config.ApiUrl)/system/usergroups/search"
	$Data = @{}
    if ($Name) { $Data.groupName = $Name }
    if ($Type) { $Data.userGroupType = $Type }
    if ($OrganizationGroupId -and $OrganizationGroupId -gt 0) { $Data.organizationGroupId = $OrganizationGroupId }
    if ($SyncStatus) { $Data.syncStatus = $SyncStatus }
    if ($MergeStatus) { $Data.mergeStatus = $MergeStatus }
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
    $Response.ResultSet
}