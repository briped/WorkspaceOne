function Get-TagDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('TagId')]
        [string]
        $Id
        ,
        [Parameter()]
        [datetime]
        $LastSeen
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/${Id}/devices"

    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS
    Retrieves all the devices with the specified tag.

    .DESCRIPTION
    Retrieves the list of devices that have the specified input tag assinged.

    .PARAMETER Id
    Identifier for a device.

    .NOTES

    #>
}