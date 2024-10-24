function Get-DeviceById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Id
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Id)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
    # TODO: Combine Get-DeviceById and Get-DeviceByUdid
}
