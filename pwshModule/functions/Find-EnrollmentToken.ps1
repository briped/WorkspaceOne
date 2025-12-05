function Find-EnrollmentToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string]
        $SerialNumber
        ,
        [Parameter()]
        [string]
        $IMEI
        ,
        [Parameter()]
        [string]
        $ComplianceStatus
        ,
        [Parameter()]
        [string]
        $EnrollmentStatus
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
    $Uri = "$($Config.ApiUrl)/mdm/groups/$($OrganizationGroupUuid)/enrollment-tokens"
    $Data = @{}
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.PageSize = $PageSize }
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
    $Response.tokens
    <#
    .SYNOPSIS
    Returns a list of enrollment tokens that match the search criteria

    .DESCRIPTION
    Returns a list of enrollment tokens that match the search criteria

    .PARAMETER OrganizationGroupUuid
    Organization Group UUID. (Example:FFD1521E-70D7-4673-A0EF-62938079C0E8, FFD1521E-70D7-4673-A0EF-62938079C0E8)

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Specific page number to get. 0 based index.

    .NOTES
    #>
}
