<#
.SYNOPSIS
Returns the list of product licenses associated with the given organization group

.DESCRIPTION
Returns the list of product licenses associated with the given organization group

.PARAMETER OriganizationGroupUuid
The unique identifier of the organization group.

.NOTES
.EXAMPLE
#>
function Get-ProductLicense {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $OriganizationGroupUuid
    )
    $Splattributes = @{
        Uri = "$($Config.ApiUrl)/system/groups/$($OriganizationGroupUuid)/licenses"
        Method = 'GET'
        Version = 1
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
}