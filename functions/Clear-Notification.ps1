<#
.SYNOPSIS
Dismiss a notification.

.DESCRIPTION
Dismiss a notification using notification id passed in by the user.

.PARAMETER Id
Notification ID

.NOTES
.EXAMPLE
#>
function Clear-Notification {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Id
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    # TODO: Update the ShouldProcess text
    if ($PSCmdlet.ShouldProcess("Dismiss Notification ID '$($Id)'.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/system/notifications/$($Id)"
            Method = 'POST'
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}