function Add-TagDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true)]
        [int[]]
        $DeviceId
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/${Id}/adddevices"

    $Payload = @{
        BulkValues = @{
            Value = $DeviceId
        }
    }
    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Version = 1
        Body = $Payload | ConvertTo-Json -Compress
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS
    Add devices to the tag.

    .DESCRIPTION
    Associates the given tag to the set of devices.

    .PARAMETER Id
    Identifier for a tag.

    .PARAMETER DeviceId
    Identifier(s) for device(s).

    .NOTES

    #>
}