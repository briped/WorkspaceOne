function Get-DeviceAppDetails {
    [CmdletBinding(DefaultParameterSetName = 'UUID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID'
                ,  Position = 0)]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID'
                ,  ValueFromPipeline = $true
                ,  ValueFromPipelineByPropertyName = $true
                ,  ValueFromRemainingArguments = $false
                ,  Position = 0)]
        [string]
        $Uuid
        ,
        [Parameter(ParameterSetName = 'UUID')]
        [string]
        $Search
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page = 0
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize = 500
        ,
        [Parameter(ParameterSetName = 'UUID')]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder = 'ASC'
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $Identifier = $Id
            $Endpoint = "/mdm/devices/$($Identifier)/apps"
        }
        'UUID' {
            $Identifier = $Uuid
            $Endpoint = "/mdm/devices/$($Identifier)/apps/search"
        }
    }
    $Attributes = @{
        Uri = "$($Config.ApiUrl)$($Endpoint)"
        Method = 'GET'
        Version = 1
    }

    $Data = @{}
    if ($Search) { $Data.searchtext = $Search }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.pagesize = $PageSize }
    if ($SortOrder) { $Data.sortorder = $SortOrder }

    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Attributes.Uri += "$($Uri)?$($Query -join '&')" }

    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Attributes
    $Response.app_items
    <#
    .SYNOPSIS
    Retrieves application details of the device identified by device ID.

    .DESCRIPTION
    This endpoint returns the details of specified app which is assigned or installed on the device.

    .PARAMETER Id
    The Device ID.
    Warning: Deprecated

    .PARAMETER Uuid
    The Universally Unique Identifier.

    .PARAMETER Search
    If provided, the records matching this text will be returned.
    The search will be applied on the following properties [name, installed_version, assigned_version].

    .PARAMETER Page
    The specific page number to get.

    .PARAMETER PageSize
    Max records per page.

    .PARAMETER SortOrder
    Sort order of results. One of ASC or DESC. Defaults to ASC.

    .NOTES
    .EXAMPLE
    #>
}