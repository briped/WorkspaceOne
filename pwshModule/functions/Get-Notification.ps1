function Get-Notification {
    [CmdletBinding()]
    param(
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
        [ValidateSet('Active' ,'Dismissed')]
        [string]
        $Status
    )
    $Uri = "$($Config.ApiUrl)/system/notifications"
    $Data = @{}
    if ($Page -and $Page -gt 0) { $Data.startIndex = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
    if ($Status -and $Status -eq 'Dismissed') { $Data.active = $false }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$($Data[$k])"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Retrieves the list of notifications based on the core user.

    .DESCRIPTION
    This API is used to get a list of all the notifications created for a particular admin.

    .PARAMETER Page
    Start index for the list of fetched notifications.
    Default: 0

    .PARAMETER PageSize
    Number of notifications fetched per page.
    Default: 0

    .PARAMETER Status
    Option to fetch active/dismissed notifications.
    Default: Active

    .NOTES
    .EXAMPLE
    #>
}