function Remove-TagDevice {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter(Mandatory = $true)]
        [int[]]
        $DeviceId
        ,
        [Parameter()]
        [switch]
        $Force
    )
    $Uri = "$($Config.ApiUrl)/mdm/tags/${Id}/removedevices"
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }

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
    if ($PSCmdlet.ShouldProcess("Remove $($DeviceId.Count) devices from TagId ${Id}", 'Remove-TagDevice', $Id)) {
        Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
        #Invoke-ApiRequest @Attributes
    }

    <#
    .SYNOPSIS
    Remove devices from the tag.

    .DESCRIPTION
    Remove devices from tag based on the tag identifier and devices to be removed.

    .PARAMETER Id
    Identifier for a tag.

    .PARAMETER DeviceId
    Identifier(s) for device(s).

    .PARAMETER Force
    Override confirmation prompts

    .NOTES
        .TODO
        .CHANGES
        2026-02-13
        + Added SupportsShouldProcess logic.

    #>
}