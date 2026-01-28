function Find-Tag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $OrganizationGroupId
        ,
        [Parameter()]
        [string]
        $Name
        ,
        [Parameter()]
        [int]
        $TypeId
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
    $Data.organizationgroupid = $OrganizationGroupId
    if ($Name) { $Data.name = $Name }
    if ($TypeId) { $Data.tagtype = $TypeId }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Attributes.Uri = "$($Uri)?$($Query -join '&')" }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Retrieve the list of tags based off name, organization group, tag type.

    .DESCRIPTION
    Retrieve the list of tags with the search criteria that includes name, organization group, tagtype, page and page size.

    .PARAMETER Name
    Name of the tag to search

    .PARAMETER OrganizationGroupId
    Organization group identifier

    .PARAMETER TypeId
    Tag type id.

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .NOTES
    .EXAMPLE
    #>
}