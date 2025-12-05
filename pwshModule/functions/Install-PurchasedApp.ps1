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
    $Body = ($Data | ConvertTo-Json -Compress)
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess($Body, "Install Application ID '$($ApplicationIdentifier)'")) {
        $Attributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($ApplicationIdentifier)/install"
            Method = 'POST'
            Body = $Body
            Version = $ApiVersion
        }
        Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Install the specified purchased application on the device

    .DESCRIPTION
    Install the specified purchased application on the device.

    .PARAMETER ApplicationId
    Id of the Application to be installed, for example - 123.
    Required

    .PARAMETER ApplicationUuid
    Unique Identifier for the purchased app to be installed on the device.
    Required

    .PARAMETER DeviceId
    Id of the device.

    .PARAMETER DeviceUuid
    The Universally Unique Identifier of the device.

    .PARAMETER DeviceUdid
    The Unique Device Identifier of the device.

    .PARAMETER SerialNumber
    The serial number reported by the device.

    .PARAMETER MacAddress
    MAC Address of the device

    .PARAMETER Force
    Don't ask for confirmation, unless -Confirm is explicitly specified.

    .NOTES
    .EXAMPLE
    #>
}