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
        Version = 1
    }
    Write-Verbose -Message ($Splattributes | ConvertTo-Json -Compress)
    Invoke-ApiRequest @Splattributes
    <#
    .SYNOPSIS
    Searches in App stores for the applications with the specified search string and returns the details.

    .DESCRIPTION
    Searches in the App store for applications that match a specified search string (Example: Boxer) and return the details.

    .PARAMETER Name
    Application name to be searched. Example: Boxer. (Required).

    .NOTES
    .LINK
    .EXAMPLE
    #>
}