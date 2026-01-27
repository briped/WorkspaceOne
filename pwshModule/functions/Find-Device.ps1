function Find-Device {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [Alias('ModelId')]
        [string[]]
        $Model
        ,
        [Parameter()]
        [Alias('DeviceType')]
        [string[]]
        $Platform
        ,
        [Parameter()]
        [ValidateSet('C', 'E', 'S', 'Undefined')]
        [string[]]
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
        ,
        [Parameter()]
        [ValidateSet(1, 2, 3, 4)]
        [int]
        $Version = 1
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User -and $Version -in (1,2,3)) {
        $Data.user = $User
    }

    if ($Model -and $Version -in (1,2)) { $Data.model = $Model }
    if ($Model -and $Version -in (3)) { $Data.model_identifier = $Model }
    if ($Model -and $Version -in (4)) { $Data.device_models = ($Model -as [array]) }

    if ($Platform -and $Version -in (1,2)) { $Data.platform = $Platform }
    if ($Platform -and $Version -in (3)) { $Data.device_type = $Platform }
    if ($Platform -and $Version -in (4)) { $Data.device_types = ($Platform -as [array]) }

    if ($LastSeen -and $Version -in (1,2)) { $Data.lastseen = $LastSeen.ToString('yyyy-MM-dd') }
    if ($LastSeen -and $Version -in (3)) { $Data.last_seen = $LastSeen.ToString('yyyy-MM-dd') }

    if ($Ownership -and $Version -in (1,2,3)) { $Data.ownership = $Ownership }
    if ($Ownership -and $Version -in (4)) { $Data.ownerships = ($Ownership -as [array]) }

    if ($LocationGroupId -and $Version -in (1,2)) { $Data.lgid = $LocationGroupId }
    if ($OrganizationGroupUuid -and $Version -in (3,4)) { $Data.organization_group_uuid = $OrganizationGroupUuid }

    if ($Compliance -and $Version -in (1)) { $Data.compliantstatus = $Compliance }
    if ($Compliance -and $Version -in (2,3,4)) { $Data.compliance_status = $Compliance }

    if ($SeenSince -and $Version -in (1)) { $Data.seensince = $SeenSince.ToString('yyyy-MM-dd') }
    if ($SeenSince -and $Version -in (2,3)) { $Data.seen_since = $SeenSince.ToString('yyyy-MM-dd') }

    if ($Page -and $Page -gt 0) { $Data.page = $Page }

    if ($PageSize -and $PageSize -gt 0 -and $Version -in (1,2)) { $Data.pagesize = $PageSize }
    if ($PageSize -and $PageSize -gt 0 -and $Version -in (3,4)) { $Data.page_size = $PageSize }

    if ($OrderBy -and $Version -in (1,2)) { $Data.orderby = $OrderBy }
    if ($OrderBy -and $Version -in (3)) { $Data.order_by = $OrderBy }
    if ($OrderBy -and $Version -in (4)) { $Data.sort_by = $OrderBy }

    if ($SortOrder -and $SortOrder -ne 'ASC' -and $Version -in (1,2)) { $Data.sortorder = $SortOrder }
    if ($SortOrder -and $SortOrder -ne 'ASC' -and $Version -in (3,4)) { $Data.sort_order = $SortOrder }

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $Version
    }
    if ($Version -in (1,2,3)) {
        $Query = @()
        foreach ($k in $Data.Keys) {
            $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
        }
        if ($Query.Count -gt 0) { $Attributes.Uri = "$($Uri)?$($Query -join '&')" }
    }
    if ($Version -in (4)) {
        $Body = $Data | ConvertTo-Json -Compress
        $Attributes.Body = $Body
        $Attributes.Method = 'POST'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Find relevant devices using various criteria.

    .DESCRIPTION
    Returns details of relevant devices belonging to an enrollment user matching specified criteria, where results are ranked/sorted using the specified orderby criteria with maximum pagesize limit of 500. 

    .PARAMETER User
    Filters devices based on enrolled username.

    .PARAMETER Model
    Filters devices based on model. For example iPhone.

    .PARAMETER Platform
    Filters devices based on platform. For example Apple.

    .PARAMETER LastSeen
    Filters devices based on the date when they were last seen.
    Valid DateTime formats : 
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

    .PARAMETER Ownership
    Filters devices based on ownership type. One of C, E, S or Undefined.

    .PARAMETER LocationGroupId
    Limits the search to given OrganizationGroup. Defaults to admin's OrganizationGroup.

    .PARAMETER Compliant
    Filters devices based on specified compliant status. Possible values are true (for Compliant) and false (for NonCompliant).

    .PARAMETER SeenSince
    Filters devices based on the date when they were seen after given date.
    Valid DateTime formats : 
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

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .PARAMETER OrderBy
    Sort results based on given field. One of model, lastseen, ownership, platform, deviceid etc. Defaults to deviceid.

    .PARAMETER SortOrder
    Sort order of results. One of ASC or DESC. Defaults to ASC.

    .NOTES
    Changes:
     * 2026-01-26: Changed from returning just devices, to returning the full result, including total count.
        
    .EXAMPLE
    #>
}