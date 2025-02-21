<#
.SYNOPSIS
Get device by identifier.

.DESCRIPTION
Gets details about a single device, as specified by the unique identifier.

.PARAMETER Id
The Device ID.

.PARAMETER Udid
The Unique Device Identifier.

.PARAMETER Uuid
The Universally Unique Identifier.

.PARAMETER Version
The API version to use.

.NOTES
.EXAMPLE
#>
function Get-Device {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UDID')]
        [string]
        $Udid
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID')]
        [string]
        $Uuid
        ,
        [Parameter(ParameterSetName = 'UUID')]
        [ValidateSet(2, 3)]
        [int]
        $Version = 2
    )
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $Identifier = $Id
            $ApiVersion = 1
            $BaseUrl = "/mdm/devices/$($Identifier)"
        }
        'UDID' {
            $Identifier = $Udid
            $ApiVersion = 1
            $BaseUrl = "/mdm/devices/udid/$($Identifier)"
        }
        'UUID' {
            $Identifier = $Uuid
            $ApiVersion = $Version
            $BaseUrl = "/mdm/devices/$($Identifier)"
        }
    }
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)$($BaseUrl)"
        Method = 'GET'
        Version = $ApiVersion
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Splattributes
}