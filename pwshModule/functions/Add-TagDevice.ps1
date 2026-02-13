function Add-TagDevice {
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
    $Uri = "$($Config.ApiUrl)/mdm/tags/${Id}/adddevices"
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
    if ($PSCmdlet.ShouldProcess("Add $($DeviceId.Count) devices to TagId ${Id}", 'Add-TagDevice', $Id)) {
        Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
        #Invoke-ApiRequest @Attributes
    }

    <#
    .SYNOPSIS
    Add devices to the tag.

    .DESCRIPTION
    Associates the given tag to the set of devices.

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