<#
.SYNOPSIS
Updates the application on devices.

.DESCRIPTION
Updates the application on devices having device based licenses for the application if an update is available.

.PARAMETER Id
The application id.

.NOTES
.EXAMPLE
#>
function Update-PurchasedApp {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('AppId', 'ApplicationId')]
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
    if ($PSCmdlet.ShouldProcess("Update Application ID '$($Id)' on devices.")) {
        $Splattributes = @{
            Uri = "$($Config.ApiUrl)/mam/apps/purchased/$($Id)"
            Method = 'POST'
            Version = 1
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}