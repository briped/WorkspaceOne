<#
.SYNOPSIS
Retrieves the list of notifications based on the core user.

.DESCRIPTION
This API is used to get a list of all the notifications created for a particular admin.

.NOTES
get /notifications
[ base url: /API/system , api version: 2 ]

.PARAMETER startIndex
Optional. Start index for the list of fetched notifications. Default value is 0.
query	integer

.PARAMETER pageSize
Optional. Number of notifications fetched per page. Default value is 0.
query	integer

.PARAMETER active
Optional. Option to fetch active/dismissed notifications. Value can be true or false. Default value is true.
query	boolean

.PARAMETER cultureCode
Optional. Option to provide the locale setting for the fetched notifications. Default value is the default culture code for the core user.
query	string


.LINK
.EXAMPLE
#>
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
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
}
