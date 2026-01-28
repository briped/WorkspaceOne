function Add-DeviceTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $DeviceUUID
        ,
        [Parameter(Mandatory = $true)]
        [string]
        $TagUUID
    )
    $Uri = "$($Config.ApiUrl)/mdm/devices/${DeviceUUID}/tags/${TagUUID}"

    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS
    Associates tag with a device

    .DESCRIPTION
    Associates a tag with the device specified by the device UUID.

    .PARAMETER DeviceUUID
    Identifier for a device.

    .PARAMETER TagUUID
    Identifier for a tag.

    .EXAMPLE
    Add-DeviceTag -DeviceUUID 12345678-90ab-cdef-abcd-ef0987654321 -TagUUID abcdef12-3456-7890-1234-567890abcdef

    .NOTES
    #>
}