<#
.SYNOPSIS
Search of the enrollment users.

.DESCRIPTION
Search for the enrollment users based on search criteria. FirstName, LastName, Email, LocationGroupID, Role, UserName can be used to search the enrollment users.
Paging is supported together with page number and page size.
Sorting is supported together with order by and sort order.
Supported keywords for sorting are UserName, EmailAddress, FirstName, LastName, Name - Sorts by Organization Group Name, Active, EnrollmentUserID.
A list of enrollment users will be present once the call is complete.

.PARAMETER UserName
The enrollment user username to search for.

.PARAMETER FirstName
The enrollment user first name to search for.

.PARAMETER LastName
The enrollment user last name to search for.

.PARAMETER Email
The enrollment user email address to search for.

.PARAMETER Role
The enrollment user role to search for.

.PARAMETER LocationGroupId
The enrollment user location group id to search for.

.PARAMETER Page
Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

.PARAMETER PageSize
Limits the number of search results per page. Defaults to 500.

.PARAMETER OrderBy
Sort results based on given field. One of model, lastseen, ownership, platform, deviceid etc. Defaults to deviceid.

.PARAMETER SortOrder
Sort order of results. One of ASC or DESC. Defaults to ASC.

.NOTES
.EXAMPLE
#>
function Find-User {
    [CmdletBinding(DefaultParameterSetName = 'V1')]
    param(
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName
        ,
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $FirstName
        ,
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $LastName
        ,
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Email
        ,
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Role
        ,
        [Parameter(ParameterSetName = 'V1')]
        [ValidateNotNullOrEmpty()]
        [int]
        $LocationGroupId
        ,
        [Parameter(ParameterSetName = 'V1')]
        [Alias('Start', 'PageStart')]
        [ValidateNotNullOrEmpty()]
        [int]
        $Page
        ,
        [Parameter(ParameterSetName = 'V1')]
        [Alias('Limit')]
        [ValidateNotNullOrEmpty()]
        [int]
        $PageSize
        ,
        [Parameter(ParameterSetName = 'V1')]
        #[ValidateSet('LastSeen', 'Ownership', 'Platform', 'DeviceId')]
        [string]
        $OrderBy
        ,
        [Parameter(ParameterSetName = 'V1')]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
        ,
        [Parameter(Mandatory = $true, ParameterSetName = 'V2')]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter(ParameterSetName = 'V2')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Query
    )
    $Uri = "$($Config.ApiUrl)/system/users/search"
    $Data = @{}
    switch ($PSCmdlet.ParameterSetName) {
        'V1' {
            if ($LocationGroupId) { $Data.lgid = $LocationGroupId }
            if ($Page -and $Page -gt 0) { $Data.page = $Page }
            if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
            if ($OrderBy) { $Data.orderby = $OrderBy }
            if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
            $Version = 1
        }
        'V2' {
            $Data.'organization-group-uuid' = $OrganizationGroupUuid
            if ($Query) { $Data.searchtext = $Query }
            $Version = 2
        }
    }

    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $Version
    }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Splattributes.Uri = "$($Uri)?$($Query -join '&')" }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Splattributes
    if ($Version -eq 1) {
        $Response.Users
    }
    else {
        $Response
    }
}