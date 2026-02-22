function Get-ApiInfo {
    [CmdletBinding()]
    param()
    $Uri = "$($Config.ApiUrl)/system/info"
    $Attributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Invoke-ApiRequest $($Attributes | ConvertTo-Json -Compress)"
    Invoke-ApiRequest @Attributes
    <#
    .SYNOPSIS
    Retrieves the information of the AirWatch Developer APIs.

    .DESCRIPTION
    Provides information about AirWatch version and API URLs. Replaces "https://{host}/API/v1" and "https://{host}/API/v2".
    #>
}