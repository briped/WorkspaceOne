<#
.SYNOPSIS
Disables feature flag

.DESCRIPTION
Sets the specified Feature Flag to false for the specified organization group ID.

.PARAMETER Flag
The Feature Flag to disable.

.PARAMETER OrganizationGroupId
The organization group ID.

.NOTES
#>
function Disable-FeatureFlag {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $Flag
        ,
        [Parameter(Mandatory = $true)]
        [int]
        $OrganizationGroupId
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Uri = "$($Config.ApiUrl)/mdm/system/featureflag/$($Flag)/$($OrganizationGroupId)/false"
    if ($PSCmdlet.ShouldProcess("Setting $($Flag) to TRUE for organization id '$($OrganizationGroupId)'.")) {
        $Splattributes = @{
            Uri = $Uri
            Method = 'GET'
            Version = 1
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
