function Find-Device {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $User
        ,
        [Parameter()]
        [Alias('ModelId')]
        [string[]]
        $Model
        ,
        [Parameter()]
        [Alias('DeviceType')]
        [string[]]
        $Platform
        ,
        [Parameter()]
        [ValidateSet('C', 'E', 'S', 'Undefined')]
        [string[]]
        $Ownership
        ,
        [Parameter()]
        [bool]
        $Compliant
        ,
        [Parameter()]
        [int]
        $LocationGroupId
        ,
        [Parameter()]
        [datetime]
        $LastSeen
        ,
        [Parameter()]
        [datetime]
        $SeenSince
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
        [ValidateSet('LastSeen', 'Ownership', 'Platform', 'DeviceId')]
        [string]
        $OrderBy
        ,
        [Parameter()]
        [Alias('Sort')]
        [ValidateSet('ASC', 'DESC')]
        [string]
        $SortOrder
        ,
        [Parameter()]
        [ValidateSet(1, 2, 3, 4)]
        [int]
        $Version = 1
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/search"
    $Data = @{}
    if ($User -and $Version -in (1,2,3)) {
        $Data.user = $User
    }

    if ($Model -and $Version -in (1,2)) { $Data.model = $Model }
    if ($Model -and $Version -in (3)) { $Data.model_identifier = $Model }
    if ($Model -and $Version -in (4)) { $Data.device_models = ($Model -as [array]) }

    if ($Platform -and $Version -in (1,2)) { $Data.platform = $Platform }
    if ($Platform -and $Version -in (3)) { $Data.device_type = $Platform }
    if ($Platform -and $Version -in (4)) { $Data.device_types = ($Platform -as [array]) }

    if ($LastSeen -and $Version -in (1,2)) { $Data.lastseen = $LastSeen }
    if ($LastSeen -and $Version -in (3)) { $Data.last_seen = $LastSeen }

    if ($Ownership -and $Version -in (1,2,3)) { $Data.ownership = $Ownership }
    if ($Ownership -and $Version -in (4)) { $Data.ownerships = ($Ownership -as [array]) }

    if ($LocationGroupId -and $Version -in (1,2)) { $Data.lgid = $LocationGroupId }
    if ($OrganizationGroupUuid -and $Version -in (3,4)) { $Data.organization_group_uuid = $OrganizationGroupUuid }

    if ($Compliance -and $Version -in (1)) { $Data.compliantstatus = $Compliance }
    if ($Compliance -and $Version -in (2,3,4)) { $Data.compliance_status = $Compliance }

    if ($SeenSince -and $Version -in (1)) { $Data.seensince = $SeenSince }
    if ($SeenSince -and $Version -in (2,3)) { $Data.seen_since = $SeenSince }

    if ($Page -and $Page -gt 0) { $Data.page = $Page }

    if ($PageSize -and $PageSize -gt 0 -and $Version -in (1,2)) { $Data.pagesize = $PageSize }
    if ($PageSize -and $PageSize -gt 0 -and $Version -in (3,4)) { $Data.page_size = $PageSize }

    if ($OrderBy -and $Version -in (1,2)) { $Data.orderby = $OrderBy }
    if ($OrderBy -and $Version -in (3)) { $Data.order_by = $OrderBy }
    if ($OrderBy -and $Version -in (4)) { $Data.sort_by = $OrderBy }

    if ($SortOrder -and $SortOrder -ne 'ASC' -and $Version -in (1,2)) { $Data.sortorder = $SortOrder }
    if ($SortOrder -and $SortOrder -ne 'ASC' -and $Version -in (3,4)) { $Data.sort_order = $SortOrder }

    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = $Version
    }
    if ($Version -in (1,2,3)) {
        $Query = @()
        foreach ($k in $Data.Keys) {
            $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
        }
        if ($Query.Count -gt 0) { $Splattributes.Uri = "$($Uri)?$($Query -join '&')" }
    }
    if ($Version -in (4)) {
        $Body = $Data | ConvertTo-Json -Compress
        $Splattributes.Body = $Body
        $Splattributes.Method = 'POST'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Splattributes | ConvertTo-Json -Compress)"
    $Response = Invoke-ApiRequest @Splattributes
    $Response.Devices
  <#
  .SYNOPSIS
  Find relevant devices using various criteria.

  .DESCRIPTION
  Returns details of relevant devices belonging to an enrollment user matching specified criteria, where results are ranked/sorted using the specified orderby criteria with maximum pagesize limit of 500. 
  If page size is greater than the maximum limit, it will return the first 500 records. 
  seensince and lastseen fields accept the following Valid DateTime formats : 
      yyyy/MM/dd, 
      yyyy-MM-dd, 
      MM/dd/yyyy, 
      MM-dd-yyyy, 
      yyyy/MM/dd HH:mm:ss.fff, 
      yyyy-MM-dd HH:mm:ss.fff, 
      MM/dd/yyyy HH:mm:ss.fff, 
      MM-dd-yyyy HH:mm:ss.fff, 
      yyyy/MM/ddTHH:mm:ss.fff, 
      yyyy-MM-ddTHH:mm:ss.fff, 
      MM/dd/yyyyTHH:mm:ss.fff, 
      MM-dd-yyyyTHH:mm:ss.fff, 
      yyyy-MM-dd HH-mm-ss-tt, 
      yyyy-MM-ddTHH-mm-ss-tt.

  .PARAMETER User
  Filters devices based on enrolled username.

  .PARAMETER Model
  Filters devices based on model. For example iPhone.

  .PARAMETER Platform
  Filters devices based on platform. For example Apple.

  .PARAMETER LastSeen
  Filters devices based on the date when they were last seen.

  .PARAMETER Ownership
  Filters devices based on ownership type. One of C, E, S or Undefined.

  .PARAMETER LocationGroupId
  Limits the search to given OrganizationGroup. Defaults to admin's OrganizationGroup.

  .PARAMETER Compliant
  Filters devices based on specified compliant status. Possible values are true (for Compliant) and false (for NonCompliant).

  .PARAMETER SeenSince
  Filters devices based on the date when they were seen after given date.

  .PARAMETER Page
  Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

  .PARAMETER PageSize
  Limits the number of search results per page. Defaults to 500.

  .PARAMETER OrderBy
  Sort results based on given field. One of model, lastseen, ownership, platform, deviceid etc. Defaults to deviceid.

  .PARAMETER SortOrder
  Sort order of results. One of ASC or DESC. Defaults to ASC.

  .NOTES
  [ base url: /API/mdm , api version: 1-4 ]
  get /devices/search

  v4
  {
    "organization_group_uuid": "1d1f131a-5776-4df8-b7f8-a0b3dbea7ff4",
    "page_size": 30,
    "page": 1,
    "sort_order": "Text value",
    "sort_by": "lastseenat",
    "user_group_uuids": [
      "0d637460-6544-456c-ae6e-bee0af032aed"
    ],
    "device_types": [
      0
    ],
    "device_models": [
      "Text value"
    ],
    "os_versions": [
      "Text value"
    ],
    "management_type": 0,
    "ownerships": [
      0
    ],
    "compromised": "true",
    "encrypted": "false",
    "passcode_present": "Text value",
    "enrollment_status": 0,
    "compliance_status": 0,
    "enrollment_history": "PAST_DAY",
    "last_seen_days_to": 5,
    "last_seen_days_from": 15,
    "smart_group_uuids": [
      "0de35c7e-d1bf-48b0-b81b-1a936554e665"
    ],
    "mac_address": "00:A0:C9:14:C8:29",
    "lost_mode_enabled": true,
    "ip_range": {
      "start": "127.0.0.1",
      "end": "127.0.0.10"
    },
    "search_text": "Global, user123",
    "device_uuids": [
      "50e75b98-be57-4846-b231-d8dfda2be08e"
    ],
    "device_reassignment_supported": true,
    "device_reassignment_enabled": true,
    "android_enrollment_modes": [
      0
    ],
    "tag_uuids": [
      "39491beb-09f1-4d73-8312-4d12f8d7a1a2"
    ],
    "content_compliance": "Text value",
    "cpu_architecture_filters": [
      1
    ],
    "battery_level": {
      "minimum_value": 1,
      "maximum_value": 1
    },
    "external_storage": {},
    "internal_storage": {},
    "os_version_filters": [
      {
        "device_type": "Text value",
        "versions": [
          {
            "device_os_version_major": 1,
            "device_os_version_minor": 1,
            "device_os_version_build": 1,
            "device_os_version_revision": "Text value"
          }
        ]
      }
    ]
  }

  .EXAMPLE
  #>
}