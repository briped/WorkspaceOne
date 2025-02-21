<#
.SYNOPSIS
Disables feature flag

.DESCRIPTION
Sets the specified Feature Flag to false for the specified organization group ID.

.PARAMETER FeatureFlag
The Feature Flag to disable.

.PARAMETER OrganizationGroupUuid
The organization group UUID.

.NOTES
#>
function Disable-FeatureFlag {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Feature', 'Flag')]
        [string]
        $FeatureFlag
        ,
        [Parameter(Mandatory = $true)]
        [Alias('UUID')]
        [string]
        $OrganizationGroupUuid
        ,
        [Parameter()]
        [switch]
        $Force
    )
    if ($Force -and !$Confirm) {
        $ConfirmPreference = 'None'
    }
    $Uri = "$($Config.ApiUrl)/mdm/system/featureflag/$($FeatureFlag)/$($OrganizationGroupUuid)/false"
    if ($PSCmdlet.ShouldProcess("Setting $($FeatureFlag) to TRUE for organization UUID '$($OrganizationGroupUuid)'.")) {
        $Splattributes = @{
            Uri = $Uri
            Method = 'GET'
            Version = 1
        }
        Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Splattributes
    }
}
