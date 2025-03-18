function Get-DeviceWithPurchasedApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppId')]
        [int]
        $ApplicationId
        ,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Installed', 'Assigned')]
        [string]
        $Status
        ,
        [Parameter()]
        [int]
        $LocationGroupId
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
    $Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/devices"
    $Data = @{}
    if ($Status) { $Data.status = $Status.ToLower() }
    if ($LocationGroupId -and $LocationGroupId -gt 0) { $Data.locationGroupId = $LocationGroupId }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    $Response = Invoke-ApiRequest @Splattributes
    $Response.DeviceId
    <#
    .SYNOPSIS
    Provides a list of devices that have the specified purchased application installed or assigned.

    .DESCRIPTION
    Gets list of devices matching on the input query parameters values.

    .PARAMETER ApplicationId
    The application ID.
    Required.

    .PARAMETER Status
    Device assignment status - installed/assigned.
    Required

    .PARAMETER LocationGroupId
    The LocationGroup Identifier, for example - 777.

    .PARAMETER Page
    Specific page number to get. 0 based index.

    .PARAMETER PageSize
    Maximumm records per page.
    Default 500.

    .NOTES
    .EXAMPLE
    #>
}