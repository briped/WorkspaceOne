function Install-PurchasedApp {
    [CmdletBinding(DefaultParameterSetName = 'ID'
                ,  SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [Alias('AppId')]
        [int]
        $ApplicationId
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UUID')]
        [Alias('AppUuid')]
        [string]
        $ApplicationUuid
        ,
        [Parameter(ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [int]
        $DeviceId
        ,
        [Parameter(ParameterSetName = 'UUID')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DeviceUuid
        ,
        [Parameter(ParameterSetName = 'ID')]
        [Parameter(ParameterSetName = 'UUID')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DeviceUdid
        ,
        [Parameter(ParameterSetName = 'ID')]
        [Parameter(ParameterSetName = 'UUID')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SerialNumber
        ,
        [Parameter(ParameterSetName = 'ID')]
        [Parameter(ParameterSetName = 'UUID')]
        [ValidateScript({($_ -replace '[^0-9a-f]','').Length -eq 12})]
        [string]
        $MacAddress
        ,
        [Parameter()]
        [switch]
        $Force
    )
    $DeviceInfo = @{}
    switch ($PSCmdlet.ParameterSetName) {
        'ID' {
            $ApplicationIdentifier = $ApplicationId
            if ($DeviceId) { $DeviceInfo.DeviceId = $DeviceId }
            if ($DeviceUdid) { $DeviceInfo.Udid = $DeviceUdid}
            if ($SerialNumber) { $DeviceInfo.SerialNumber = $SerialNumber }
            if ($MacAddress) { $DeviceInfo.MacAddress = $MacAddress }
            $ApiVersion = 1
            break
        }
        'UUID' {
            $ApplicationIdentifier = $ApplicationUuid
            if ($DeviceUuid) { $DeviceInfo.device_uuid = $DeviceUuid }
            if ($DeviceUdid) { $DeviceInfo.device_udid = $DeviceUdid}
            if ($SerialNumber) { $DeviceInfo.serial_number = $SerialNumber }
            if ($MacAddress) { $DeviceInfo.mac_address = $MacAddress }
            $ApiVersion = 2
            break
        }
    }
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Data = @{
        DeviceId = $DeviceID
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Install Application ID '$($ApplicationIdentifier)' on Device ID '$($DeviceId)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationId)/install"
            Method = 'POST'
            Body = ($Data | ConvertTo-Json -Compress)
            Version = $ApiVersion
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
