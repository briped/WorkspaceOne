function Remove-TagDevice {
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
    Write-Error -Message "This function is not completed yet." -ErrorAction Stop

    $Uri = "$($Config.ApiUrl)/mdm/tags/${Id}/removedevices"

    $Payload = @{
        BulkValues = @{
            Value = $DeviceId
        }
    }
    $Attributes = @{
        Uri = $Uri
        Method = 'POST'
        Version = 1
        $Body = $Payload
    }
    Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Attributes

    <#
    .SYNOPSIS
    Remove devices from the tag.

    .DESCRIPTION
    Remove devices from tag based on the tag identifier and devices to be removed.

    .PARAMETER Id
    Identifier for a tag.

    .PARAMETER DeviceId
    Identifier(s) for device(s).

    .NOTES

    #>
}