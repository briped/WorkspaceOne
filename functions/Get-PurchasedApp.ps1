<#
.SYNOPSIS
Returns VPP licensed Application allocation details by AppId.

.DESCRIPTION
Returns VPP licensed Application allocation details including info about orders and licenses, assignment, and deployment parameters. Not valid for apps implementing flexible assignment. Should use new version of api. cannot be updated through this api.

Get purchased application and assignment details
Retrieve the details of a license-based purchased application and its assignments.

.NOTES
[ base url: /API/mam , api version: 1 ]
get /apps/purchased/{applicationid}
[ base url: /API/mam , api version: 2 ]
get /apps/purchased/{uuid}

.PARAMETER applicationid
(required)
Application Id.
path	integer

.PARAMETER uuid
(required)
Purchased application's UUID(Required).
path	string

.LINK
.EXAMPLE
#>
function Get-PurchasedApp {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [Alias('AppId', 'ApplicationId')]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID')]
        [Alias('AppUuid', 'ApplicationUuid')]
        [string]
        $Uuid
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $ApplicationIdentifier = $Id
            $ApiVersion = 1
            break
        }
        'UUID' {
            $ApplicationIdentifier = $Uuid
            $ApiVersion = 2
            break
        }
    }
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationIdentifier)"
        Method = 'GET'
        Version = $ApiVersion
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
}
