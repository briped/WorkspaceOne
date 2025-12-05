function Enable-FeatureFlag {
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
    $Uri = "$($Config.ApiUrl)/mdm/system/featureflag/$($FeatureFlag)/$($OrganizationGroupUuid)/true"
    if ($PSCmdlet.ShouldProcess("Setting $($FeatureFlag) to TRUE for organization UUID '$($OrganizationGroupUuid)'.")) {
        $Attributes = @{
            Uri = $Uri
            Method = 'GET'
            Version = 1
        }
        Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Enables feature flag

    .DESCRIPTION
    Sets the specified Feature Flag to true for the specified organization group ID.

    .PARAMETER FeatureFlag
    The Feature Flag to enable.

    .PARAMETER OrganizationGroupUuid
    The organization group UUID.

    .NOTES
    #>
}
