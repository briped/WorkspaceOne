function Find-DeviceEnrollmentProgramProfile {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $SearchText
        ,
        [Parameter()]
        [string]
        $OrganizationGroupUuid
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
        [ValidateSet('DeviceProfileName', 'RootLocationGroupName')]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
    )
    $Uri = "$($Config.ApiUrl)/mdm/dep/profiles/search"
    $Data = @{}
    if ($SearchText) {
        $Data.SearchText = $SearchText
    }

    if ($OrganizationGroupUuid) { $Data.OrganizationGroupUuid = $OrganizationGroupUuid }

    if ($Page -and $Page -gt 0) { $Data.page = $Page }

    if ($PageSize -and $PageSize -gt 0) { $Data.PageSize = $PageSize }

    if ($OrderBy) { $Data.SortOrder = $OrderBy }

    if ($SortOrder -and $SortOrder -ne 'ASC') { $Data.OrderBy = $OrderBy }

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Attributes.Uri = "$($Uri)?$($Query -join '&')" }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    $Response.ProfileList
    <#
    .SYNOPSIS
    Returns a collection of Automated Device Enrollment profiles based on the search criteria.

    .DESCRIPTION
    Returns a collection of Automated Device Enrollment profiles based on the search criteria specified. The search parameters can be organization group ID, page, and the pagesize.

    .PARAMETER SearchText
    Profile name.

    .PARAMETER OrganizationGroupUuid
    Organization Group UUID. (Example:FFD1521E-70D7-4673-A0EF-62938079C0E8, FFD1521E-70D7-4673-A0EF-62938079C0E8)

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .PARAMETER OrderBy
    Default DeviceProfileName (Example:DeviceProfileName,RootLocationGroupName)

    .PARAMETER SortOrder
    Sort order of results. One of ASC or DESC. Defaults to ASC.

    .NOTES
    #>
}