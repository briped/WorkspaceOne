<#
.SYNOPSIS
Get device by identifier.

.DESCRIPTION
Gets details about a single device, as specified by the unique identifier.

.NOTES
[ base url: /API/mdm , api version: 1 ]
get /devices/{id}
{
  "Udid": "827BE1C5AEC05C378C61C44103E9D3FCB2EC354D",
  "SerialNumber": "R51G844T90R",
  "MacAddress": "485A3F880798",
  "Imei": "356766060039613",
  "EasId": "6Q93UFOQ7H0K39JPMFPTEMJQ3K",
  "AssetNumber": "827BE1C5AEC05C378C61C44103E9D3FCB2EC354D",
  "DeviceFriendlyName": "users iPhone iOS 10.3.2 ",
  "DeviceReportedName": "5CD6473R77 - Demo HP Chromebook",
  "LocationGroupId": {
    "Name": "Text value",
    "Uuid": "c4bf3648-44fd-4561-960f-c4ce049800a0"
  },
  "LocationGroupName": "locationgroup1",
  "UserId": {},
  "UserName": "user1",
  "DataProtectionStatus": 5,
  "UserEmailAddress": "user1@vmware.com",
  "Ownership": "C",
  "PlatformId": {},
  "Platform": "Apple",
  "ModelId": {},
  "Model": "iPhone",
  "OperatingSystem": "10.3.2",
  "PhoneNumber": "+14045550100",
  "LastSeen": "2024-09-11T13:23:29.9817843+02:00",
  "EnrollmentStatus": "Enrolled",
  "ComplianceStatus": "Compliant",
  "CompromisedStatus": true,
  "LastEnrolledOn": "2024-09-11T13:23:29.9817843+02:00",
  "LastComplianceCheckOn": "2024-09-11T13:23:29.9817843+02:00",
  "LastCompromisedCheckOn": "2024-09-11T13:23:29.9817843+02:00",
  "ComplianceSummary": {
    "DeviceCompliance": [
      {
        "CompliantStatus": true,
        "PolicyName": "application list compliance policy",
        "PolicyDetail": "compliance policy for device compromised status including application list contains rule",
        "LastComplianceCheck": "2024-09-11T13:23:29.9817843+02:00",
        "NextComplianceCheck": "2024-09-11T13:23:29.9817843+02:00",
        "ActionTaken": [
          {
            "ActionType": 0
          }
        ],
        "Id": {
          "Value": 1
        },
        "Uuid": "9b47c0e6-6c5f-4173-9ccc-5debc4456fa0"
      }
    ]
  },
  "IsSupervised": true,
  "DeviceMCC": {
    "SIMMCC": "Text value",
    "CurrentMCC": "Text value"
  },
  "IsRemoteManagementEnabled": "abcd",
  "DataEncryptionYN": "Y",
  "AcLineStatus": 1,
  "VirtualMemory": 2,
  "OEMInfo": "Samsung",
  "DeviceCapacity": 1,
  "AvailableDeviceCapacity": 1,
  "LastSystemSampleTime": "2024-09-11T13:23:29.9817843+02:00",
  "IsDeviceDNDEnabled": true,
  "IsDeviceLocatorEnabled": true,
  "IsCloudBackupEnabled": true,
  "IsActivationLockEnabled": true,
  "IsNetworkTethered": true,
  "BatteryLevel": "abcd",
  "IsRoaming": true,
  "LastNetworkLANSampleTime": "2024-09-11T13:23:29.9817843+02:00",
  "LastBluetoothSampleTime": "2024-09-11T13:23:29.9817843+02:00",
  "SystemIntegrityProtectionEnabled": true,
  "ProcessorArchitecture": 5,
  "UserApprovedEnrollment": true,
  "EnrolledViaDEP": true,
  "TotalPhysicalMemory": 3,
  "AvailablePhysicalMemory": 4,
  "OSBuildVersion": "17G65",
  "HostName": "zs-MacBook-Air",
  "LocalHostName": "zs-MacBook-Air.mshome.net",
  "SecurityPatchDate": "2024-09-11T13:23:29.9973978+02:00",
  "SystemUpdateReceivedTime": "2024-09-11T13:23:29.9973978+02:00",
  "IsSecurityPatchUpdate": true,
  "DeviceManufacturerId": 1,
  "DeviceNetworkInfo": [
    {
      "ConnectionType": "Text value",
      "IPAddress": "Text value",
      "MACAddress": "Text value",
      "Name": "Text value",
      "Vendor": "Text value"
    }
  ],
  "DeviceCellularNetworkInfo": [
    {
      "CarrierName": "Text value",
      "CardId": "Text value",
      "PhoneNumber": "Text value",
      "DeviceMCC": {},
      "IsRoaming": true
    }
  ],
  "EnrollmentUserUuid": "00000000-0000-0000-0000-000000000000",
  "ManagedBy": 0,
  "WifiSsid": "guest",
  "DepTokenSource": 0,
  "Id": {
    "Value": 0
  },
  "Uuid": "e4774bca-85bf-44d2-b5cf-dc68324d66ad"
}


get /devices/udid/{udid}


[ base url: /API/mdm , api version: 2 ]
get /devices/{uuid}
Get basic information about the device based on the unique identifier passed in the path. The response contains hypermedia links, which can be followed to get more information about the device. The API returns a 404 - NotFound if the device is not available.
{
  "udid": "827BE1C5AEC05C378C61C44103E9D3FCB2EC354D",
  "serialNumber": "R51G844T90R",
  "macAddress": "485A3F880798",
  "imei": "356766060039613",
  "friendlyName": "My iPhone iOS 10.3.2",
  "organizationGroupName": "testOg",
  "totalStorageBytes": "68719476736",
  "availableStorageBytes": "34359738368",
  "batteryLevelPercentage": "80",
  "computerName": "WindowsPC",
  "supervised": true,
  "dataEncrypted": true,
  "platformInfo": {
    "deviceType": "Apple",
    "platformName": "iOS",
    "modelName": "MD200LL",
    "osVersion": "10.3.2"
  },
  "carrierInfo": {
    "phoneNumber": "+14045550100",
    "roamingEnabled": true
  },
  "enrollmentInfo": {
    "enrollmentStatus": "UNKNOWN",
    "compliant": true,
    "enrollmentTimestamp": "2024-09-11T13:23:21.9437612+02:00",
    "lastSeenTimestamp": "2024-09-11T13:23:21.9437612+02:00",
    "ownership": "CORPORATE",
    "organizationGroupId": "aec92715-67ac-4de2-8954-ad0a75b0e476",
    "organizationGroupName": "locationgroup1",
    "userName": "user1",
    "userEmailAddress": "user1@vmware.com",
    "enrollmentUserUuid": "6cf61465-b9f5-4442-aee9-7546c4293afc",
    "managedBy": "Unknown"
  },
  "OSBuildVersion": "80",
  "WifiSsid": "Text value",
  "Links": [],
  "uuid": "a61de75c-e10e-4688-95a8-a587b9e9ad8b"
}

[ base url: /API/mdm , api version: 3 ]
get /devices/{uuid}
Get basic information about the device based on the unique identifier passed in the path. The response contains hypermedia links, which can be followed to get more information about the device.
{
  "udid": "827BE1C5AEC05C378C61C44103E9D3FCB2EC354D",
  "serial_number": "R51G844T90R",
  "mac_address": "485A3F880798",
  "imei": "356766060039613",
  "friendly_name": "My iPhone iOS 10.3.2",
  "device_reported_name": "R51G844T90R - My iPhone iOS 10.3.2",
  "organization_group_name": "testOg",
  "total_storage_bytes": "68719476736",
  "available_storage_bytes": "34359738368",
  "total_physical_memory_bytes": "28719476736",
  "available_physical_memory_bytes": "12359738368",
  "total_external_storage_bytes": "84619476736",
  "available_external_storage_bytes": "2479738368",
  "total_internal_storage_bytes": "84619476736",
  "available_internal_storage_bytes": "84619476736",
  "battery_level_percentage": "80",
  "computer_name": "WindowsPC",
  "supervised": true,
  "data_encrypted": true,
  "platform_info": {
    "device_type": "UNKNOWN",
    "platform_name": "iOS",
    "oem_info": "Apple",
    "model_identifier": "MD200LL",
    "model": "iPhone 5s (CDMA/GSM/LTE) (16 GB Silver)",
    "os_version": "10.3.2"
  },
  "carrier_info": {
    "phone_number": "4045550100",
    "roaming_enabled": true
  },
  "enrollment_info": {
    "enrollment_status": "UNKNOWN",
    "compliance_status": "UNKNOWN",
    "enrollment_timestamp": "2024-09-11T13:23:22.6979018+02:00",
    "last_seen_timestamp": "2024-09-11T13:23:22.6979018+02:00",
    "ownership": "CORPORATE",
    "organization_group_uuid": "b4471492-2dc9-4c62-ac95-675ae18a43dd",
    "organization_group_name": "locationgroup1",
    "enrollment_user_name": "user1",
    "enrollment_user_uuid": "91c42942-b03a-4abc-b1ab-15d92a86236a",
    "enrollment_user_email_address": "user1@vmware.com",
    "managed_by": "UNKNOWN"
  },
  "os_build_version": "17G65",
  "wifi_ssid": "Example Wi-Fi Name",
  "last_reboot": "2024-09-11T13:23:22.6979018+02:00",
  "security_patch_date": "2024-09-11T13:23:22.6979018+02:00",
  "system_update_received_time": "2024-09-11T13:23:22.6979018+02:00",
  "is_security_patch_update": true,
  "hardware_device_identifier": "B07B9C3CDF8AC44B923D215B1BB77623",
  "processor_architecture_name": "ARM64",
  "supplement_version_extra": "(a)",
  "supplement_build_version": "B07B9C3CDF8",
  "Links": [],
  "id": 1234,
  "uuid": "e6ac137f-f319-49aa-aa7b-28ed1ea16415"
}

.EXAMPLE
#>
function Get-Device {
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param(
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'ID')]
        [int]
        $Id #v1
        ,
        [Parameter(Mandatory = $true
                ,  ParameterSetName = 'UDID')]
        [string] #v1
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
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes)"
    Invoke-ApiRequest @Splattributes
}