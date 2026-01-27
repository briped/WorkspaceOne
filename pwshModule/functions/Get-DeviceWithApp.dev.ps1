function Get-DeviceWithApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppUuid')]
        [string]
        $ApplicationId
        ,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Installed', 'Assigned')]
        [string]
        $Status
        ,
        [Parameter()]
        [Alias('OGUuid')]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string[]]
        $SmartGroupId
        ,
        [Parameter()]
        [string]
        $Search
        ,
        [Parameter()]
        [bool]
        $Assigned
        ,
        [Parameter()]
        [bool]
        $Installed
        ,
        [Parameter()]
        [string[]]
        $InstallationStatus
        ,
        [Parameter()]
        [string[]]
        $LastActionTaken
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
    $Uri = "$($Config.ApiUrl)/mam/apps/$($ApplicationId)/devices"
    $Data = @{}
    if ($PSBoundParameters.ContainsKey('Assigned')) {
        switch ($Assigned) {
            $true { $Data.isAssigned = $true }
            $false { $Data.isNotAssigned = $true }
        }
    }
    if ($PSBoundParameters.ContainsKey('Installed')) {
        switch ($Installed) {
            $true { $Data.isInstalled = $true }
            $false { $Data.isNotInstalled = $true }
        }
    }
    if ($Status) { $Data.status = $Status.ToLower() }
    if ($OrganizationGroupUuid) { $Data.organizationGroupUuid = $OrganizationGroupUuid }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pageSize = $PageSize }
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
    $Response = Invoke-ApiRequest @Attributes
    $Response.DeviceId
    <#
    .SYNOPSIS
    Provides a list of devices that have the specified purchased application installed or assigned.

    .DESCRIPTION
    Gets list of devices matching on the input query parameters values.

    .PARAMETER ApplicationId
    The uuid of the application.
    Required.

    .PARAMETER Status
    Device assignment status - installed/assigned.

    .PARAMETER OrganizationGroupUuid
    The Organization Group identifier in which the counts need to be fetched. Will be defaulted to admin organization group identifier if not set.

    .PARAMETER SmartGroupId
    Comma separated list of smart group ids to which the devices belong.
    If no smart group id is passed, all the eligible devices will be returned based on the other filters. E.g. 10, 20

    .PARAMETER Search
    If provided, the records matching this text will be returned.
    The search will be applied on the following properties [name, installed_version, assigned_version].

    .PARAMETER Page
    Specific page number to get. 0 based index.

    .PARAMETER PageSize
    Maximumm records per page.
    Default: 500

    .PARAMETER OrderBy
    Name of the property used for sorting.

    .PARAMETER SortOrder
    Whether the sort order is ascending or descending. The property used for sorting is name.
    Default: ASC

    .NOTES
    .EXAMPLE
    #>
}