<#
.SYNOPSIS
Searches the device using the query information provided.

.DESCRIPTION
Get basic information about the device with maximum pagesize limit of 500. If page size is greater than the maximum limit, it will return the first 500 records.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

[ base url: /API/mdm , api version: 3 ]
get /devices/search

.PARAMETER user
Username the device enrolled under.
query	string

.PARAMETER model_identifier
Partial search by device model. Search by MD20 would return device with model MD200LL.
query	string

.PARAMETER device_type
Device platform type, i.e. Apple, Android, WindowsPC, etc.
query	string

.PARAMETER last_seen
Last seen date string.
query	date-time

.PARAMETER ownership
Device ownership.
query	string

.PARAMETER organization_group_uuid
Organization Group to be searched. User's OG is considered if not specified.
query	string

.PARAMETER compliance_status
Compliance status.
query	string

.PARAMETER seen_since
Specifies the date filter for device search, which retrieves the devices that are seen after this date.
query	date-time

.PARAMETER page
Specific page number to get. 0 based index.
query	integer

.PARAMETER page_size
Maximum records per page. Default 500.
query	integer

.PARAMETER order_by
Order by column name.
query	string

.PARAMETER sort_order
Sorting order. Values ASC or DESC. Defaults to ASC.
query	string

.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.

.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function Find-DeviceV3 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [string]
        $Ownership
        ,
        [Parameter()]
        [string]
        $Compliance
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string]
        $ModelId
        ,
        [Parameter()]
        [ValidateSet('Apple', 'Android')]
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
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($Compliance) { $Data.compliance_status = $Compliance }
    if ($OrganizationGroupUuid) { $Data.organization_group_uuid = $OrganizationGroupUuid }
    if ($ModelID) { $Data.model_identifier = $ModelID }
    if ($Platform) { $Data.device_type = $Platform }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.page_size = $PageSize }
    if ($OrderBy) { $Data.order_by = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sort_order = $SortOrder }
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
