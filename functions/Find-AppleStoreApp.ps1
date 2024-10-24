<#
.SYNOPSIS
Searches in App stores for the applications with the specified search string and returns the details.

.DESCRIPTION
Searches in the App store for applications that match a specified search string (Example: Boxer) and return the details.

.NOTES
Information or caveats about the function e.g. 'This function is not supported in Linux'

get /apps/applestore/search
[ base url: /API/mam , api version: 1 ]

.PARAMETER appname
Application name to be searched. Example: Boxer. (Required).
query	string

.LINK
.EXAMPLE
#>
function Find-AppleStoreApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name
    )
    $Uri = "$($Config.ApiUrl)/mam/apps/applestore/search"
    $Uri = "$($Uri)?appname=$([uri]::EscapeDataString($Name))"
    $Splattributes = @{
        Uri = $Uri
        Method = 'GET'
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
}
