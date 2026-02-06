function Remove-DeviceTag {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $DeviceUUID
        ,
        [Parameter(Mandatory = $true)]
        [string]
        $TagUUID
    )
    #Write-Error -Message "This function is not completed yet." -ErrorAction Stop

    $Uri = "$($Config.ApiUrl)/mdm/devices/${DeviceUUID}/tags/${TagUUID}"

    $Attributes = @{
        Uri = $Uri
        Method = 'DELETE'
        Version = 1
    }
    if ($PSCmdlet.ShouldProcess("Device: ${DeviceUUID}. Tag: ${TagUUID}")) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Dissociate tag from a device

    .DESCRIPTION
    Dissociate a tag from the device specified by the device UUID.

    .PARAMETER DeviceUUID
    Identifier for a device.

    .PARAMETER TagUUID
    Identifier for a tag.

    .NOTES

    #>
}