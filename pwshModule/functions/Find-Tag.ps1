function Find-Tag {
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
        $TagTypeId
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
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/search"
    $Data = @{}
    if ($OrganizationGroupId) { $Data.organizationgroupid = $OrganizationGroupId }
    if ($TagTypeId) { $Data.tagtype = $TagTypeId }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $Version
    }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Attributes.Uri = "$($Uri)?$($Query -join '&')" }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    $Response
    <#
    .SYNOPSIS
    Retrieve the list of tags based off name, organization group, tag type.

    .DESCRIPTION
    Retrieve the list of tags with the search criteria that includes name, organization group, tagtype, page and page size.

    .PARAMETER Name
    Name of the tag to search

    .PARAMETER OrganizationGroupId
    Organization group identifier

    .PARAMETER TagTypeId
    Tag type id.

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .NOTES
    .EXAMPLE
    #>
}