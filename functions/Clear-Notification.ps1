<#
.SYNOPSIS
Dismiss a notification.

.DESCRIPTION
Dismiss a notification using notification id passed in by the user.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

Example Value:
{
    "Value": 1
}

Model:
EntityId {
    Value (integer, optional, read only)
}

.PARAMETER Id
Notification ID

.LINK
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
