function Get-LookupField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('OrganizationGroupUuid', 'OrgGroupUuid', 'GroupUuid')]
        [string]
        $Uuid
        ,
        [Parameter()]
        [Alias('Lang', 'Locale')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Language
    )
    $Uri = "$($Config.ApiUrl)/system/lookup-value/keys/$($Uuid)"
    if ($Language) { $Uri += "?language=$($Language)" }
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/system/lookup-value/keys/$($Uuid)"
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
    <#
    .SYNOPSIS
    Retrieves lookup keys for a given organization group.

    .DESCRIPTION
    Retrieve all lookup value keys for the given organization group.

    .PARAMETER Uuid
    Represents the organization group to retrieve lookup value keys from.

    .PARAMETER Language
    The language code (Default en-US).

    .NOTES
    .EXAMPLE
    #>
}