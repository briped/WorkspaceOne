<#
.SYNOPSIS
Find relevant devices using various criteria.

.DESCRIPTION
Returns details of relevant devices belonging to an enrollment user matching specified criteria, where results are ranked/sorted using the specified orderby criteria with maximum pagesize limit of 500. 
If page size is greater than the maximum limit, it will return the first 500 records. 
seensince and lastseen fields accept the following Valid DateTime formats : 
    yyyy/MM/dd, 
    yyyy-MM-dd, 
    MM/dd/yyyy, 
    MM-dd-yyyy, 
    yyyy/MM/dd HH:mm:ss.fff, 
    yyyy-MM-dd HH:mm:ss.fff, 
    MM/dd/yyyy HH:mm:ss.fff, 
    MM-dd-yyyy HH:mm:ss.fff, 
    yyyy/MM/ddTHH:mm:ss.fff, 
    yyyy-MM-ddTHH:mm:ss.fff, 
    MM/dd/yyyyTHH:mm:ss.fff, 
    MM-dd-yyyyTHH:mm:ss.fff, 
    yyyy-MM-dd HH-mm-ss-tt, 
    yyyy-MM-ddTHH-mm-ss-tt.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

[ base url: /API/mdm , api version: 2 ]
get /devices/search

.PARAMETER user	
Filters devices based on enrolled username.
query	string

.PARAMETER model
Filters devices based on model. For example iPhone.
query	string

.PARAMETER platform
Filters devices based on platform. For example Apple.
query	string

.PARAMETER lastseen
Filters devices based on date when they were last seen.
query	date-time

.PARAMETER ownership
Filters devices based on ownership type. One of C, E, S or Undefined.
query	string

.PARAMETER lgid
Limits the search to given OrganizationGroup, defaults to user's OrganizationGroup.
query	integer

.PARAMETER compliance_status
Filters devices based on specified compliance status. Possible values are true (for Compliant) and false (for NonCompliant).
query	string

.PARAMETER seen_since
Filters devices based on the date when they were seen after the given date.
query	date-time

.PARAMETER page
Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return first page.
query	integer

.PARAMETER pagesize
Limits the number of search results per page. Defaults to 500.
query	integer

.PARAMETER orderby
Sort results based on given field. One of model, lastseen, ownership, platform, deviceid etc. Defaults to deviceid.
query	string

.PARAMETER sortorder
Sort order of results. One of ASC or DESC. Defaults to ASC.
query	string

.LINK
Specify a URI to a help page, this will show when Get-Help -Online is used.

.EXAMPLE
Test-MyTestFunction -Verbose
Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function Find-DeviceV2 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [ValidateSet('iPhone'
                    ,'iPad')]
        [string]
        $Model
        ,
        [Parameter()]
        [ValidateSet('Apple', 'Android')]
        [string]
        $Platform
        ,
        [Parameter()]
        [ValidateSet('C', 'E', 'S', 'Undefined')]
        [string]
        $Ownership
        ,
        [Parameter()]
        [string]
        $Compliance
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid # lgid #TODO: Follow-up check if LocationGroupId rather than OrganisationGroupUuid.
        ,
        [Parameter()]
        [datetime]
        $LastSeen
        ,
        [Parameter()]
        [datetime]
        $SeenSince
        ,
        [Parameter()]
        [Alias('Start', 'StartPage')]
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
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User) { $Data.user = $User }
    if ($Model) { $Data.model = $Model }
    if ($Platform) { $Data.platform = $Platform }
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($Compliance) { $Data.compliance_status = $Compliance }
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
    }
    Invoke-ApiRequest @Splattributes
}
