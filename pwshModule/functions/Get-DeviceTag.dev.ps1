function Get-DeviceTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('DeviceUUID')]
        [string]
        $UUID
    )
    Write-Error -Message "This function is not completed yet." -ErrorAction Stop

    $Uri = "$($Config.ApiUrl)/mdm/devices/${UUID}/tags"

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS
    Retrieves associated tags for a device

    .DESCRIPTION
    Retrieves a list of all associated tags for the device specified by the device UUID.

    .PARAMETER UUID
    Identifier for a device.

    .NOTES

    #>
}