function Remove-PurchasedAppV1 {
    [CmdletBinding(DefaultParameterSetName = 'ID'
                ,  SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [int]
        $DeviceId
        ,
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
        [Alias('AppID')]
        [int]
        $ApplicationId
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
    if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationId)' on Device ID '$($DeviceId)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/uninstall"
            Method = 'POST'
            Body = $Data | ConvertTo-Json -Compress
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
