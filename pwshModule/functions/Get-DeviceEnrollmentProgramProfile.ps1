function Get-DeviceEnrollmentProgramProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Uuid
    )
    $Attributes = @{
        Uri = "$($Config.ApiUrl)/mdm/dep/profiles/$($Uuid)"
        Method = 'GET'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Get Device Enrollment Program profile based on the profile unique identifier.

    .DESCRIPTION
    Gets the details of the saved Device Enrollment Program profile created based on the provided profile unique identifier.

    .PARAMETER Uuid
    The Universally Unique Identifier.

    .NOTES
    .EXAMPLE
    #>
}