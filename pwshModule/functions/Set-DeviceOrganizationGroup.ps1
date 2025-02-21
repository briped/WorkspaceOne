<#
.SYNOPSIS
Changes the organization group to which the device identified by the alternate ID is assigned.

.DESCRIPTION
Processes the command to change organization group for the specific device using UUID. It will also check if device can be accessed or not.

.PARAMETER Id
Device alternate ID Formats = {Macaddress - 848506B900BA, Udid - 6bf0f04c73681fbecfc3eb4f13cbf05b, SerialNumber - LGH871c18f631a, ImeiNumber - 354833052322837}

.PARAMETER IdType
The alternate ID type Macaddress, Udid, Serialnumber, ImeiNumber

.PARAMETER OrganizationGroupId
The new organization group ID.

.NOTES
#>
function Set-DeviceOrganizationGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Identifier')]
        [string]
        $Id
        ,
        [Parameter(Mandatory = $true)]
        [Alias('IdentifierType')]
        [ValidateSet('Macaddress', 'Udid', 'Serialnumber', 'ImeiNumber')]
        [string]
        $IdType
        ,
        [Parameter(Mandatory = $true)]
        [int]
        $OrganizationGroupId
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Uri = "$($Config.ApiUrl)/mdm/devices/commands/changeorganizationgroup"
    $Data = @{}
    if ($Id) { $Data.id = $Id }
    if ($IdType) { $Data.searchBy = $IdType }
    if ($OrganizationGroupId) { $Data.ogid = $OrganizationGroupId }
    $Query = @()
    foreach ($k in $Data.Keys) {
        $Query += "$($k)=$([uri]::EscapeDataString($Data[$k]))"
    }
    if ($Query.Count -gt 0) { $Uri = "$($Uri)?$($Query -join '&')" }
    if ($PSCmdlet.ShouldProcess("Setting organizationgroup to '$($OrganizationGroupId)' for device '$($Id)'.")) {
        $Splattributes = @{
            Uri = $Uri
            Method = 'POST'
            Version = 1
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
