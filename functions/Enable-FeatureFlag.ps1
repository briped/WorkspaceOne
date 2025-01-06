<#
.SYNOPSIS
Enables feature flag

.DESCRIPTION
Sets the specified Feature Flag to true for the specified organization group ID.

.PARAMETER Flag
The Feature Flag to enable.

.PARAMETER OrganizationGroupId
The organization group ID.

.NOTES
#>
function Enable-FeatureFlag {
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
    $Uri = "$($Config.ApiUrl)/mdm/system/featureflag/$($Flag)/$($OrganizationGroupId)/true"
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
