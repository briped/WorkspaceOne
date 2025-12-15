function Remove-Device {
    [CmdletBinding(SupportsShouldProcess = $true
                ,  ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
    )
    $Attributes = @{
        Uri = "$($Config.ApiUrl)/mdm/devices/$($Id)"
        Method = 'DELETE'
    }
    if ($PSCmdlet.ShouldProcess($Id)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Delete Device details by device identifier.

    .DESCRIPTION
    Delete Device details by Device id.
    
    .PARAMETER Id
    The Device ID.

    .NOTES
    .EXAMPLE
    #>
}