function Set-UserOrganizationGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('UserId')]
        [int]
        $Id
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
    if ($PSCmdlet.ShouldProcess("Setting organizationgroup to '$($LocationGroupId)' for user '$($Id)'.")) {
        $Attributes = @{
            Uri = "$($Config.ApiUrl)/system/users/$($Id)/changelocationgroup"
            Method = 'POST'
            Version = 1
        }
        Write-Verbose -Message ($Attributes | ConvertTo-Json -Compress)
        Invoke-ApiRequest @Attributes
    }
    <#
    .SYNOPSIS
    Change the organization group of the enrollment user.

    .DESCRIPTION
    Change the organization group of the enrollment user by enrollment user id. The organization group will be changed once the call is complete.

    .PARAMETER Id
    The enrollment user id.

    .PARAMETER OrganizationGroupId
    The new enrollment user organization group id (Required).

    .NOTES
    post /users/{id}/changelocationgroup
    [ base url: /API/system , api version: 1 ]
    #>
}