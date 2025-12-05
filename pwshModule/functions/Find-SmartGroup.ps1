function Find-SmartGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Name
        ,
        [Parameter()]
        [int]
        $OrganizationGroupId
        ,
        [Parameter()]
        [int]
        $ManagedBy
        ,
        [Parameter()]
        [datetime]
        $ModifiedAfter
        ,
        [Parameter()]
        [datetime]
        $ModifiedBefore
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
    $Uri = "$($Script:Config.ApiUrl)/mdm/smartgroups/search"
    $Data = @{}
    if ($Name) { $Data.name = $Name }
    if ($OrganizationGroupId) { $Data.organizationgroupid = $OrganizationGroupId }
    if ($ManagedBy) { $Data.managedbyorganizationgroupid = $ManagedBy }
    if ($ModifiedAfter) { $Data.modifiedfrom = $ModifiedAfter.ToString('yyyy-MM-ddTHH:mm:ss.fff') }
    if ($ModifiedBefore) { $Data.modifiedtill = $ModifiedBefore.ToString('yyyy-MM-ddTHH:mm:ss.fff') }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($OrderBy) { $Data.orderby = $OrderBy }
    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.sortorder = $SortOrder }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    $Response.SmartGroups
    <#
    .SYNOPSIS
    Searches for smart groups using the query information provided.

    .DESCRIPTION
    Searches for smart groups using the query information (smartgroup name, organizationgroup Id, mdodifedfrom/modifiedtill date, page, pagesize) provided in the request query.
    modifiedfrom and modifiedtill fields accept the following Valid DateTime formats : yyyy/MM/dd, yyyy-MM-dd, MM/dd/yyyy, MM-dd-yyyy, yyyy/MM/dd HH:mm:ss.fff, yyyy-MM-dd HH:mm:ss.fff, MM/dd/yyyy HH:mm:ss.fff, MM-dd-yyyy HH:mm:ss.fff, yyyy/MM/ddTHH:mm:ss.fff, yyyy-MM-ddTHH:mm:ss.fff, MM/dd/yyyyTHH:mm:ss.fff, MM-dd-yyyyTHH:mm:ss.fff, yyyy-MM-dd HH-mm-ss-tt, yyyy-MM-ddTHH-mm-ss-tt.

    .NOTES
    get /smartgroups/search
    [ base url: /API/mdm , api version: 1 ]

    .PARAMETER Name
    SmartGroup name.

    .PARAMETER OrganizationGroupId
    Organization Group identifier.

    .PARAMETER ManagedBy
    Smart group managing organization group identifier.

    .PARAMETER ModifiedAfter
    DateTime, Filters the result where SmartGroup modified date is greater or equal to ModifiedAfter value.

    .PARAMETER ModifiedBefore
    DateTime, Filters the result where SmartGroup modified date is less or equal to ModifiedBefore value.

    .PARAMETER OrderBy
    Order by column name.

    .PARAMETER Page
    Page number.

    .PARAMETER PageSize
    Records per page.

    .PARAMETER SortOrder
    Sorting order. Values ASC or DESC. Defaults to ASC.

    .LINK
    .EXAMPLE
    #>
}