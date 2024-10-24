<#
.SYNOPSIS
Searches the device using the query information provided.

.DESCRIPTION
Get basic information about the device with maximum pagesize limit of 500. If page size is greater than the maximum limit, it will return the first 500 records.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

[ base url: /API/mdm , api version: 4 ]
post /devices/search

.PARAMETER requestBody
Specifies the search criteria used to perform a device search.
(Required)
body

DeviceListSearchRequestModel {
    organization_group_uuid (string, optional): Organization group membership filter.,
    page_size (integer, optional): An integer that indicates the maximum number of records per page. It is limited to 500.,
    page (integer, optional): An integer describing the starting position in the result set.,
    sort_order (string, optional): Specifies the sort order for the result set. e.g. 'ASC','DESC'.,
    sort_by (string, optional): Sort results based on given field. One of model, lastseenat, ownership, platform etc. Defaults to deviceid.,
    user_group_uuids (Array[string], optional): A List of User group uuids.,
    management_type (integer, optional): Device model management type filter. e.g. 'APP_LEVEL', 'CATALOG', 'CONTAINER','MDM', etc. = ['0', '1', '2', '3', '4', '5', '6'],
    ownerships (Array[integer], optional): An array of ownership type values. e.g. 'CORPORATE_DEDICATED', 'CORPORATE_SHARED', 'EMPLOYEE_OWNED', etc.,
    compromised (integer, optional): Specifies the compromised state of the device. = ['0', '1', '2'],
    encrypted (integer, optional): Specifies the encryption state of the device. = ['0', '1', '2'],
    passcode_present (integer, optional): Specifies the existence of a passcode on the device. = ['0', '1', '2'],
    enrollment_status (integer, optional): Specifies the set of possible device enrollment states. e.g. 'ENROLLED','UNENROLLED', etc. = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'],
    compliance_status (integer, optional): Specifies the set of possible compliance states for a device. e.g. 'COMPLIANT','NON_COMPLIANT', etc. = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'],
    enrollment_history (integer, optional): Specifies the valid enrollment history filter options. e.g. 'PAST_DAY','PAST_WEEK','PAST_MONTH', etc. = ['0', '1', '2', '3'],
    last_seen_days (MinimumMaximumRangeModel, optional): Last seen days lower and upper bound date criteria.,
    smart_group_uuids (Array[string], optional): List of smart group uuids.,
    lost_mode_enabled (boolean, optional): Device's lost mode value.,
    ip_range (IpRangeModel, optional): IP range to filter devices by.,
    search_text (string, optional): A string value by which devices are to be filtered by matching against device properties like 'friendly_name', 'organization_group_name', 'enrollment_user_name' etc.,
    device_uuids (Array[string], optional): An array containing device uuids.,
    device_reassignment_supported (boolean, optional): Device reassignment is supported or not.,
    device_reassignment_enabled (boolean, optional): Device reassignment is enabled or not.,
    android_enrollment_modes (Array[integer], optional): Enrollment mode for android devices.,
    tag_uuids (Array[string], optional): An array of device tag unique identifier.,
    content_compliance (integer, optional): A string value by which devices to be filtered by matching against content compliance status. = ['0', '1', '2'],
    cpu_architecture_filters (Array[integer], optional): CPU architecture for Windows Desktop & Mac OS Devices.,
    battery_level (MinimumMaximumRangeModel, optional): Min & Max Battery Level,
    external_storage_mega_bytes (MinimumMaximumRangeModel, optional): Min and Max external Storage,
    internal_storage_mega_bytes (MinimumMaximumRangeModel, optional): Min and Max Internal Storage,
    platform (Array[PlatformFilterModelV4], optional): Platform filter model.
}
MinimumMaximumRangeModel {
    minimum_value (integer, optional): Minimum value of the property.,
    maximum_value (integer, optional): Maximum value of the property.
}
IpRangeModel {
    start (string): IP address range start value.,
    end (string): IP address range end value.
}
PlatformFilterModelV4 {
    device_type (integer, optional): Device type. = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
    device_model (DeviceModelFilterV4, optional): Device model.
}
DeviceModelFilterV4 {
    device_models (Array[string], optional): Device model filter. An array of device model names.,
    versions (Array[string], optional): An array of OS version.
}

Example Value:
{
    "organization_group_uuid": "233d2744-8f30-4a1d-b2c4-9f4f25e48490",
    "page_size": 30,
    "page": 1,
    "sort_order": "Text value",
    "sort_by": "lastseenat",
    "user_group_uuids": [
        "d760d480-ecc5-4e62-b50b-d1947503e6f5"
    ],
    "management_type": "UNKNOWN",
    "ownerships": [
        "UNKNOWN"
    ],
    "compromised": "UNKNOWN",
    "encrypted": "UNKNOWN",
    "passcode_present": "UNKNOWN",
    "enrollment_status": "UNKNOWN",
    "compliance_status": "UNKNOWN",
    "enrollment_history": "UNKNOWN",
    "last_seen_days": {
        "minimum_value": 1,
        "maximum_value": 1
    },
    "smart_group_uuids": [
        "e2ba2cb3-53db-47ef-af91-7e22c2ef95dc"
    ],
    "lost_mode_enabled": true,
    "ip_range": {
        "start": "127.0.0.1",
        "end": "127.0.0.10"
    },
    "search_text": "Global, user123",
    "device_uuids": [
        "1bb42008-f812-4594-af83-dc5ff932c01d"
    ],
    "device_reassignment_supported": true,
    "device_reassignment_enabled": true,
    "android_enrollment_modes": [
        "UNKNOWN"
    ],
    "tag_uuids": [
        "388eb27f-031f-4781-a398-2bcbe6afd18b"
    ],
    "content_compliance": "UNKNOWN",
    "cpu_architecture_filters": [
        "UNKNOWN"
    ],
    "battery_level": {},
    "external_storage_mega_bytes": {},
    "internal_storage_mega_bytes": {},
    "platform": [
        {
            "device_type": 0,
            "device_model": {
                "device_models": [
                    "Text value"
                ],
                "versions": [
                    "Text value"
                ]
            }
        }
    ]
}

.PARAMETER parameterContentType
application/json

.LINK
Specify a URI to a help page, this will show when Get-Help -Online is used.

.EXAMPLE
Test-MyTestFunction -Verbose
Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function Find-DeviceV4 {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [ValidateSet('iPhone', 'iPad')]
        [string[]]
        $Model
        ,
        [Parameter()]
        [Alias('Start', 'PageStart')]
        [int]
        $Page
        ,
        [Parameter()]
        [Alias('Limit')]
        [int]
        $PageSize
        ,
        [Parameter()]
        [string]
        $OrderBy
    )
    # TODO: Implement it.
    Write-Output 'Not implemented yet'
}
