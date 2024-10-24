function Remove-PurchasedAppV2 {
    [CmdletBinding(DefaultParameterSetName = 'UUID'
                ,  SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID')]
        [int]
        $DeviceUuid
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UDID')]
        [int]
        $DeviceUdid
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'SerialNumber')]
        [int]
        $SerialNumber
        ,
        [Parameter(Mandatory = $true)]
        [Alias('AppUuid')]
        [int]
        $ApplicationUuid
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceId
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application UUID '$($ApplicationUuid)' on Device UUID '$($DeviceUuid)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationUuid)/uninstall"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
