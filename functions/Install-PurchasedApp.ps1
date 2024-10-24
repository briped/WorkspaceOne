<#
.SYNOPSIS
Install the specified purchased application on the device

.DESCRIPTION
Install the specified purchased application on the device.

.NOTES
[ base url: /API/mam , api version: 1 ]
post /apps/purchased/{applicationid}/install
[ base url: /API/mam , api version: 2 ]
post /apps/purchased/{applicationUuid}/install

.PARAMETER applicationid
(required)
Id of the Application to be installed, for example - 123.
path	string

.PARAMETER applicationUuid
(required)
Unique Identifier for the purchased app to be installed on the device.(Required).
path	string

.PARAMETER Parametercontenttype
application/json

.PARAMETER deviceInfo
(required)
Details of the device on which the Application to be installed. Accepted format is guid E.g. 3d958f38-246e-4854-a306-189d941ab073(Required).

.PARAMETER body
DeviceInfo {
    DeviceId (integer, optional): Gets or sets the device id.,
    Udid (string, optional): Gets or sets the device's unique identifier.,
    SerialNumber (string, optional): Gets or sets the serial number reported by the device.,
    MacAddress (string, optional): Gets or sets macaddress of the device.
}
DeviceInformationV2Model {
    device_uuid (string, optional): Unique identifier of the device.,
    device_udid (string, optional): UDID of the device,
    serial_number (string, optional): Device serial number,
    mac_address (string, optional): MAC Address of the device.
}
ModelExample Value
{
    "DeviceId": 1,
    "device_uuid": "f88ba0e1-149e-4006-8041-c64e2f287653",

    "Udid": "6bf0f04c73681fbecfc3eb4f13cbf05b",
    "device_udid": "827BE1C5AEC05C378C61C44103E9D3FCB2EC354D",

    "SerialNumber": "LGH871c18f631a",
    "serial_number": "BLCA34786H",

    "MacAddress": "0x848506B900BA"
    "mac_address": "485A3F880798"
}

.LINK
.EXAMPLE
#>
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
    if ($PSCmdlet.ShouldProcess("Device ID '$($DeviceId)'", "Install Application ID '$($ApplicationIdentifier)'")) {
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
