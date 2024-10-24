function Get-DeviceV3 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uuid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Uuid)"
        Method = 'GET'
    }
    Invoke-ApiRequest @Splattributes
}
