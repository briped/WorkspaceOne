function Find-EnrollmentToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [string]
        $SerialNumber
        ,
        [Parameter()]
        [string]
        $Imei
        ,
        [Parameter()]
        [string]
        $ComplianceStatus
        ,
        [Parameter()]
        [string]
        $EnrollmentStatus
        ,
        [Parameter()]
        [string]
        $DeviceType
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
    )
    $Uri = "$($Config.ApiUrl)/mdm/groups/${OrganizationGroupUuid}/enrollment-tokens"
    $Data = @{}
    if ($SerialNumber) { $Data.serial_number = $SerialNumber }
    if ($Imei) { $Data.imei = $Imei }
    if ($ComplianceStatus) { $Data.compliance_status = $ComplianceStatus }
    if ($EnrollmentStatus) { $Data.enrollment_status = $EnrollmentStatus }
    if ($DeviceType) { $Data.device_type = $DeviceType }
    if ($Page -and $Page -gt 0) { $Data.page = $Page }
    if ($PageSize -and $PageSize -gt 0) { $Data.page_size = $PageSize }
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Attributes.Uri = "$($Uri)?$($Query -join '&')" }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Returns a list of enrollment tokens that match the search criteria

    .DESCRIPTION
    Returns a list of enrollment tokens that match the search criteria

    .PARAMETER OrganizationGroupUuid
    [string] Required
    Uuid of the organization group to search in.

    .PARAMETER SerialNumber
    [uuid]
    Serial number of the device.

    .PARAMETER Imei
    [string]
    IMEI number of the device

    .PARAMETER ComplianceStatus
    [string]
    Compliance status of registration.

    .PARAMETER EnrollmentStatus
    [string]
    Enrollment status.

    .PARAMETER DeviceType
    [string]
    Device type (Platform).

    .PARAMETER Page
    Filters search result to return results based on page number. Page numbering is 0 based and omitting this parameter will return the first page.

    .PARAMETER PageSize
    Limits the number of search results per page. Defaults to 500.

    .NOTES
    Console: Devices > Lifecycle: Registration
    .EXAMPLE
    #>
}
