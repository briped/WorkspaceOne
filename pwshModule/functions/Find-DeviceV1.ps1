function Find-DeviceV1 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [ValidateSet('iPhone', 'iPad')]
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
        [bool]
        $Compliant
        ,
        [Parameter()]
        [int]
        $LocationGroupId
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
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User) { $Data.user = $User }
    if ($Model) { $Data.model = $Model }
    if ($Platform) { $Data.platform = $Platform }
    if ($LastSeen) { $Data.lastseen = $LastSeen.ToString('yyyy-MM-dd') }
    if ($Ownership) { $Data.ownership = $Ownership }
    if ($LocationGroupId) { $Data.lgid = $LocationGroupId }
    if ($Compliance) { $Data.compliantstatus = $Compliance }
    if ($SeenSince) { $Data.seensince = $SeenSince.ToString('yyyy-MM-dd') }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($OrderBy) { $Data.orderby = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Devices
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

    .PARAMETER User
    Filters devices based on enrolled username.

    .PARAMETER Model
    Filters devices based on model. For example iPhone.

    .PARAMETER Platform
    Filters devices based on platform. For example Apple.

    .PARAMETER LastSeen
    Filters devices based on the date when they were last seen.

    .PARAMETER Ownership
    Filters devices based on ownership type. One of C, E, S or Undefined.

    .PARAMETER LocationGroupId
    Limits the search to given OrganizationGroup. Defaults to admin's OrganizationGroup.

    .PARAMETER Compliant
    Filters devices based on specified compliant status. Possible values are true (for Compliant) and false (for NonCompliant).

    .PARAMETER SeenSince
    Filters devices based on the date when they were seen after given date.

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .PARAMETER OrderBy
    Sort results based on given field. One of model, lastseen, ownership, platform, deviceid etc. Defaults to deviceid.

    .PARAMETER SortOrder
    Sort order of results. One of ASC or DESC. Defaults to ASC.

    .NOTES
    [ base url: /API/mdm , api version: 1 ]
    get /devices/search

    .EXAMPLE
    #>
}