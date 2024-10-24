function Get-DeviceByUdid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Udid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/udid/$($Udid)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
    # TODO: Combine Get-DeviceById and Get-DeviceByUdid
}
